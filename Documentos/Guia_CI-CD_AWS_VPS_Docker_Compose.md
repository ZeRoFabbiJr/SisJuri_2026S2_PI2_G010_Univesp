# 🚀 Guia de CI/CD e Implantação com Docker Compose em VPS AWS (EC2 / Lightsail)

Este guia fornece o passo a passo completo para configurar, automatizar e implantar em produção o **Sistema Web de Gerenciamento para Escritório de Advocacia** em um servidor VPS na Amazon Web Services (AWS EC2 ou AWS Lightsail) utilizando **Docker Compose**, **Nginx**, **Let's Encrypt (SSL/HTTPS)** e **GitHub Actions**.

---

## 📋 Sumário
1. [Visão Geral da Arquitetura em VPS](#1-visão-geral-da-arquitetura-em-vps)
2. [Provisionamento e Preparação da VPS AWS](#2-provisionamento-e-preparação-da-vps-aws)
3. [Estrutura do Projeto e Arquivos Docker](#3-estrutura-do-projeto-e-arquivos-docker)
4. [Configuração do Nginx como Reverse Proxy e SSL com Certbot](#4-configuração-do-nginx-como-reverse-proxy-e-ssl-com-certbot)
5. [Automação CI/CD com GitHub Actions via SSH](#5-automação-cicd-com-github-actions-via-ssh)
6. [Estratégia de Backup Automatizado do PostgreSQL](#6-estratégia-de-backup-automatizado-do-postgresql)
7. [Comandos de Operação e Monitoramento](#7-comandos-de-operação-e-monitoramento)

---

## 1. Visão Geral da Arquitetura em VPS

Nesta arquitetura de baixo custo e alta eficiência para pequenas e médias instâncias (ex: AWS EC2 `t3.small` ou Lightsail 2GB RAM):

```text
                                  [ Internet / Usuários ]
                                             │
                                   HTTP (80) │ HTTPS (443)
                                             ▼
                        ┌──────────────────────────────────────────┐
                        │      AWS Security Group / Firewall       │
                        └────────────────────┬─────────────────────┘
                                             │
                                             ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ Servidor VPS Ubuntu (AWS EC2 / Lightsail)                                              │
│                                                                                        │
│   ┌────────────────────────────────────────────────────────────────────────────────┐   │
│   │ Docker Compose Network (sistema-network)                                      │   │
│   │                                                                                │   │
│   │   ┌───────────────────────────┐      /api/      ┌──────────────────────────┐   │   │
│   │   │ Container Frontend Nginx  ├────────────────►│ Container Backend        │   │   │
│   │   │ (Portas 80 / 443 -> SSL)  │                 │ (FastAPI / Uvicorn :8000)│   │   │
│   │   └─────────────┬─────────────┘                 └────────────┬─────────────┘   │   │
│   │                 │ Arquivos                                   │                 │   │
│   │                 │ Estáticos                                  │ SQL             │   │
│   │                 ▼                                            ▼                 │   │
│   │   ┌───────────────────────────┐                 ┌──────────────────────────┐   │   │
│   │   │ HTML5 / CSS3 / JS         │                 │ Container PostgreSQL 15  │   │   │
│   │   └───────────────────────────┘                 │ (Porta 5432)             │   │   │
│   │                                                 └────────────┬─────────────┘   │   │
│   └──────────────────────────────────────────────────────────────┼─────────────────┘   │
│                                                                  │ Volume Persistente  │
│                                                                  ▼                     │
│                                                     ┌──────────────────────────┐       │
│                                                     │ Volume Docker            │       │
│                                                     │ (postgres_data)          │       │
│                                                     └──────────────────────────┘       │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Provisionamento e Preparação da VPS AWS

### 2.1. Criar a Instância na AWS (EC2 ou Lightsail)
1. **Sistema Operacional**: Ubuntu 22.04 LTS (ou 24.04 LTS).
2. **Tipo de Instância**: `t3.small` (2 vCPU, 2GB RAM) ou equivalente no Lightsail.
3. **Endereço IP**: Aloque um **Elastic IP** (EC2) ou **Static IP** (Lightsail) e vincule à instância para que o IP público não mude ao reiniciar.

### 2.2. Configurar o Security Group / Firewall
Liberar as seguintes portas de entrada (Inbound Rules):
* **Porta 22 (SSH)**: Restrita ao seu IP de administração.
* **Porta 80 (HTTP)**: Aberta ao público (`0.0.0.0/0`).
* **Porta 443 (HTTPS)**: Aberta ao público (`0.0.0.0/0`).

### 2.3. Instalação do Docker e Docker Compose na VPS
Acesse a VPS via SSH (`ssh -i sua-chave.pem ubuntu@IP_PUBLICO_AWS`) e execute o script de instalação:

```bash
# 1. Atualizar o sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependências básicas
sudo apt install -y ca-certificates curl gnupg lsb-release git unzip

# 3. Adicionar chave oficial do Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Adicionar repositório do Docker
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Instalar Docker Engine e Plugin Compose
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 6. Adicionar usuário ubuntu ao grupo docker
sudo usermod -aG docker $USER
newgrp docker

# 7. Testar instalação
docker compose version
```

---

## 3. Estrutura do Projeto e Arquivos Docker

No servidor VPS, crie o diretório de implantação `/var/www/sistema-juridico`:

```bash
sudo mkdir -p /var/www/sistema-juridico
sudo chown -R $USER:$USER /var/www/sistema-juridico
cd /var/www/sistema-juridico
```

### 3.1. Arquivo `docker-compose.yml` (Produção)
Crie o arquivo `/var/www/sistema-juridico/docker-compose.yml`:

```yaml
version: '3.8'

services:
  # 1. BANCO DE DADOS POSTGRESQL
  db:
    image: postgres:15-alpine
    container_name: sistema_juridico_db
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-senha_segura_prod_2026}
      POSTGRES_DB: ${POSTGRES_DB:-sistema_juridico}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - sistema-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-sistema_juridico}"]
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
      - DATABASE_URL=postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-senha_segura_prod_2026}@db:5432/${POSTGRES_DB:-sistema_juridico}
      - SECRET_KEY=${SECRET_KEY:-chave_jwt_super_secreta_escritorio_2026}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - sistema-network

  # 3. FRONTEND NGINX (REVERSE PROXY)
  frontend:
    build:
      context: ./FrontEnd
      dockerfile: Dockerfile
    container_name: sistema_juridico_frontend
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    depends_on:
      - backend
    networks:
      - sistema-network

networks:
  sistema-network:
    driver: bridge

volumes:
  postgres_data:
```

### 3.2. Arquivo `.env` na VPS
Crie o arquivo de variáveis de ambiente sensíveis `/var/www/sistema-juridico/.env`:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=SuaSenhaForteProducao2026!
POSTGRES_DB=sistema_juridico
SECRET_KEY=ChaveJwtMuitoSeguraGeradaParaProd2026
```

---

## 4. Configuração do Nginx como Reverse Proxy e SSL com Certbot

### 4.1. Arquivo de Configuração do Nginx (`FrontEnd/nginx.conf`)
Crie o arquivo `nginx.conf` dentro do diretório `FrontEnd/`:

```nginx
server {
    listen 80;
    server_name seu-dominio.com.br www.seu-dominio.com.br;

    # Validação do Certbot para SSL
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # Redirecionamento HTTP -> HTTPS
    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name seu-dominio.com.br www.seu-dominio.com.br;

    ssl_certificate /etc/letsencrypt/live/seu-dominio.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/seu-dominio.com.br/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Servir Arquivos Estáticos do Frontend
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # Redirecionar Chamadas de API para o Backend FastAPI
    location /api/ {
        proxy_pass http://backend:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 4.2. Gerar Certificado SSL Gratuito com Let's Encrypt
Rode o Certbot via Docker uma única vez para emitir os certificados HTTPS:

```bash
# 1. Criar pastas de certificados
mkdir -p certbot/conf certbot/www

# 2. Executar Certbot
docker run -it --rm --name certbot   -v "$(pwd)/certbot/conf:/etc/letsencrypt"   -v "$(pwd)/certbot/www:/var/www/certbot"   certbot/certbot certonly --webroot   -w /var/www/certbot   -d seu-dominio.com.br -d www.seu-dominio.com.br   --email seu-email@escritorio.com --agree-tos --no-eff-email
```

---

## 5. Automação CI/CD com GitHub Actions via SSH

O pipeline do GitHub Actions compila, testa e se conecta com segurança à sua VPS AWS via SSH para executar a atualização automática do sistema sem necessidade de intervenção manual.

### 5.1. Criar o Workflow (`.github/workflows/deploy-vps.yml`)

```yaml
name: Deploy para VPS AWS com Docker Compose

on:
  push:
    branches:
      - main
      - master

jobs:
  deploy:
    name: Build & Deploy na VPS AWS
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do Repositório
        uses: actions/checkout@v4

      - name: Executar Deploy via SSH na VPS AWS
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          port: 22
          script: |
            cd /var/www/sistema-juridico
            
            # 1. Atualizar o código-fonte via Git
            git pull origin main
            
            # 2. Reconstruir as imagens e atualizar os contêineres
            docker compose up -d --build --remove-orphans
            
            # 3. Limpar imagens antigas não utilizadas
            docker image prune -f
            
            # 4. Exibir status dos serviços
            docker compose ps
```

### 5.2. Configurar os Secrets no Repositório GitHub
No seu repositório no GitHub, acesse **Settings > Secrets and variables > Actions > New repository secret** e cadastre:

| Nome do Secret | Descrição / Valor |
| :--- | :--- |
| **`VPS_HOST`** | IP Público Estático (Elastic IP) da sua instância EC2 ou Lightsail. |
| **`VPS_USERNAME`** | Usuário de acesso SSH (padrão: `ubuntu`). |
| **`VPS_SSH_KEY`** | Conteúdo completo da chave privada SSH (`.pem`) utilizada para acessar a VPS. |

---

## 6. Estratégia de Backup Automatizado do PostgreSQL

Para garantir a proteção de dados do escritório, configure uma rotina de backup diário com envio compactado utilizando o `cron` do sistema operacional:

### 6.1. Script de Backup (`/var/www/sistema-juridico/backup.sh`)
Crie o script:

```bash
#!/bin/bash
BACKUP_DIR="/var/www/sistema-juridico/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz"

mkdir -p $BACKUP_DIR

# Executa pg_dump dentro do container
docker exec -t sistema_juridico_db pg_dump -U postgres sistema_juridico | gzip > $BACKUP_FILE

# Remove backups com mais de 30 dias
find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +30 -delete

echo "Backup concluído com sucesso: $BACKUP_FILE"
```

Dê permissão de execução:
```bash
chmod +x /var/www/sistema-juridico/backup.sh
```

### 6.2. Agendar no Crontab (Todos os dias às 03:00)
```bash
crontab -e
```
Adicione a linha:
```cron
0 3 * * * /var/www/sistema-juridico/backup.sh >> /var/www/sistema-juridico/backups/backup.log 2>&1
```

---

## 7. Comandos de Operação e Monitoramento

Useful CLI commands para gerenciar a aplicação em produção:

* **Verificar status dos serviços**:
  ```bash
  docker compose ps
  ```
* **Acompanhar logs em tempo real**:
  ```bash
  docker compose logs -f --tail=100
  ```
* **Reiniciar aplicação**:
  ```bash
  docker compose restart
  ```
* **Verificar uso de memória e CPU**:
  ```bash
  docker stats
  ```
* **Forçar recriação de contêineres**:
  ```bash
  docker compose up -d --force-recreate
  ```

---

*Guia elaborado para o Sistema Web de Gerenciamento para Escritório de Advocacia.*
