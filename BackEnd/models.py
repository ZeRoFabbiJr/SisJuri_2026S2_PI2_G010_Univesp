from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String(100), nullable=False)
    email = Column(String(120), unique=True, index=True, nullable=False)
    senha = Column(String(255), nullable=False)
    tipo = Column(String(20), nullable=False, default="advogado")
    ativo = Column(Boolean, nullable=False, default=True)
    criado_em = Column(DateTime, default=datetime.utcnow)

    clientes = relationship("Cliente", back_populates="advogado", cascade="all, delete-orphan")
    processos = relationship("Processo", back_populates="advogado")
    agendamentos = relationship("Agendamento", back_populates="advogado", cascade="all, delete-orphan")

class Cliente(Base):
    __tablename__ = "clientes"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String(120), nullable=False)
    cpf = Column(String(20), nullable=False)
    telefone = Column(String(30), nullable=False)
    email = Column(String(120), nullable=False)
    advogado_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    criado_em = Column(DateTime, default=datetime.utcnow)

    advogado = relationship("Usuario", back_populates="clientes")
    processos = relationship("Processo", back_populates="cliente", cascade="all, delete-orphan")

class Processo(Base):
    __tablename__ = "processos"

    id = Column(Integer, primary_key=True, index=True)
    numero_processo = Column(String(30), unique=True, index=True, nullable=False)
    descricao = Column(Text, nullable=False)
    status = Column(String(50), nullable=False)
    cliente_id = Column(Integer, ForeignKey("clientes.id"), nullable=False)
    advogado_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    tribunal = Column(String(50), nullable=True)
    classe_processual = Column(String(100), nullable=True)
    orgao_julgador = Column(String(150), nullable=True)
    data_ajuizamento = Column(DateTime, nullable=True)
    criado_em = Column(DateTime, default=datetime.utcnow)

    cliente = relationship("Cliente", back_populates="processos")
    advogado = relationship("Usuario", back_populates="processos")
    historicos = relationship("HistoricoProcesso", back_populates="processo", cascade="all, delete-orphan")

class HistoricoProcesso(Base):
    __tablename__ = "historicos_processos"

    id = Column(Integer, primary_key=True, index=True)
    processo_id = Column(Integer, ForeignKey("processos.id"), nullable=False)
    data_hora = Column(DateTime, default=datetime.utcnow)
    origem = Column(String(30), nullable=False, default="Manual")
    nome_movimento = Column(String(150), nullable=False)
    descricao_detalhada = Column(Text, nullable=True)

    processo = relationship("Processo", back_populates="historicos")

class Agendamento(Base):
    __tablename__ = "agendamentos"

    id = Column(Integer, primary_key=True, index=True)
    titulo = Column(String(150), nullable=False)
    descricao = Column(Text, nullable=False)
    data_hora = Column(DateTime, nullable=False)
    advogado_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    cliente_id = Column(Integer, ForeignKey("clientes.id"), nullable=True)
    ata_reuniao = Column(Text, nullable=True)
    criado_em = Column(DateTime, default=datetime.utcnow)

    advogado = relationship("Usuario", back_populates="agendamentos")
    cliente = relationship("Cliente")
