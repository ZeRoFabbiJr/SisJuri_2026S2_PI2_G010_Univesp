# 🚀 Guia Prático de Execução Local (Uvicorn, http.server e Docker Compose)

Este guia prático fornece as instruções passo a passo para executar o **Sistema Web de Gerenciamento para Escritório de Advocacia** em seu ambiente de desenvolvimento local utilizando duas abordagens distintas:

1. **Execução Local Nativa**: Servidor de API FastAPI via `uvicorn` + Servidor Web de arquivos estáticos via `python -m http.server` + Banco SQLite local.
2. **Execução Containerizada via Docker Compose**: Orquestração completa de contêineres para PostgreSQL 15, Backend FastAPI e Frontend Nginx.

---

## 📋 Sumário
1. [Pré-requisitos do Sistema](#1-pré-requisitos-do-sistema)
2. [Opção 1: Execução Local Nativa (Uvicorn + http.server)](#2-opção-1-execução-local-nativa-uvicorn--httpserver)
   - [2.1. Configuração do Ambiente Virtual Python](#21-configuração-do-ambiente-virtual-python)
   - [2.2. Executando o Backend (API FastAPI)](#22-executando-o-backend-api-fastapi)
   - [2.3. Executando o Frontend (Servidor HTTP Python)](#23-executando-o-frontend-servidor-http-python)
   - [2.4. Acesso e Credenciais de Teste](#24-acesso-e-credenciais-de-teste)
3. [Opção 2: Execução Containerizada (Docker Compose)](#3-opção-2-execução-containerizada-docker-compose)
   - [3.1. Estrutura e Serviços do Docker Compose](#31-estrutura-e-serviços-do-docker-compose)
   - [3.2. Subindo a Aplicação Completamente](#32-subindo-a-aplicação-completamente)
   - [3.3. Monitoramento de Logs e Status](#33-monitoramento-de-logs-e-status)
   - [3.4. Parando e Resetando os Serviços](#34-parando-e-resetando-os-serviços)
4. [Resolução de Problemas Comuns (Troubleshooting)](#4-resolução-de-problemas-comuns-troubleshooting)

---

## 1. Pré-requisitos do Sistema

Dependendo do modo de execução escolhido, certifique-se de ter os seguintes softwares instalados:

* **Para Execução Nativa**:
  * **Python 3.10+** (recomendado Python 3.12).
  * Gerenciador de pacotes **pip** e módulo `venv`.
  * Navegador Web moderno (Google Chrome, Microsoft Edge ou Firefox).

* **Para Execução via Docker**:
  * **Docker Desktop** (Windows / macOS) ou **Docker Engine + Docker Compose V2** (Linux).

---

## 2. Opção 1: Execução Local Nativa (Uvicorn + http.server)

Nesta opção, o backend utiliza banco de dados **SQLite** automático (`sistema_juridico.db`), dispensando a instalação prévia de um servidor PostgreSQL externo.

```text
 ┌──────────────────────────────────┐        GET / POST (JWT)        ┌─────────────────────────────────┐
 │   Navegador Web                  ├───────────────────────────────►│  Backend FastAPI                │
 │   http://127.0.0.1:8080          │                                │  http://127.0.0.1:8000          │
 └─────────────────┬────────────────┘                                └────────────────┬────────────────┘
                   │ Servido via                                                      │
                   ▼                                                                  ▼
 ┌──────────────────────────────────┐                                ┌─────────────────────────────────┐
 │ Python http.server               │                                │ SQLite local                    │
 │ (Pasta FrontEnd)                 │                                │ (sistema_juridico.db)           │
 └──────────────────────────────────┘                                └─────────────────────────────────┘
```

### 2.1. Configuração do Ambiente Virtual Python

Abra o terminal na pasta raiz do projeto:

```bash
# 1. Criar o ambiente virtual isolado
python -m venv venv

# 2. Ativar o ambiente virtual:
# No Windows (PowerShell):
.\venv\Scripts\activate

# No Windows (Prompt de Comando CMD):
.\venv\Scripts\activate.bat

# No Linux ou macOS:
source venv/bin/activate
```

---

### 2.2. Executando o Backend (API FastAPI)

Com o ambiente virtual ativado:

```bash
# 1. Instalar as dependências do projeto
pip install -r BackEnd/requirements.txt

# 2. Navegar até a pasta do backend
cd BackEnd

# 3. Iniciar o servidor Uvicorn com suporte a auto-reload
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

> **📌 Nota de Execução**: O servidor iniciará em `http://127.0.0.1:8000`. As tabelas SQLite e as contas padrão de teste serão criadas automaticamente no primeiro startup. A documentação interativa OpenAPI (Swagger) estará disponível em `http://127.0.0.1:8000/docs`.

---

### 2.3. Executando o Frontend (Servidor HTTP Python)

Abra um **segundo terminal** (mantenha o terminal do backend rodando):

```bash
# 1. Navegar até a pasta do frontend
cd FrontEnd

# 2. Iniciar o servidor HTTP nativo do Python na porta 8080
python -m http.server 8080
```

---

### 2.4. Acesso e Credenciais de Teste

1. Abra seu navegador e acesse: **`http://127.0.0.1:8080`**
2. Utilize uma das contas pré-cadastradas para realizar o login:

| Perfil | E-mail de Acesso | Senha Padrão | Funcionalidades Principais |
| :--- | :--- | :--- | :--- |
| **Master** | `master@escritorio.com` | `123456` | Acesso total, cadastro e ativação/desativação de advogados. |
| **Advogado** | `joao@escritorio.com` | `123456` | Gestão de seus próprios clientes, processos e agenda. |
| **Advogada** | `rafaela@escritorio.com` | `123456` | Gestão de seus próprios clientes, processos e agenda. |

---

## 3. Opção 2: Execução Containerizada (Docker Compose)

Esta abordagem sobe todo o ecossistema da aplicação em contêineres isolados rodando **PostgreSQL 15**, **FastAPI** e **Nginx**.

```text
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │ DOCKER COMPOSE NETWORK (sistema-network)                                               │
 │                                                                                        │
 │  ┌─────────────────────────┐     /api/     ┌─────────────────────────┐                 │
 │  │ Frontend Nginx          ├──────────────►│ Backend FastAPI         │                 │
 │  │ (Porta Externa: 8080)   │               │ (Porta Externa: 8000)   │                 │
 │  └─────────────────────────┘               └────────────┬────────────┘                 │
 │                                                         │                              │
 │                                                         ▼                              │
 │                                            ┌─────────────────────────┐                 │
 │                                            │ PostgreSQL 15           │                 │
 │                                            │ (Volume: postgres_data) │                 │
 │                                            └─────────────────────────┘                 │
 └────────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.1. Estrutura do `docker-compose.yml`

Certifique-se de que o arquivo `docker-compose.yml` esteja na raiz do projeto:

```yaml
version: '3.8'

services:
  # 1. Banco de Dados PostgreSQL
  db:
    image: postgres:15-alpine
    container_name: sistema_juridico_db
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: senha_segura_123
      POSTGRES_DB: sistema_juridico
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d sistema_juridico"]
      interval: 5s
      timeout: 5s
      retries: 5

  # 2. Backend FastAPI
  backend:
    build:
      context: ./BackEnd
      dockerfile: Dockerfile
    container_name: sistema_juridico_backend
    restart: always
    environment:
      - DATABASE_URL=postgresql://postgres:senha_segura_123@sistema_juridico_db:5432/sistema_juridico
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy

  # 3. Frontend Nginx
  frontend:
    build:
      context: ./FrontEnd
      dockerfile: Dockerfile
    container_name: sistema_juridico_frontend
    restart: always
    ports:
      - "8080:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

---

### 3.2. Subindo a Aplicação Completamente

Na pasta raiz do projeto onde está o `docker-compose.yml`:

```bash
# 1. Compilar as imagens e inicializar os contêineres em segundo plano (-d)
docker-compose up -d --build
```

---

### 3.3. Monitoramento de Logs e Status

```bash
# Verificar se os 3 contêineres estão em execução (State: Up / Healthy)
docker-compose ps

# Acompanhar os logs do Backend FastAPI em tempo real
docker-compose logs -f backend

# Acompanhar os logs do Banco de Dados PostgreSQL
docker-compose logs -f db
```

---

### 3.4. Parando e Resetando os Serviços

```bash
# Parar os contêineres mantendo os dados do banco intactos
docker-compose down

# Parar e remover volumes (Útil para redefinir o banco do zero)
docker-compose down -v
```

---

## 4. Resolução de Problemas Comuns (Troubleshooting)

### ⚠️ Erro: `Port 8000 or 8080 is already in use`
* **Causa**: Outra aplicação ou uma instância anterior do Python/Uvicorn está ocupando a porta.
* **Solução**: 
  * No Windows: Execute `netstat -ano | findstr :8000` e finalize o processo via `taskkill /PID <PID> /F`.
  * No Linux/macOS: Execute `lsof -i :8000` e encerre com `kill -9 <PID>`.

---

### ⚠️ Erro: `FATAL: password authentication failed for user "postgres"` (Docker)
* **Causa**: O volume do Docker armazenou credenciais de uma execução anterior com senha divergente.
* **Solução**:
  ```bash
  docker-compose down -v
  docker-compose up -d --build
  ```

---

### ⚠️ Erro de Comunicação CORS no Navegador
* **Causa**: A aplicação cliente não consegue alcançar a porta `8000` da API.
* **Solução**: Caso utilize o `http.server` em uma porta customizada (ex: `8085`), clique na notificação de alteração de porta na tela do sistema ou ajuste o valor da chave `api_port` no `localStorage` do navegador.

---

*Guia elaborado para o Sistema Web de Gerenciamento para Escritório de Advocacia.*
