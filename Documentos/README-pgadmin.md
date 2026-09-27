# Configuração do pgAdmin 4 no Docker

O **pgAdmin 4** foi adicionado ao ambiente Docker Compose para permitir a administração visual do banco de dados PostgreSQL do **Sistema Jurídico de Gerenciamento**.

---

## 🔑 Credenciais de Acesso ao pgAdmin

- **URL de Acesso**: `http://localhost:5050`
- **E-mail de Login**: `admin@escritorio.com`
- **Senha de Login**: `admin`

---

## 🔌 Como Conectar o pgAdmin ao Banco de Dados PostgreSQL

Ao acessar o pgAdmin pela primeira vez em `http://localhost:5050`:

1. Faça login com as credenciais acima (`admin@escritorio.com` / `admin`).
2. Clique em **"Add New Server"** (ou botão direito em *Servers* -> *Register* -> *Server...*).
3. Na aba **General**:
   - **Name**: `Sistema Juridico DB` (ou o nome de sua preferência)
4. Na aba **Connection**:
   - **Host name/address**: `db` *(nome do serviço containerizado no Docker)*
   - **Port**: `5432`
   - **Maintenance database**: `sistema_juridico`
   - **Username**: `postgres`
   - **Password**: `postgres`
   - Marque a opção **Save password?** para facilitar acessos futuros.
5. Clique em **Save**.

Pronto! Você verá todas as tabelas (`usuarios`, `clientes`, `processos`, `agendamentos`) no schema `public`.

---

## 🚀 Como Executar no Terminal

```bash
# Subir toda a infraestrutura (PostgreSQL + pgAdmin + Backend + Frontend HTTPS)
docker-compose up --build -d
```
