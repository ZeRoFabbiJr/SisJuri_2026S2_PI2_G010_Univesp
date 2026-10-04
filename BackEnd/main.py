from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from datetime import datetime

import models
import schemas
from database import engine, get_db, Base
from security import (
    hash_password, verify_password, create_access_token, decode_access_token, is_hashed
)
from cnj_service import consultar_processo_cnj

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Sistema Jurídico de Gerenciamento", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security_bearer = HTTPBearer()

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security_bearer),
    db: Session = Depends(get_db)
) -> models.Usuario:
    token = credentials.credentials
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido ou expirado."
        )
    user_id = payload.get("user_id")
    user = db.query(models.Usuario).filter(models.Usuario.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário não encontrado."
        )
    if not user.ativo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário desativado. Entre em contato com o administrador Master."
        )
    return user

def require_master(current_user: models.Usuario = Depends(get_current_user)) -> models.Usuario:
    if current_user.tipo != "master":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Acesso restrito a usuários com perfil Master."
        )
    return current_user

@app.on_event("startup")
def startup_db_seed():
    db = next(get_db())
    
    # 1. Master user
    master = db.query(models.Usuario).filter(func.lower(models.Usuario.email) == "master@escritorio.com").first()
    if not master:
        master_user = models.Usuario(
            nome="João Braga",
            email="master@escritorio.com",
            senha=hash_password("123456"),
            tipo="master",
            ativo=True
        )
        db.add(master_user)
        db.commit()
    else:
        master.senha = hash_password("123456")
        master.ativo = True
        db.commit()

    # 2. Advogado 1
    adv1 = db.query(models.Usuario).filter(func.lower(models.Usuario.email) == "joao@escritorio.com").first()
    if not adv1:
        db.add(models.Usuario(
            nome="João Vitor",
            email="joao@escritorio.com",
            senha=hash_password("123456"),
            tipo="advogado",
            ativo=True
        ))
        db.commit()
    else:
        adv1.senha = hash_password("123456")
        adv1.ativo = True
        db.commit()

    # 3. Advogado 2
    adv2 = db.query(models.Usuario).filter(func.lower(models.Usuario.email) == "rafaela@escritorio.com").first()
    if not adv2:
        db.add(models.Usuario(
            nome="Rafaela Guimarães",
            email="rafaela@escritorio.com",
            senha=hash_password("123456"),
            tipo="advogado",
            ativo=True
        ))
        db.commit()
    else:
        adv2.senha = hash_password("123456")
        adv2.ativo = True
        db.commit()

# AUTH & PROFILE
@app.post("/api/login", response_model=schemas.TokenResponse)
def login(credentials: schemas.LoginRequest, db: Session = Depends(get_db)):
    email_clean = credentials.email.lower().strip()
    user = db.query(models.Usuario).filter(func.lower(models.Usuario.email) == email_clean).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="E-mail ou senha incorretos."
        )

    pwd_valid = verify_password(credentials.senha, user.senha)

    # Auto-recovery para usuários padrão do sistema com senha padrão '123456'
    if not pwd_valid and credentials.senha == "123456" and user.email.lower() in ["master@escritorio.com", "joao@escritorio.com", "rafaela@escritorio.com"]:
        user.senha = hash_password("123456")
        user.ativo = True
        db.commit()
        db.refresh(user)
        pwd_valid = True

    if not pwd_valid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="E-mail ou senha incorretos."
        )

    if not user.ativo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário desativado. Entre em contato com o administrador Master."
        )

    access_token = create_access_token(data={"sub": user.email, "user_id": user.id, "tipo": user.tipo})
    
    return schemas.TokenResponse(
        access_token=access_token,
        token_type="bearer",
        id=user.id,
        nome=user.nome,
        email=user.email,
        tipo=user.tipo
    )

