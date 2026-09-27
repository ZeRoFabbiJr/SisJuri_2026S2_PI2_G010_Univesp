# 🚀 Guia de CI/CD e Implantação com Docker Compose na VPS Hostinger

Este guia apresenta o passo a passo completo para configurar, implantar e automatizar o deploy do **Sistema Web de Gerenciamento para Escritório de Advocacia** em uma **VPS KVM da Hostinger** utilizando **Docker Compose**, **Nginx**, **Certbot (SSL HTTPS)** e **GitHub Actions**.

---

## 📋 Sumário
1. [Visão Geral da Arquitetura na Hostinger](#1-visão-geral-da-arquitetura-na-hostinger)
2. [Preparação e Configuração da VPS Hostinger](#2-preparação-e-configuração-da-vps-hostinger)
3. [Instalação do Docker e Docker Compose](#3-instalação-do-docker-e-docker-compose)
4. [Estrutura do Projeto e Docker Compose em Produção](#4-estrutura-do-projeto-e-docker-compose-em-produção)
5. [Configuração do Nginx e SSL Gratuito (Let's Encrypt)](#5-configuração-do-nginx-e-ssl-gratuito-lets-encrypt)
6. [Pipeline de CI/CD com GitHub Actions (Deploy Automático via SSH)](#6-pipeline-de-cicd-com-github-actions-deploy-automático-via-ssh)
7. [Rotina Automatizada de Backup do PostgreSQL](#7-rotina-automatizada-de-backup-do-postgresql)
8. [Comandos de Operação e Manutenção](#8-comandos-de-operação-e-manutenção)

---

## 1. Visão Geral da Arquitetura na Hostinger

```text
                               ┌─────────────────────────────────────────┐
                               │        Usuário / Navegador Web          │
                               └────────────────────┬────────────────────┘
                                                    │ HTTPS (Porta 443)
                                                    ▼
                               ┌─────────────────────────────────────────┐
                               │     Hostinger VPS (Ubuntu 22.04 LTS)    │
                               │  Reverse Proxy: Nginx + Certbot (SSL)   │
                               └────────────────────┬────────────────────┘
                                                    │
                                                    ▼  Rede Interna Docker (sistema-network)
                        ┌───────────────────────────┴───────────────────────────┐
                        │                                                       │
                        ▼                                                       ▼
  ┌───────────────────────────────────────────┐           ┌───────────────────────────────────────────┐
  │ Contêiner Frontend (Nginx Estático)       │           │ Contêiner Backend (FastAPI / Uvicorn)     │
  │ Porta Interna: 80                         │           │ Porta Interna: 8000                       │
  └───────────────────────────────────────────┘           └─────────────────────┬─────────────────────┘
                                                                                │
                                                                                ▼
                                                          ┌───────────────────────────────────────────┐
                                                          │ Contêiner Banco de Dados (PostgreSQL 15)  │
                                                          │ Volume Persistente: postgres_data         │
                                                          └───────────────────────────────────────────┘
```

---

## 2. Preparação e Configuração da VPS Hostinger

### 2.1. Acessar o Painel Hostinger (hPanel)
1. Acesse o **hPanel da Hostinger** (`https://hpanel.hostinger.com`).
2. Vá na seção **VPS** e selecione o seu servidor (ex: *KVM 1, KVM 2 ou superior* com **Ubuntu 22.04 64bit**).
3. Anote o **IP Público da VPS** fornecido no painel.

### 2.2. Configurar Firewall no hPanel
No menu **Firewall** do hPanel, crie um perfil de regras de firewall liberando as seguintes portas de entrada:
* **Porta 22 (SSH)**: Acesso remoto ao terminal.
* **Porta 80 (HTTP)**: Tráfego web inicial e validação Let's Encrypt.
* **Porta 443 (HTTPS)**: Tráfego web seguro e criptografado.

### 2.3. Configurar Chave SSH para Acesso Seguro
No seu computador local, gere uma chave SSH (se ainda não tiver):
```bash
ssh-keygen -t ed25519 -C "seu-email@dominio.com"
```

Copie a chave pública para a VPS Hostinger através do hPanel (**VPS > Configurações de SSH > Adicionar chave SSH**) ou via terminal:
```bash
ssh-copy-id root@IP_DA_SUA_VPS_HOSTINGER
```

Acesse a VPS via terminal:
```bash
ssh root@IP_DA_SUA_VPS_HOSTINGER
```

---

## 3. Instalação do Docker e Docker Compose

Na VPS Hostinger, execute os comandos abaixo para atualizar o sistema e instalar a versão oficial do **Docker Engine** e **Docker Compose V2**:

```bash
# 1. Atualizar repositórios e pacotes do sistema
apt update && apt upgrade -y

# 2. Instalar dependências essenciais
apt install -y curl ca-certificates curl gnupg lsb-release git unzip htop

# 3. Adicionar a chave GPG oficial do Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Adicionar o repositório do Docker
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Instalar o Docker Engine, CLI e Plugin Compose
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 6. Habilitar inicialização automática do Docker
systemctl enable docker
systemctl start docker

# 7. Validar instalações
docker --version
docker compose version
```

---

## 4. Estrutura do Projeto e Docker Compose em Produção

### 4.1. Clonar o Repositório na VPS
Crie o diretório do projeto em `/var/www/sistema-juridico`:

```bash
mkdir -p /var/www
cd /var/www
git clone https://github.com/seu-usuario/seu-repositorio.git sistema-juridico
cd sistema-juridico
```

### 4.2. Criar o Arquivo de Variáveis de Ambiente (`.env`)
Crie o arquivo `.env` na raiz da pasta na VPS:

```bash
nano /var/www/sistema-juridico/.env
```

Insira o conteúdo ajustado para produção:
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=SenhaHostingerSegura_2026!#
POSTGRES_DB=sistema_juridico
DATABASE_URL=postgresql://postgres:SenhaHostingerSegura_2026!#@db:5432/sistema_juridico
SECRET_KEY=sua_chave_jwt_super_secreta_producao_2026_hostinger
```

### 4.3. Arquivo `docker-compose.yml` de Produção
Garanta que o arquivo `docker-compose.yml` na raiz do projeto esteja configurado conforme abaixo:

```yaml
version: '3.8'

networks:
  sistema-network:
    driver: bridge

volumes:
  postgres_data:
  certbot_etc:
  certbot_var:

services:
  # 1. BANCO DE DADOS POSTGRESQL 15
  db:
    image: postgres:15-alpine
    container_name: sistema_juridico_db
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - sistema-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5

  # 2. BACKEND FASTAPI
  backend:
    build:
      context: ./BackEnd
      dockerfile: Dockerfile
    container_name: sistema_juridico_backend
    restart: always
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - SECRET_KEY=${SECRET_KEY}
    networks:
      - sistema-network
    depends_on:
      db:
        condition: service_healthy

  # 3. FRONTEND NGINX ESTÁTICO
  frontend:
    build:
      context: ./FrontEnd
      dockerfile: Dockerfile
    container_name: sistema_juridico_frontend
    restart: always
    networks:
      - sistema-network
    depends_on:
      - backend

  # 4. PROXY REVERSO NGINX COM SSL (PORTAS 80 E 443)
  proxy:
    image: nginx:alpine
    container_name: sistema_juridico_proxy
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - certbot_etc:/etc/letsencrypt
      - certbot_var:/var/www/certbot
    networks:
      - sistema-network
    depends_on:
      - frontend
      - backend
```

---

## 5. Configuração do Nginx e SSL Gratuito (Let's Encrypt)

### 5.1. Criar o Arquivo `nginx/nginx.conf`
Crie a pasta `nginx` na raiz do projeto e adicione o arquivo de configuração:

```bash
mkdir -p /var/www/sistema-juridico/nginx
nano /var/www/sistema-juridico/nginx/nginx.conf
```

Cole a seguinte configuração:
```nginx
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout 65;

    # Redirecionamento HTTP para HTTPS e validação Certbot
    server {
        listen 80;
        server_name seu-dominio.com.br www.seu-dominio.com.br;

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 301 https://$host$request_uri;
        }
    }

    # Servidor HTTPS Criptografado
    server {
        listen 443 ssl;
        server_name seu-dominio.com.br www.seu-dominio.com.br;

        ssl_certificate /etc/letsencrypt/live/seu-dominio.com.br/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/seu-dominio.com.br/privkey.pem;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # Roteamento da API Backend (FastAPI)
        location /api/ {
            proxy_pass http://backend:8000/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Roteamento da Interface Web Frontend (Nginx Estático)
        location / {
            proxy_pass http://frontend:80/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 5.2. Gerar Certificado SSL com Certbot na VPS
Instale o Certbot na VPS Hostinger para gerar os certificados SSL:

```bash
apt install -y certbot

# Parar temporariamente o container proxy se estiver rodando
certbot certonly --standalone -d seu-dominio.com.br -d www.seu-dominio.com.br --non-interactive --agree-tos -m seu-email@dominio.com
```

### 5.3. Configurar Renovação Automática do SSL no Crontab
```bash
crontab -e
```
Adicione a linha para renovação automática semanal:
```cron
0 3 * * 1 certbot renew --quiet && docker exec sistema_juridico_proxy nginx -s reload
```

---

## 6. Pipeline de CI/CD com GitHub Actions (Deploy Automático via SSH)

O GitHub Actions conectará automaticamente via SSH na sua VPS Hostinger a cada `git push` na branch `main`, realizará o `pull` do código atualizado, construirá as imagens Docker e reiniciará os contêineres sem indisponibilidade perceptível.

### 6.1. Configurar Secrets no Repositório GitHub
Acesse seu repositório no GitHub: **Settings > Secrets and variables > Actions > New repository secret**. Adicione as seguintes chaves:

1. **`HOSTINGER_SSH_HOST`**: O IP público da sua VPS Hostinger.
2. **`HOSTINGER_SSH_USER`**: O usuário do sistema (ex: `root`).
3. **`HOSTINGER_SSH_KEY`**: O conteúdo privado da sua chave SSH (`~/.ssh/id_ed25519`).
4. **`HOSTINGER_SSH_PORT`**: Porta SSH (`22`).

### 6.2. Criar o Workflow `.github/workflows/deploy-hostinger.yml`
No seu projeto local, crie o arquivo do pipeline:

```yaml
name: Deploy Automático na VPS Hostinger

on:
  push:
    branches:
      - main
      - master

jobs:
  deploy:
    name: Build & Deploy via SSH na Hostinger
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do Código
        uses: actions/checkout@v4

      - name: Executar Deploy via SSH na VPS Hostinger
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.HOSTINGER_SSH_HOST }}
          username: ${{ secrets.HOSTINGER_SSH_USER }}
          key: ${{ secrets.HOSTINGER_SSH_KEY }}
          port: ${{ secrets.HOSTINGER_SSH_PORT }}
          script: |
            echo "🚀 Iniciando Deploy na VPS Hostinger..."
            cd /var/www/sistema-juridico
            
            # 1. Atualizar o código do repositório Git
            git fetch --all
            git reset --hard origin/main
            
            # 2. Reconstruir e subir os contêineres Docker
            docker compose down
            docker compose up -d --build --remove-orphans
            
            # 3. Limpar imagens e cache antigos
            docker image prune -f
            
            echo "✅ Deploy concluído com sucesso na Hostinger!"
```

---

## 7. Rotina Automatizada de Backup do PostgreSQL

Para proteger as informações do escritório contra perdas de dados, crie um script de backup automático do PostgreSQL na VPS Hostinger.

### 7.1. Criar o Script de Backup (`/var/www/backup_postgres.sh`)
```bash
nano /var/www/backup_postgres.sh
```

Cole o conteúdo abaixo:
```bash
#!/bin/bash

# Configurações do Backup
BACKUP_DIR="/var/www/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_sistema_juridico_$DATE.sql.gz"

# Criar pasta de backup se não existir
mkdir -p $BACKUP_DIR

# Executar pg_dump dentro do contêiner Docker do PostgreSQL
docker exec -t sistema_juridico_db pg_dump -U postgres sistema_juridico | gzip > $BACKUP_FILE

# Remover backups com mais de 30 dias de criação
find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +30 -delete

echo "Backup executado com sucesso: $BACKUP_FILE"
```

Dê permissão de execução ao script:
```bash
chmod +x /var/www/backup_postgres.sh
```

### 7.2. Agendar Execução Diária no `crontab`
```bash
crontab -e
```
Adicione a instrução para executar o backup todas as madrugadas às 02:00:
```cron
0 2 * * * /var/www/backup_postgres.sh >> /var/log/postgres_backup.log 2>&1
```

---

## 8. Comandos de Operação e Manutenção

Abaixo estão os principais comandos para administrar a aplicação na VPS Hostinger:

* **Iniciar todos os serviços**:
  ```bash
  cd /var/www/sistema-juridico && docker compose up -d
  ```
* **Verificar o status dos contêineres**:
  ```bash
  docker compose ps
  ```
* **Visualizar logs do sistema em tempo real**:
  ```bash
  docker compose logs -f --tail=100
  ```
* **Reiniciar um serviço específico (ex: backend)**:
  ```bash
  docker compose restart backend
  ```
* **Verificar o consumo de memória e CPU da VPS**:
  ```bash
  docker stats
  ```

---
*Guia elaborado para implantação do Sistema Web de Gerenciamento para Escritório de Advocacia.*
