# 🔐 Guia Prático: Criação e Configuração de Certificados SSL/TLS para Nginx

Este guia prático ensina como gerar e configurar certificados digitais **SSL/TLS** para o **Nginx**, cobrindo desde o desenvolvimento local com certificados autoassinados até a produção automatizada na nuvem com **Let's Encrypt**, **Docker Compose** e **Kubernetes**.

---

## 📋 Sumário
1. [Conceitos Básicos de SSL/TLS no Nginx](#1-conceitos-básicos-de-ssltls-no-nginx)
2. [Cenário 1: Desenvolvimento Local (Certificados Autoassinados via OpenSSL)](#2-cenário-1-desenvolvimento-local-certificados-autoassinados-via-openssl)
3. [Cenário 2: Produção em Servidor VPS/Linux (Certbot & Let's Encrypt)](#3-cenário-2-produção-em-servidor-vpslinux-certbot--lets-encrypt)
4. [Cenário 3: Produção Containerizada com Docker Compose](#4-cenário-3-produção-containerizada-com-docker-compose)
5. [Cenário 4: Orquestração no Kubernetes com Cert-Manager](#5-cenário-4-orquestração-no-kubernetes-com-cert-manager)
6. [Hardening e Boas Práticas de Segurança SSL/TLS no Nginx](#6-hardening-e-boas-práticas-de-segurança-ssltls-no-nginx)

---

## 1. Conceitos Básicos de SSL/TLS no Nginx

Para habilitar conexões seguras **HTTPS (Porta 443)**, o Nginx necessita de dois arquivos principais:

* **Chave Privada (`.key`)**: Utilizada pelo servidor para descriptografar as conexões dos clientes. Deve ser mantida em sigilo absoluto.
* **Certificado Público / Cadeia (`.crt`, `.pem` ou `fullchain.pem`)**: Contém a chave pública do servidor e a assinatura da Autoridade Certificadora (CA). É enviado ao navegador do usuário para validar a identidade do site.

---

## 2. Cenário 1: Desenvolvimento Local (Certificados Autoassinados via OpenSSL)

Em ambientes de testes locais (ex: `localhost` ou `127.0.0.1`), você pode gerar um certificado assinado por você mesmo usando o utilitário **OpenSSL**.

### 2.1. Gerando a Chave Privada e o Certificado
Abra o terminal e execute o comando:

```bash
# Criar diretório para os certificados
mkdir -p /etc/nginx/ssl

# Gerar chave RSA 2048-bit e certificado válido por 365 dias
openssl req -x509 -nodes -days 365 -newkey rsa:2048   -keyout /etc/nginx/ssl/nginx-selfsigned.key   -out /etc/nginx/ssl/nginx-selfsigned.crt   -subj "/CN=localhost/O=Escritorio Advocacia/C=BR"
```

### 2.2. Configurando o Nginx para Usar o Certificado Local
No arquivo de configuração do Nginx (`nginx.conf` ou `/etc/nginx/conf.d/default.conf`):

```nginx
server {
    listen 80;
    server_name localhost;
    return 301 https://$host$request_uri; # Redireciona HTTP para HTTPS
}

server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

> **📌 Nota de Uso Local**: Ao acessar `https://localhost` no navegador, será exibido o aviso *"Sua conexão não é privada"* porque o certificado foi autoassinado. Clique em **"Avançado" > "Continuar para localhost"** para prosseguir.

---

## 3. Cenário 2: Produção em Servidor VPS/Linux (Certbot & Let's Encrypt)

Para domínios públicos válidos (ex: `sistema.escritorio.com.br`), o **Let's Encrypt** fornece certificados SSL/TLS reconhecidos por todos os navegadores gratuitamente.

### 3.1. Instalando o Certbot
Em servidores Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
```

### 3.2. Gerando e Configurando o Certificado Automático
Certifique-se de que as portas **80 (HTTP)** e **443 (HTTPS)** estejam abertas no firewall e execute:

```bash
sudo certbot --nginx -d sistema.escritorio.com.br
```

O Certbot irá:
1. Validar a propriedade do domínio via desafio HTTP-01.
2. Baixar os certificados para `/etc/letsencrypt/live/sistema.escritorio.com.br/`.
3. Injetar a configuração SSL automaticamente no Nginx.

### 3.3. Testando a Renovação Automática
Os certificados do Let's Encrypt valem por 90 dias. O Certbot configura um timer automático no sistema. Para testar a renovação:

```bash
sudo certbot renew --dry-run
```

---

## 4. Cenário 3: Produção Containerizada com Docker Compose

Para rodar o Nginx em contêiner com suporte a certificados automáticos do Certbot:

### 4.1. Estrutura do `docker-compose.yml`

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: sistema_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    restart: always

  certbot:
    image: certbot/certbot
    container_name: sistema_certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while true; do certbot renew; sleep 12d & wait $${!}; done;'"
```

### 4.2. Bloco Nginx para Validação do Desafio ACME (`nginx.conf`)

```nginx
server {
    listen 80;
    server_name sistema.escritorio.com.br;

    # Desafio de validação do Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name sistema.escritorio.com.br;

    ssl_certificate /etc/letsencrypt/live/sistema.escritorio.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sistema.escritorio.com.br/privkey.pem;

    location / {
        proxy_pass http://sistema_frontend:80;
    }

    location /api/ {
        proxy_pass http://sistema_backend:8000/api/;
    }
}
```

### 4.3. Comando de Emissão do Certificado Inicial

```bash
docker-compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot   -d sistema.escritorio.com.br --email admin@escritorio.com --agree-tos --no-eff-email
```

---

## 5. Cenário 4: Orquestração no Kubernetes com Cert-Manager

Em um cluster Kubernetes (ex: AWS EKS), a emissão de certificados é automatizada usando o **Cert-Manager** e o **Nginx Ingress Controller**.

### 5.1. Instalando o Cert-Manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

### 5.2. Criando o `ClusterIssuer` (Let's Encrypt)
Crie o arquivo `cluster-issuer.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@escritorio.com
    privateKeySecretRef:
      name: letsencrypt-prod-account-key
    solvers:
      - http01:
          ingress:
            class: nginx
```

### 5.3. Anotando o Ingress Kubernetes (`ingress.yaml`)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sistema-juridico-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
    - hosts:
        - sistema.escritorio.com.br
      secretName: sistema-juridico-tls-secret
  rules:
    - host: sistema.escritorio.com.br
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: backend-service
                port:
                  number: 8000
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-service
                port:
                  number: 80
```

---

## 6. Hardening e Boas Práticas de Segurança SSL/TLS no Nginx

Para obter uma nota **A+** nos testes de SSL (ex: *Qualys SSL Labs*), adicione os seguintes parâmetros de segurança ao bloco `server` do seu Nginx:

```nginx
# 1. Gerar parâmetros Diffie-Hellman para troca segura de chaves:
# Comando CLI: openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
ssl_dhparam /etc/nginx/ssl/dhparam.pem;

# 2. Restringir protocolos a versões seguras (Desativar SSLv3, TLS 1.0 e TLS 1.1)
ssl_protocols TLSv1.2 TLSv1.3;

# 3. Ciphers seguros recomendados
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers on;

# 4. Cache de sessão SSL para melhorar performance
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;

# 5. HSTS (HTTP Strict Transport Security) - Força HTTPS no navegador
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

# 6. Cabeçalhos de proteção adicional
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

---

*Guia elaborado para o Sistema Web de Gerenciamento para Escritório de Advocacia.*