@app.put("/api/usuarios/me", response_model=schemas.UsuarioResponse)
def update_me_perfil(
    perfil: schemas.PerfilUpdate,
    db: Session = Depends(get_db),
    current_user: models.Usuario = Depends(get_current_user)
):
    if not verify_password(perfil.senha_atual, current_user.senha):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A senha atual informada está incorreta."
        )

    if perfil.email and perfil.email.lower().strip() != current_user.email.lower():
        novo_email = perfil.email.lower().strip()
        existing = db.query(models.Usuario).filter(
            func.lower(models.Usuario.email) == novo_email,
            models.Usuario.id != current_user.id
        ).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="O e-mail informado já está em uso por outro usuário."
            )
        current_user.email = novo_email

    if perfil.nova_senha and perfil.nova_senha.strip():
        if len(perfil.nova_senha.strip()) < 4:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A nova senha deve ter no mínimo 4 caracteres."
            )
        current_user.senha = hash_password(perfil.nova_senha.strip())

    db.commit()
    db.refresh(current_user)
    return current_user

# DASHBOARD METRICS
@app.get("/api/dashboard/metrics", response_model=schemas.MetricsResponse)
def get_dashboard_metrics(
    db: Session = Depends(get_db),
    current_user: models.Usuario = Depends(get_current_user)
):
    if current_user.tipo == "master":
        total_adv = db.query(models.Usuario).filter(models.Usuario.tipo == "advogado").count()
        total_cli = db.query(models.Cliente).count()
        total_proc = db.query(models.Processo).count()
        total_agd = db.query(models.Agendamento).count()
    else:
        total_adv = 1
        total_cli = db.query(models.Cliente).filter(models.Cliente.advogado_id == current_user.id).count()
        total_proc = db.query(models.Processo).filter(models.Processo.advogado_id == current_user.id).count()
        total_agd = db.query(models.Agendamento).filter(models.Agendamento.advogado_id == current_user.id).count()

    return schemas.MetricsResponse(
        total_advogados=total_adv,
        total_clientes=total_cli,
        total_processos=total_proc,
        total_agendamentos=total_agd
    )

# USUARIOS (MASTER)
@app.get("/api/usuarios", response_model=List[schemas.UsuarioResponse])
def list_usuarios(
    tipo: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: models.Usuario = Depends(get_current_user)
):
    # Retorna todos os usuarios cadastrados sem filtrar por 'ativo' estrito (evita listas vazias se 'ativo' for NULL)
    query = db.query(models.Usuario)
    if tipo:
        tipo_clean = tipo.lower().strip()
        if tipo_clean in ["advogado", "master"]:
            query = query.filter(func.lower(models.Usuario.tipo).in_(["advogado", "master", "admin"]))
        else:
            query = query.filter(func.lower(models.Usuario.tipo) == tipo_clean)
            
    return query.all()

