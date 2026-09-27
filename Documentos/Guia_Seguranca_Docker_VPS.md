# Guia de Hardening e Segurança Docker para Implantação em VPS Cloud
**Sistema Web de Gerenciamento para Escritório de Advocacia**

---

## 1. Visão Geral da Arquitetura de Segurança

Este documento detalha as melhorias de segurança de nível de produção (*Hardening*) aplicadas aos containers **Docker**, ao **docker-compose** e às configurações do banco de dados **PostgreSQL** para implantação em uma **VPS (Virtual Private Server)** na nuvem (ex: AWS, DigitalOcean, Hetzner, Linode, Google Cloud).

---

## 2. As 7 Camadas de Proteção Aplicadas

### 🔒 Camada 1: Execução Não-Root (Non-Root User)
* **Backend (`Dockerfile.backend`)**: Criação do grupo `appgroup` e do usuário `appuser` (UID/GID 10001) sem privilégios administrativos. O processo do Uvicorn/FastAPI executa sob a identidade deste usuário restrito.
* **Frontend (`Dockerfile.frontend`)**: Utilização da imagem oficial base `nginxinc/nginx-unprivileged:alpine-slim`, configurada nativamente para executar sem acesso ao usuário root e escutando na porta não-privilegiada `8080`.

### 🛡️ Camada 2: Segmentação de Rede e Isolamento do Banco de Dados
* **Rede Interna Fechada (`backend_net`)**: Configurada no `docker-compose.yml` com a flag `internal: true`. Esta rede conecta apenas o backend e o PostgreSQL e **não possui roteamento para a internet**.
* **Proteção do PostgreSQL**: A porta `5432` do banco de dados **NÃO foi exposta no host** (sem mapeamento em `ports:`). Isso impede que atacantes externos tentem ataques de força bruta diretamente na porta do banco.
* **Rede do Proxy (`frontend_net`)**: Conecta o Nginx ao Backend FastAPI. Apenas a porta pública HTTP/HTTPS (ex: 80/443) é exposta no host.

### 🔑 Camada 3: Proteção de Segredos e Arquivo `.env`
* **Passagem Dinâmica de Variáveis**: Nenhuma senha, token JWT ou chave de API está hardcoded no código ou nos Dockerfiles.
* **Permissões Estritas no Servidor**: Instrução para aplicar `chmod 600 .env` no servidor VPS, garantindo que apenas o usuário proprietário da máquina leia as credenciais.
* **Inclusão no `.gitignore`**: Garantia de que o arquivo `.env` nunca seja versionado no Git.

### 🌐 Camada 4: Cabeçalhos de Segurança HTTP (Security Headers)
Configurados diretamente no `nginx.conf`:
* `X-Frame-Options DENY`: Previne ataques de Clickjacking.
* `X-Content-Type-Options nosniff`: Previne Mime-Type Sniffing.
* `X-XSS-Protection "1; mode=block"`: Ativa proteção contra Cross-Site Scripting.
* `server_tokens off`: Oculta a versão do Nginx no cabeçalho de resposta HTTP.
* `Content-Security-Policy`: Define fontes confiáveis de scripts, imagens e conexões.

### ⚙️ Camada 5: Restrições de Recursos e Privilégios no Docker
* **`no-new-privileges:true`**: Impede que os containers ganhem novas capacidades ou elevação de privilégios (`sudo`/`suid`) durante a execução.
* **Cotas de CPU e Memória**: Definidos limites máximos de RAM e CPU (`deploy.resources.limits`) para cada serviço, prevenindo que um estouro de memória derrube a VPS (ataques DoS por exaustão de recursos).

### 🏥 Camada 6: Healthchecks e Resiliência
* Cada container possui uma rotina de monitoramento de saúde (`HEALTHCHECK` e `pg_isready`). O backend aguarda a confirmação de disponibilidade do PostgreSQL antes de iniciar (`service_healthy`).

### 🛡️ Camada 7: Firewall do Servidor Host (UFW)
Recomendação para a VPS:
```bash
# Ativa o firewall do sistema operacional da VPS
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
```

---

## 3. Estrutura dos Arquivos Gerados

1. **`Dockerfile.backend.txt`**: Multi-stage build otimizado com usuário não-root.
2. **`Dockerfile.frontend.txt`**: Servidor Nginx Unprivileged com headers de segurança.
3. **`nginx.conf.txt`**: Configuração do proxy reverso e proteção de arquivos ocultos.
4. **`docker-compose.yml.txt`**: Orquestrador com redes segmentadas e limites de recursos.
5. **`.env.example.txt`**: Template seguro de variáveis de ambiente.

---

## 🚀 Como Implantar na VPS

```bash
# 1. Copie os arquivos para a VPS
# 2. Crie o arquivo .env a partir do template e ajuste as permissões
cp .env.example .env
chmod 600 .env

# 3. Gere senhas e chaves fortes para o .env
openssl rand -base64 24 # Para POSTGRES_PASSWORD
openssl rand -hex 32    # Para SECRET_KEY

# 4. Inicie a aplicação com o Docker Compose
docker-compose up -d --build
```
