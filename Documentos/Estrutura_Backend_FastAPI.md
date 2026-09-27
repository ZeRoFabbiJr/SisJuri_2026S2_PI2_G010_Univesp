# 🛠️ Documentação da Estrutura e Rotas do Backend (FastAPI)

Este documento apresenta a arquitetura completa, a estrutura de módulos, a modelagem de dados, a segurança e a especificação detalhada de todas as rotas da **API REST do Backend** desenvolvida em **FastAPI** para o **Sistema Web de Gerenciamento para Escritório de Advocacia**.

---

## 📋 Sumário
1. [Visão Geral da Arquitetura do Backend](#1-visão-geral-da-arquitetura-do-backend)
2. [Estrutura de Arquivos e Organização de Módulos](#2-estrutura-de-arquivos-e-organização-de-módulos)
3. [Camada de Dados, Modelos e Segurança (ORM & JWT)](#3-camada-de-dados-modelos-e-segurança-orm--jwt)
4. [Especificação Completa de Rotas e Endpoints REST](#4-especificação-completa-de-rotas-e-endpoints-rest)
   - [4.1. Autenticação e Perfil de Acesso](#41-autenticação-e-perfil-de-acesso)
   - [4.2. Métricas do Dashboard](#42-métricas-do-dashboard)
   - [4.3. Gestão de Usuários e Advogados (Perfil Master)](#43-gestão-de-usuários-e-advogados-perfil-master)
   - [4.4. Gestão de Clientes](#44-gestão-de-clientes)
   - [4.5. Gestão de Processos e Integração CNJ Datajud](#45-gestão-de-processos-e-integração-cnj-datajud)
   - [4.6. Gestão de Agendamentos e Atas de Reunião](#46-gestão-de-agendamentos-e-atas-de-reunião)
5. [Regras de Negócio e Validações de Integridade](#5-regras-de-negócio-e-validações-de-integridade)
6. [Containerização e Deploy com Docker](#6-containerização-e-deploy-com-docker)

---

## 1. Visão Geral da Arquitetura do Backend

O backend foi construído utilizando a biblioteca **FastAPI** em Python 3.12, seguindo o padrão arquitetural **RESTful**. A aplicação implementa um design desacoplado e escalável, utilizando:

* **FastAPI**: Framework assíncrono de altíssima performance com validação automática de dados via Pydantic.
* **SQLAlchemy ORM**: Mapeamento Objeto-Relacional para abstração de banco de dados (suportando **PostgreSQL 15** em produção e **SQLite** para desenvolvimento local).
* **Segurança e Autenticação JWT**: Emissão de tokens de acesso *Bearer JWT* com hashing de senhas utilizando algorítimos criptográficos seguros via `passlib` / `bcrypt`.
* **RBAC (Role-Based Access Control)**: Controle rigoroso de permissões segregando os perfis **Master** (acesso global ao escritório) e **Advogado** (acesso restrito aos seus próprios processos, clientes e agendamentos).
* **Serviço de Integração CNJ Datajud**: Integração via API Pública do Conselho Nacional de Justiça para busca e carga automatizada de andamentos judiciais.

---

## 2. Estrutura de Arquivos e Organização de Módulos

A aplicação backend está organizada no diretório `BackEnd/` conforme a seguinte estrutura modular:

```text
BackEnd/
├── main.py              # Ponto de entrada (Entrypoint), configuração das rotas REST e Middlewares
├── models.py            # Definição das tabelas e relacionamentos do banco de dados (SQLAlchemy)
├── schemas.py           # Contratos de entrada e saída (Modelos Pydantic para validação)
├── database.py          # Configuração da engine de conexão e sessão do banco de dados (SessionLocal)
├── security.py          # Funções utilitárias de hash de senha, token JWT e autenticação
├── cnj_service.py       # Cliente HTTP de comunicação com a API Pública do CNJ Datajud
├── requirements.txt     # Lista de dependências Python (FastAPI, Uvicorn, SQLAlchemy, PyJWT, etc.)
└── Dockerfile           # Multi-stage build para conteinerização em produção
```

---

## 3. Camada de Dados, Modelos e Segurança (ORM & JWT)

### 3.1. Modelos ORM (`models.py`)
* **`Usuario`**: Tabela `usuarios` (`id`, `nome`, `email`, `senha`, `tipo`, `ativo`, `criado_em`).
* **`Cliente`**: Tabela `clientes` (`id`, `nome`, `cpf`, `telefone`, `email`, `advogado_id`, `criado_em`).
* **`Processo`**: Tabela `processos` (`id`, `numero_processo`, `descricao`, `status`, `cliente_id`, `advogado_id`, `tribunal`, `classe_processual`, `orgao_julgador`, `data_ajuizamento`).
* **`HistoricoProcesso`**: Tabela `historicos_processos` (`id`, `processo_id`, `data_hora`, `origem`, `nome_movimento`, `descricao_detalhada`).
* **`Agendamento`**: Tabela `agendamentos` (`id`, `titulo`, `descricao`, `data_hora`, `advogado_id`, `cliente_id`, `ata_reuniao`).

### 3.2. Mecanismo de Injeção de Dependências (`get_current_user`)
Todas as rotas protegidas injetam a dependência `get_current_user`, que:
1. Extrai o token do cabeçalho `Authorization: Bearer <token>`.
2. Valida a assinatura criptográfica e expiração do JWT.
3. Carrega o usuário do banco de dados e verifica se a conta está ativa (`ativo == True`).

---

## 4. Especificação Completa de Rotas e Endpoints REST

### 4.1. Autenticação e Perfil de Acesso

#### `POST /api/login`
Autentica o usuário e retorna o token de acesso JWT.
* **Acesso**: Público.
* **Corpo da Requisição (`schemas.LoginRequest`)**:
  ```json
  {
    "email": "joao@escritorio.com",
    "senha": "123456"
  }
  ```
* **Resposta de Sucesso (`200 OK`)**:
  ```json
  {
    "access_token": "eyJhbGciOi...",
    "token_type": "bearer",
    "id": 2,
    "nome": "João Vitor",
    "email": "joao@escritorio.com",
    "tipo": "advogado"
  }
  ```

#### `PUT /api/usuarios/me`
Permite ao usuário autenticado atualizar suas próprias credenciais (e-mail e/ou senha).
* **Acesso**: Autenticado.
* **Corpo da Requisição (`schemas.PerfilUpdate`)**:
  ```json
  {
    "email": "novo_email@escritorio.com",
    "senha_atual": "123456",
    "nova_senha": "nova_senha_segura"
  }
  ```

---

### 4.2. Métricas do Dashboard

#### `GET /api/dashboard/metrics`
Retorna os contadores do painel principal ajustados ao perfil de quem consulta.
* **Acesso**: Autenticado.
* **Resposta de Sucesso (`200 OK`)**:
  ```json
  {
    "total_advogados": 3,
    "total_clientes": 12,
    "total_processos": 8,
    "total_agendamentos": 5
  }
  ```

---

### 4.3. Gestão de Usuários e Advogados (Perfil Master)

#### `GET /api/usuarios`
Lista todos os usuários ou filtra por tipo (`?tipo=advogado`).
* **Acesso**: Autenticado.

#### `POST /api/usuarios`
Cadastra um novo usuário/advogado no sistema.
* **Acesso**: Exclusivo perfil **Master**.
* **Corpo da Requisição (`schemas.UsuarioCreate`)**:
  ```json
  {
    "nome": "Dra. Rafaela Guimarães",
    "email": "rafaela@escritorio.com",
    "senha": "123456",
    "tipo": "advogado"
  }
  ```

#### `PUT /api/usuarios/{usuario_id}/status`
Ativa ou desativa o acesso de um advogado no escritório.Ao reativar, define a senha padrão temporária `123456`.
* **Acesso**: Exclusivo perfil **Master**.

---

### 4.4. Gestão de Clientes

#### `GET /api/clientes`
Retorna a lista de clientes. Se o usuário for **Master**, retorna todos os clientes do escritório; se for **Advogado**, retorna apenas os seus clientes vinculados.

#### `POST /api/clientes`
Cadastra um novo cliente e vincula ao advogado responsável.

#### `PUT /api/clientes/{cliente_id}`
Atualiza os dados de cadastro de um cliente existente.

#### `DELETE /api/clientes/{cliente_id}`
Remove o registro do cliente.

---

### 4.5. Gestão de Processos e Integração CNJ Datajud

#### `GET /api/processos`
Lista as ações judiciais cadastradas incluindo os metadados do CNJ e a linha do tempo do histórico evolutivo.

#### `POST /api/processos`
Cadastra um novo processo judicial pelo Número Único CNJ (20 dígitos). Dispara automaticamente a consulta à **API Pública do Datajud CNJ**, preenchendo tribunal, classe, órgão julgador e movimentações iniciais.

#### `PUT /api/processos/{proc_id}`
Atualiza os dados do processo.

#### `DELETE /api/processos/{proc_id}`
Exclui a ação judicial e remove em cascata todo o seu histórico de movimentações.

#### `POST /api/processos/{proc_id}/consultar-cnj`
Força uma sincronização sob demanda com o tribunal de origem via API do CNJ, adicionando novos andamentos ao histórico evolutivo.

#### `POST /api/processos/{proc_id}/historico`
Adiciona um andamento manual interno na linha do tempo do processo.

---

### 4.6. Gestão de Agendamentos e Atas de Reunião

#### `GET /api/agendamentos`
Lista compromissos e reuniões. Suporta parâmetros de filtro: `data_inicio`, `data_fim` e `advogado_id`.

#### `POST /api/agendamentos`
Cadastra um novo compromisso na agenda.
* **Validação de Conflito Automatizada**: Bloqueia e retorna erro HTTP 400 se o advogado ou o cliente já possuírem reunião marcada na mesma data e hora.

#### `PUT /api/agendamentos/{agd_id}`
Atualiza data, hora, pauta ou participantes da reunião com revalidação automatizada de choques de agenda.

#### `PUT /api/agendamentos/{agd_id}/ata`
Redige ou atualiza o campo de texto longo da **Ata da Reunião** vinculada ao compromisso.

#### `DELETE /api/agendamentos/{agd_id}`
Cancela e exclui o agendamento da agenda.

---

## 5. Regras de Negócio e Validações de Integridade

1. **Validação de Conflitos de Agenda**:
   * O sistema consulta a tabela `agendamentos` antes de concluir a gravação. Se houver sobreposição exata de `data_hora` + `advogado_id` ou `data_hora` + `cliente_id`, a requisição é rejeitada.
2. **Exclusão de Advogados Próprios**:
   * O perfil Master não pode alterar o próprio status de ativação para evitar o bloqueio acidental da conta administrativa do escritório.
3. **Persistência de Transações do CNJ**:
   * Falhas de rede ou instabilidades na API do CNJ durante a consulta de processos não interrompem o cadastro da ação; os metadados podem ser recuperados posteriormente via endpoint de sincronização.

---

## 6. Containerização e Deploy com Docker

O backend é empacotado através do **`Dockerfile`** em duas etapas (Multi-stage build):

```dockerfile
# Estágio 1: Builder
FROM python:3.12-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Estágio 2: Production Runner
FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . /app
ENV PATH=/root/.local/bin:$PATH
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

---

*Documentação da API Backend gerada para o Sistema Web de Gerenciamento para Escritório de Advocacia.*