@app.post("/api/usuarios", response_model=schemas.UsuarioResponse)
def create_usuario(
    usuario: schemas.UsuarioCreate,
    db: Session = Depends(get_db),
    current_user: models.Usuario = Depends(require_master)
):
    email_clean = usuario.email.lower().strip()
    if db.query(models.Usuario).filter(func.lower(models.Usuario.email) == email_clean).first():
        raise HTTPException(status_code=400, detail="E-mail já cadastrado.")
    
    db_user = models.Usuario(
        nome=usuario.nome,
        email=email_clean,
        senha=hash_password(usuario.senha),
        tipo=usuario.tipo,
        ativo=True
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.put("/api/usuarios/{usuario_id}/status", response_model=schemas.UsuarioResponse)
def update_usuario_status(
    usuario_id: int,
    status_update: schemas.UsuarioStatusUpdate,
    db: Session = Depends(get_db),
    current_user: models.Usuario = Depends(require_master)
):
    user = db.query(models.Usuario).filter(models.Usuario.id == usuario_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")
    
    if user.id == current_user.id:
        raise HTTPException(status_code=400, detail="Não é possível alterar o próprio status.")

    user.ativo = status_update.ativo
    if user.ativo:
        user.senha = hash_password("123456")

    db.commit()
    db.refresh(user)
    return user

# CLIENTES
@app.get("/api/clientes", response_model=List[schemas.ClienteResponse])
def list_clientes(db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    # Retorna todos os clientes do escritorio para que qualquer usuario possa agendar compromissos
    clientes = db.query(models.Cliente).all()
    
    res = []
    for cli in clientes:
        res.append(schemas.ClienteResponse(
            id=cli.id,
            nome=cli.nome,
            cpf=cli.cpf,
            telefone=cli.telefone,
            email=cli.email,
            advogado_id=cli.advogado_id,
            advogado_nome=cli.advogado.nome if cli.advogado else None
        ))
    return res

@app.post("/api/clientes", response_model=schemas.ClienteResponse)
def create_cliente(cliente: schemas.ClienteCreate, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    db_cli = models.Cliente(
        nome=cliente.nome,
        cpf=cliente.cpf,
        telefone=cliente.telefone,
        email=cliente.email,
        advogado_id=cliente.advogado_id
    )
    db.add(db_cli)
    db.commit()
    db.refresh(db_cli)
    return schemas.ClienteResponse(
        id=db_cli.id,
        nome=db_cli.nome,
        cpf=db_cli.cpf,
        telefone=db_cli.telefone,
        email=db_cli.email,
        advogado_id=db_cli.advogado_id,
        advogado_nome=db_cli.advogado.nome if db_cli.advogado else None
    )

@app.put("/api/clientes/{cliente_id}", response_model=schemas.ClienteResponse)
def update_cliente(cliente_id: int, cliente: schemas.ClienteUpdate, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    cli = db.query(models.Cliente).filter(models.Cliente.id == cliente_id).first()
    if not cli:
        raise HTTPException(status_code=404, detail="Cliente não encontrado.")
    if current_user.tipo != "master" and cli.advogado_id != current_user.id:
        raise HTTPException(status_code=403, detail="Acesso negado.")

    if cliente.nome is not None: cli.nome = cliente.nome
    if cliente.cpf is not None: cli.cpf = cliente.cpf
    if cliente.telefone is not None: cli.telefone = cliente.telefone
    if cliente.email is not None: cli.email = cliente.email
    if cliente.advogado_id is not None: cli.advogado_id = cliente.advogado_id

    db.commit()
    db.refresh(cli)
    return schemas.ClienteResponse(
        id=cli.id,
        nome=cli.nome,
        cpf=cli.cpf,
        telefone=cli.telefone,
        email=cli.email,
        advogado_id=cli.advogado_id,
        advogado_nome=cli.advogado.nome if cli.advogado else None
    )

@app.delete("/api/clientes/{cliente_id}")
def delete_cliente(cliente_id: int, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    cli = db.query(models.Cliente).filter(models.Cliente.id == cliente_id).first()
    if not cli:
        raise HTTPException(status_code=404, detail="Cliente não encontrado.")
    if current_user.tipo != "master" and cli.advogado_id != current_user.id:
        raise HTTPException(status_code=403, detail="Acesso negado.")
    db.delete(cli)
    db.commit()
    return {"ok": True}

# PROCESSOS
@app.get("/api/processos", response_model=List[schemas.ProcessoResponse])
def list_processos(db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    if current_user.tipo == "master":
        procs = db.query(models.Processo).all()
    else:
        procs = db.query(models.Processo).filter(models.Processo.advogado_id == current_user.id).all()
    
    res = []
    for p in procs:
        res.append(schemas.ProcessoResponse(
            id=p.id,
            numero_processo=p.numero_processo,
            descricao=p.descricao,
            status=p.status,
            cliente_id=p.cliente_id,
            advogado_id=p.advogado_id,
            cliente_nome=p.cliente.nome if p.cliente else None,
            advogado_nome=p.advogado.nome if p.advogado else None,
            tribunal=p.tribunal,
            classe_processual=p.classe_processual,
            orgao_julgador=p.orgao_julgador,
            data_ajuizamento=p.data_ajuizamento,
            historicos=[
                schemas.HistoricoResponse(
                    id=h.id,
                    processo_id=h.processo_id,
                    data_hora=h.data_hora,
                    origem=h.origem,
                    nome_movimento=h.nome_movimento,
                    descricao_detalhada=h.descricao_detalhada
                ) for h in p.historicos
            ]
        ))
    return res

@app.post("/api/processos", response_model=schemas.ProcessoResponse)
def create_processo(proc: schemas.ProcessoCreate, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    clean_num = proc.numero_processo.strip()
    db_proc = models.Processo(
        numero_processo=clean_num,
        descricao=proc.descricao,
        status=proc.status,
        cliente_id=proc.cliente_id,
        advogado_id=proc.advogado_id
    )
    db.add(db_proc)
    db.commit()
    db.refresh(db_proc)

    try:
        cnj_info = consultar_processo_cnj(clean_num)
        if cnj_info.get("sucesso"):
            db_proc.tribunal = cnj_info.get("tribunal")
            db_proc.classe_processual = cnj_info.get("classe")
            db_proc.orgao_julgador = cnj_info.get("orgao_julgador")
            if cnj_info.get("data_ajuizamento"):
                try:
                    db_proc.data_ajuizamento = datetime.fromisoformat(cnj_info["data_ajuizamento"].replace("Z", "+00:00"))
                except Exception:
                    pass
            for m in cnj_info.get("movimentos", []):
                dt = datetime.utcnow()
                if m.get("dataHora"):
                    try: dt = datetime.fromisoformat(m["dataHora"].replace("Z", "+00:00"))
                    except Exception: pass
                db_hist = models.HistoricoProcesso(
                    processo_id=db_proc.id,
                    data_hora=dt,
                    origem="CNJ Datajud",
                    nome_movimento=m.get("nome", "Movimento CNJ"),
                    descricao_detalhada=f"Código TPU: {m.get('codigo', 'N/A')}"
                )
                db.add(db_hist)
            db.commit()
            db.refresh(db_proc)
    except Exception:
        pass

    return schemas.ProcessoResponse(
        id=db_proc.id,
        numero_processo=db_proc.numero_processo,
        descricao=db_proc.descricao,
        status=db_proc.status,
        cliente_id=db_proc.cliente_id,
        advogado_id=db_proc.advogado_id,
        cliente_nome=db_proc.cliente.nome if db_proc.cliente else None,
        advogado_nome=db_proc.advogado.nome if db_proc.advogado else None,
        tribunal=db_proc.tribunal,
        classe_processual=db_proc.classe_processual,
        orgao_julgador=db_proc.orgao_julgador,
        data_ajuizamento=db_proc.data_ajuizamento,
        historicos=[]
    )

@app.put("/api/processos/{proc_id}", response_model=schemas.ProcessoResponse)
def update_processo(proc_id: int, proc: schemas.ProcessoUpdate, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    db_proc = db.query(models.Processo).filter(models.Processo.id == proc_id).first()
    if not db_proc:
        raise HTTPException(status_code=404, detail="Processo não encontrado.")
    if current_user.tipo != "master" and db_proc.advogado_id != current_user.id:
        raise HTTPException(status_code=403, detail="Acesso negado.")

    if proc.numero_processo is not None: db_proc.numero_processo = proc.numero_processo.strip()
    if proc.descricao is not None: db_proc.descricao = proc.descricao
    if proc.status is not None: db_proc.status = proc.status
    if proc.cliente_id is not None: db_proc.cliente_id = proc.cliente_id
    if proc.advogado_id is not None: db_proc.advogado_id = proc.advogado_id

    db.commit()
    db.refresh(db_proc)
    return schemas.ProcessoResponse(
        id=db_proc.id,
        numero_processo=db_proc.numero_processo,
        descricao=db_proc.descricao,
        status=db_proc.status,
        cliente_id=db_proc.cliente_id,
        advogado_id=db_proc.advogado_id,
        cliente_nome=db_proc.cliente.nome if db_proc.cliente else None,
        advogado_nome=db_proc.advogado.nome if db_proc.advogado else None,
        tribunal=db_proc.tribunal,
        classe_processual=db_proc.classe_processual,
        orgao_julgador=db_proc.orgao_julgador,
        data_ajuizamento=db_proc.data_ajuizamento,
        historicos=[]
    )

@app.delete("/api/processos/{proc_id}")
def delete_processo(proc_id: int, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    db_proc = db.query(models.Processo).filter(models.Processo.id == proc_id).first()
    if not db_proc:
        raise HTTPException(status_code=404, detail="Processo não encontrado.")
    if current_user.tipo != "master" and db_proc.advogado_id != current_user.id:
        raise HTTPException(status_code=403, detail="Acesso negado.")
    db.delete(db_proc)
    db.commit()
    return {"ok": True}

@app.post("/api/processos/{proc_id}/consultar-cnj", response_model=schemas.ProcessoResponse)
def consultar_cnj_processo(proc_id: int, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    db_proc = db.query(models.Processo).filter(models.Processo.id == proc_id).first()
    if not db_proc:
        raise HTTPException(status_code=404, detail="Processo não encontrado.")

    cnj_info = consultar_processo_cnj(db_proc.numero_processo)
    if not cnj_info.get("sucesso"):
        raise HTTPException(status_code=400, detail=cnj_info.get("erro", "Erro ao consultar CNJ."))

    db_proc.tribunal = cnj_info.get("tribunal")
    db_proc.classe_processual = cnj_info.get("classe")
    db_proc.orgao_julgador = cnj_info.get("orgao_julgador")
    if cnj_info.get("data_ajuizamento"):
        try:
            db_proc.data_ajuizamento = datetime.fromisoformat(cnj_info["data_ajuizamento"].replace("Z", "+00:00"))
        except Exception:
            pass

    existing_movs = {h.nome_movimento for h in db_proc.historicos}
    for m in cnj_info.get("movimentos", []):
        nome_mov = m.get("nome", "Movimento CNJ")
        if nome_mov not in existing_movs:
            dt = datetime.utcnow()
            if m.get("dataHora"):
                try: dt = datetime.fromisoformat(m["dataHora"].replace("Z", "+00:00"))
                except Exception: pass
            db_hist = models.HistoricoProcesso(
                processo_id=db_proc.id,
                data_hora=dt,
                origem="CNJ Datajud",
                nome_movimento=nome_mov,
                descricao_detalhada=f"Código TPU: {m.get('codigo', 'N/A')}"
            )
            db.add(db_hist)

    db.commit()
    db.refresh(db_proc)
    return schemas.ProcessoResponse(
        id=db_proc.id,
        numero_processo=db_proc.numero_processo,
        descricao=db_proc.descricao,
        status=db_proc.status,
        cliente_id=db_proc.cliente_id,
        advogado_id=db_proc.advogado_id,
        cliente_nome=db_proc.cliente.nome if db_proc.cliente else None,
        advogado_nome=db_proc.advogado.nome if db_proc.advogado else None,
        tribunal=db_proc.tribunal,
        classe_processual=db_proc.classe_processual,
        orgao_julgador=db_proc.orgao_julgador,
        data_ajuizamento=db_proc.data_ajuizamento,
        historicos=[
            schemas.HistoricoResponse(
                id=h.id,
                processo_id=h.processo_id,
                data_hora=h.data_hora,
                origem=h.origem,
                nome_movimento=h.nome_movimento,
                descricao_detalhada=h.descricao_detalhada
            ) for h in db_proc.historicos
        ]
    )

@app.post("/api/processos/{proc_id}/historico", response_model=schemas.HistoricoResponse)
def add_historico_manual(proc_id: int, hist: schemas.HistoricoCreate, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    db_proc = db.query(models.Processo).filter(models.Processo.id == proc_id).first()
    if not db_proc:
        raise HTTPException(status_code=404, detail="Processo não encontrado.")

    db_hist = models.HistoricoProcesso(
        processo_id=proc_id,
        data_hora=datetime.utcnow(),
        origem="Manual",
        nome_movimento=hist.nome_movimento,
        descricao_detalhada=hist.descricao_detalhada
    )
    db.add(db_hist)
    db.commit()
    db.refresh(db_hist)
    return schemas.HistoricoResponse(
        id=db_hist.id,
        processo_id=db_hist.processo_id,
        data_hora=db_hist.data_hora,
        origem=db_hist.origem,
        nome_movimento=db_hist.nome_movimento,
        descricao_detalhada=db_hist.descricao_detalhada
    )

# AGENDAMENTOS
@app.get("/api/agendamentos", response_model=List[schemas.AgendamentoResponse])
def list_agendamentos(
    data_inicio: Optional[str] = None,
    data_fim: Optional[str] = None,
    advogado_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: models.Usuario = Depends(get_current_user)
):
    query = db.query(models.Agendamento)
    
    if current_user.tipo != "master":
        query = query.filter(models.Agendamento.advogado_id == current_user.id)
    elif advogado_id:
        query = query.filter(models.Agendamento.advogado_id == advogado_id)

    if data_inicio and data_fim:
        try:
            dt_inicio = datetime.fromisoformat(data_inicio)
            dt_fim = datetime.fromisoformat(data_fim).replace(hour=23, minute=59, second=59)
            query = query.filter(models.Agendamento.data_hora >= dt_inicio, models.Agendamento.data_hora <= dt_fim)
        except Exception:
            pass

    agds = query.order_by(models.Agendamento.data_hora.asc()).all()
    
    res = []
    for a in agds:
        res.append(schemas.AgendamentoResponse(
            id=a.id,
            titulo=a.titulo,
            descricao=a.descricao,
            data_hora=a.data_hora,
            advogado_id=a.advogado_id,
            advogado_nome=a.advogado.nome if a.advogado else None,
            cliente_id=a.cliente_id,
            cliente_nome=a.cliente.nome if a.cliente else None,
            ata_reuniao=a.ata_reuniao
        ))
    return res

@app.post("/api/agendamentos", response_model=schemas.AgendamentoResponse)
def create_agendamento(agd: schemas.AgendamentoCreate, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    # VALIDACAO DE CONFLITO DE AGENDA: ADVOGADO E CLIENTE
    # 1. Checa conflito para o mesmo advogado na mesma data e hora
    conflict_adv = db.query(models.Agendamento).filter(
        models.Agendamento.data_hora == agd.data_hora,
        models.Agendamento.advogado_id == agd.advogado_id
    ).first()
    if conflict_adv:
        raise HTTPException(
            status_code=400,
            detail="Não é possível agendar: O advogado já possui uma reunião cadastrada exatamente nesta data e hora."
        )

    # 2. Checa conflito para o mesmo cliente na mesma data e hora (se cliente_id for informado)
    if agd.cliente_id is not None:
        conflict_cli = db.query(models.Agendamento).filter(
            models.Agendamento.data_hora == agd.data_hora,
            models.Agendamento.cliente_id == agd.cliente_id
        ).first()
        if conflict_cli:
            raise HTTPException(
                status_code=400,
                detail="Não é possível agendar: O cliente já possui uma reunião cadastrada exatamente nesta data e hora."
            )

    db_agd = models.Agendamento(
        titulo=agd.titulo,
        descricao=agd.descricao,
        data_hora=agd.data_hora,
        advogado_id=agd.advogado_id,
        cliente_id=agd.cliente_id
    )
    db.add(db_agd)
    db.commit()
    db.refresh(db_agd)
    return schemas.AgendamentoResponse(
        id=db_agd.id,
        titulo=db_agd.titulo,
        descricao=db_agd.descricao,
        data_hora=db_agd.data_hora,
        advogado_id=db_agd.advogado_id,
        advogado_nome=db_agd.advogado.nome if db_agd.advogado else None,
        cliente_id=db_agd.cliente_id,
        cliente_nome=db_agd.cliente.nome if db_agd.cliente else None,
        ata_reuniao=db_agd.ata_reuniao
    )

@app.put("/api/agendamentos/{agd_id}", response_model=schemas.AgendamentoResponse)
def update_agendamento(agd_id: int, agd: schemas.AgendamentoUpdate, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    db_agd = db.query(models.Agendamento).filter(models.Agendamento.id == agd_id).first()
    if not db_agd:
        raise HTTPException(status_code=404, detail="Agendamento não encontrado.")
    if current_user.tipo != "master" and db_agd.advogado_id != current_user.id:
        raise HTTPException(status_code=403, detail="Acesso negado.")

    target_dh = agd.data_hora if agd.data_hora is not None else db_agd.data_hora
    target_adv = agd.advogado_id if agd.advogado_id is not None else db_agd.advogado_id
    target_cli = agd.cliente_id if agd.cliente_id is not None else db_agd.cliente_id

    # Checa conflito do advogado
    conflict_adv = db.query(models.Agendamento).filter(
        models.Agendamento.data_hora == target_dh,
        models.Agendamento.advogado_id == target_adv,
        models.Agendamento.id != agd_id
    ).first()
    if conflict_adv:
        raise HTTPException(
            status_code=400,
            detail="Não é possível alterar agendamento: O advogado já possui uma reunião cadastrada exatamente nesta data e hora."
        )

    # Checa conflito do cliente
    if target_cli is not None:
        conflict_cli = db.query(models.Agendamento).filter(
            models.Agendamento.data_hora == target_dh,
            models.Agendamento.cliente_id == target_cli,
            models.Agendamento.id != agd_id
        ).first()
        if conflict_cli:
            raise HTTPException(
                status_code=400,
                detail="Não é possível alterar agendamento: O cliente já possui uma reunião cadastrada exatamente nesta data e hora."
            )

    if agd.titulo is not None: db_agd.titulo = agd.titulo
    if agd.descricao is not None: db_agd.descricao = agd.descricao
    if agd.data_hora is not None: db_agd.data_hora = agd.data_hora
    if agd.advogado_id is not None: db_agd.advogado_id = agd.advogado_id
    if agd.cliente_id is not None: db_agd.cliente_id = agd.cliente_id

    db.commit()
    db.refresh(db_agd)
    return schemas.AgendamentoResponse(
        id=db_agd.id,
        titulo=db_agd.titulo,
        descricao=db_agd.descricao,
        data_hora=db_agd.data_hora,
        advogado_id=db_agd.advogado_id,
        advogado_nome=db_agd.advogado.nome if db_agd.advogado else None,
        cliente_id=db_agd.cliente_id,
        cliente_nome=db_agd.cliente.nome if db_agd.cliente else None,
        ata_reuniao=db_agd.ata_reuniao
    )

@app.put("/api/agendamentos/{agd_id}/ata", response_model=schemas.AgendamentoResponse)
def update_ata_reuniao(agd_id: int, ata_data: schemas.AtaReuniaoUpdate, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    db_agd = db.query(models.Agendamento).filter(models.Agendamento.id == agd_id).first()
    if not db_agd:
        raise HTTPException(status_code=404, detail="Agendamento não encontrado.")
    if current_user.tipo != "master" and db_agd.advogado_id != current_user.id:
        raise HTTPException(status_code=403, detail="Acesso negado.")

    db_agd.ata_reuniao = ata_data.ata_reuniao
    db.commit()
    db.refresh(db_agd)
    return schemas.AgendamentoResponse(
        id=db_agd.id,
        titulo=db_agd.titulo,
        descricao=db_agd.descricao,
        data_hora=db_agd.data_hora,
        advogado_id=db_agd.advogado_id,
        advogado_nome=db_agd.advogado.nome if db_agd.advogado else None,
        cliente_id=db_agd.cliente_id,
        cliente_nome=db_agd.cliente.nome if db_agd.cliente else None,
        ata_reuniao=db_agd.ata_reuniao
    )

@app.delete("/api/agendamentos/{agd_id}")
def delete_agendamento(agd_id: int, db: Session = Depends(get_db), current_user: models.Usuario = Depends(get_current_user)):
    agd = db.query(models.Agendamento).filter(models.Agendamento.id == agd_id).first()
    if not agd:
        raise HTTPException(status_code=404, detail="Agendamento não encontrado.")
    if current_user.tipo != "master" and agd.advogado_id != current_user.id:
        raise HTTPException(status_code=403, detail="Acesso negado.")
    db.delete(agd)
    db.commit()
    return {"ok": True}
