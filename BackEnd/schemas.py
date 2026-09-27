from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class LoginRequest(BaseModel):
    email: str
    senha: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    id: int
    nome: str
    email: str
    tipo: str

class UsuarioCreate(BaseModel):
    nome: str
    email: str
    senha: str
    tipo: str = "advogado"

class UsuarioStatusUpdate(BaseModel):
    ativo: bool

class UsuarioResponse(BaseModel):
    id: int
    nome: str
    email: str
    tipo: str
    ativo: bool = True

    class Config:
        from_attributes = True

class PerfilUpdate(BaseModel):
    email: Optional[str] = None
    senha_atual: str
    nova_senha: Optional[str] = None

class ClienteCreate(BaseModel):
    nome: str
    cpf: str
    telefone: str
    email: str
    advogado_id: int

class ClienteUpdate(BaseModel):
    nome: Optional[str] = None
    cpf: Optional[str] = None
    telefone: Optional[str] = None
    email: Optional[str] = None
    advogado_id: Optional[int] = None

class ClienteResponse(BaseModel):
    id: int
    nome: str
    cpf: str
    telefone: str
    email: str
    advogado_id: int
    advogado_nome: Optional[str] = None

    class Config:
        from_attributes = True

class ProcessoCreate(BaseModel):
    numero_processo: str
    descricao: str
    status: str
    cliente_id: int
    advogado_id: int

class ProcessoUpdate(BaseModel):
    numero_processo: Optional[str] = None
    descricao: Optional[str] = None
    status: Optional[str] = None
    cliente_id: Optional[int] = None
    advogado_id: Optional[int] = None

class HistoricoCreate(BaseModel):
    nome_movimento: str
    descricao_detalhada: Optional[str] = None

class HistoricoResponse(BaseModel):
    id: int
    processo_id: int
    data_hora: datetime
    origem: str
    nome_movimento: str
    descricao_detalhada: Optional[str] = None

    class Config:
        from_attributes = True

class ProcessoResponse(BaseModel):
    id: int
    numero_processo: str
    descricao: str
    status: str
    cliente_id: int
    advogado_id: int
    cliente_nome: Optional[str] = None
    advogado_nome: Optional[str] = None
    tribunal: Optional[str] = None
    classe_processual: Optional[str] = None
    orgao_julgador: Optional[str] = None
    data_ajuizamento: Optional[datetime] = None
    historicos: List[HistoricoResponse] = []

    class Config:
        from_attributes = True

class AgendamentoCreate(BaseModel):
    titulo: str
    descricao: str
    data_hora: datetime
    advogado_id: int
    cliente_id: Optional[int] = None

class AgendamentoUpdate(BaseModel):
    titulo: Optional[str] = None
    descricao: Optional[str] = None
    data_hora: Optional[datetime] = None
    advogado_id: Optional[int] = None
    cliente_id: Optional[int] = None
    ata_reuniao: Optional[str] = None

class AtaReuniaoUpdate(BaseModel):
    ata_reuniao: str

class AgendamentoResponse(BaseModel):
    id: int
    titulo: str
    descricao: str
    data_hora: datetime
    advogado_id: int
    advogado_nome: Optional[str] = None
    cliente_id: Optional[int] = None
    cliente_nome: Optional[str] = None
    ata_reuniao: Optional[str] = None

    class Config:
        from_attributes = True

class MetricsResponse(BaseModel):
    total_advogados: int
    total_clientes: int
    total_processos: int
    total_agendamentos: int
