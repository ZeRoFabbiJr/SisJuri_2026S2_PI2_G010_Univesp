# Guia de Configuração HTTPS (SSL/TLS) para Nginx no Docker

Este guia instrui como configurar certificados SSL no Nginx para o **Sistema Jurídico de Gerenciamento**.

---

## 1. Estrutura de Diretórios com SSL

```text
meu-projeto/
├── docker-compose.yml
├── backend/
│   ├── Dockerfile
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   └── requirements.txt
└── frontend/
    ├── Dockerfile
    ├── nginx.conf
    ├── index.html
    ├── style.css
    ├── app.js
    └── certs/                 <-- Pasta para os certificados SSL
        ├── fullchain.pem
        └── privkey.pem
```

---

## 2. Gerando Certificados SSL Autoassinados (Para Desenvolvimento Local)

Para testar localmente com HTTPS, gere um certificado autoassinado usando OpenSSL:

```bash
# Cria o diretório de certificados dentro da pasta frontend
mkdir -p frontend/certs

# Gerar a chave privada e o certificado autoassinado de 365 dias
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout frontend/certs/privkey.pem \
  -out frontend/certs/fullchain.pem \
  -subj "/C=BR/ST=SP/L=Campinas/O=EscritorioAdvocacia/CN=localhost"
```

---

## 3. Gerando Certificados Válidos com Let's Encrypt (Para Produção em Domínio Real)

Se o sistema estiver rodando em um servidor público com um domínio configurado (ex: `juridico.seuescritorio.com.br`), você pode obter um certificado gratuito via **Certbot / Let's Encrypt**:

```bash
# Executar o Certbot no servidor hospedeiro
sudo certbot certonly --standalone -d juridico.seuescritorio.com.br

# Copiar os certificados gerados para o projeto
cp /etc/letsencrypt/live/juridico.seuescritorio.com.br/fullchain.pem frontend/certs/
cp /etc/letsencrypt/live/juridico.seuescritorio.com.br/privkey.pem frontend/certs/
```

---

## 4. Testando a Aplicação com HTTPS

Suba o ambiente com o Docker Compose:

```bash
docker-compose up --build -d
```

- **Acesso HTTP (Redireciona automaticamente para HTTPS)**: `http://localhost`
- **Acesso Direto HTTPS**: `https://localhost`
