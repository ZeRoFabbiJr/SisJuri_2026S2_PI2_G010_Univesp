
# UNIVERSIDADE VIRTUAL DO ESTADO DE SÃO PAULO
# ⚖️ Sistema Web de Gerenciamento para Escritório de Advocacia
# Projeto Integrador em Computação II - DRP04 - Turma 001 - Grupo 10
# 2026 - 2º Semestre

> **Projeto**  
> Sistema web completo, seguro e acessível para gestão de clientes, processos judiciais com integração à API do CNJ Datajud, agendamentos e atas de reunião.

---

## 📌 Visão Geral do Projeto

O **Sistema Web de Gerenciamento para Escritório de Advocacia** é uma solução corporativa desenvolvida para otimizar a rotina jurídica de escritórios de advocacia. A plataforma oferece controle de acesso baseado em papéis (RBAC), gestão completa de clientes e processos, consulta automatizada de movimentações processuais no CNJ Datajud, controle de agenda e atas de reunião, além de suporte nativo a regras de acessibilidade digital (**WCAG 2.1 AA**) e responsividade para dispositivos móveis.

---

## 🏗️ Arquitetura do Sistema e Conteinerização (Docker)

A aplicação adota uma arquitetura de microsserviços conteinerizada utilizando **Docker** e **Docker Compose**, composta por 3 serviços interdependentes e isolados em sub-redes dedicadas:

```
                  +-----------------------------------+
                  |      Navegador Web / Mobile       |
                  +-----------------------------------+
                                    |
                                    v (Porta 8080)
                  +-----------------------------------+
                  |      FRONTEND (Nginx / Static)    |
                  +-----------------------------------+
                                    |
                         (juridico_frontend_net)
                                    v
                  +-----------------------------------+
                  |        BACKEND (FastAPI)          |
                  +-----------------------------------+
                                    |
                         (juridico_backend_net)
                                    v
                  +-----------------------------------+
                  |     POSTGRES_DB (PostgreSQL 16)   |
                  +-----------------------------------+
```

### 📦 Componentes da Infraestrutura Docker

1. **`frontend` (Servidor Web Nginx Unprivileged)**:
   * **Imagem**: `nginxinc/nginx-unprivileged:alpine`
   * **Função**: Serve os arquivos estáticos da interface (HTML5, CSS3, JS Vanilla ES6 Módulos) e atua como servidor web de alta performance.
   * **Segurança**: Executa em modo não-root na porta interna `8080` (mapeada para `8080:8080` no host).
   * **Rede**: Conectado à rede `juridico_frontend_net`.

2. **`backend` (API Restful FastAPI)**:
   * **Linguagem / Framework**: Python 3.12 + FastAPI 0.110+ com servidor ASGI Uvicorn.
   * **ORM & Schemas**: SQLAlchemy 2.0 (manipulação relacional) e Pydantic v2 (validação de dados).
   * **Segurança & Autenticação**: OAuth2 com Tokens JWT (criptografia de senhas via Bcrypt) e controle de permissões RBAC (`Master` e `Advogado`).
   * **Integração CNJ Datajud**: Módulo de resiliência com algoritmo de *Retry com Backoff Exponencial* para tratamento de limites de taxa (HTTP 429 / Rate Limit) e timeouts.
   * **Redes**: Conectado às redes `juridico_frontend_net` e `juridico_backend_net`.

3. **`postgres_db` (Banco de Dados Relacional)**:
   * **Imagem**: `postgres:16-alpine`
   * **Segurança**: Porta `5432` **não exposta** para a internet no ambiente de produção.
   * **Persistência**: Volume Docker dedicado (`juridico_postgres_data`) para garantir a integridade dos dados.
   * **Monitoramento**: Teste de integridade (*healthcheck*) contínuo via `pg_isready`.
   * **Rede**: Isolado exclusivamente na rede interna `juridico_backend_net`.

---

## ☁️ Ambiente de Produção (VPS KVM2 Hostinger)

A aplicação está homologada e implantada em servidor virtual privado (**VPS KVM2 Hostinger**) com as seguintes especificações e hardening de segurança:

* **Sistema Operacional**: Ubuntu 24.04 LTS (Noble Numbat).
* **Orquestração**: Docker Engine + Docker Compose Plugin.
* **Segurança de Rede**: Firewall nativo **UFW** configurado para liberar apenas portas estritamente necessárias (`80`, `443`, `8080` e SSH).
* **Acesso Remoto**: Autenticação SSH restrita por **Chaves Criptográficas Pública/Privada** (login por senha desativado).
* **Política de Backup (Disaster Recovery)**: Script automatizado Shell (`.sh`) executado diariamente às 02:00 via `cron`, realizando o `pg_dump` com compressão `gzip` e retenção automática de 7 dias.

---

## 🚀 Funcionalidades Principais

### 1. Autenticação e Perfis de Acesso (RBAC)
* **Perfil Master (Administrador)**: Acesso irrestrito a todos os módulos, incluindo cadastro, ativação/desativação de advogados e visualização de métricas globais.
* **Perfil Advogado**: Acesso restrito aos clientes, processos, agendamentos e compromissos sob sua responsabilidade.

### 2. Módulo de Clientes e Validação Algorítmica
* **Validação de CPF (Módulo 11)**: Algoritmo matemático para verificação dos dígitos verificadores, rejeição de sequências inválidas (ex: `111.111.111-11`) e formatação automática em tempo real (`XXX.XXX.XXX-XX`).
* **Edição e Atualização**: Formulário dinâmico para atualização de dados cadastrais.

### 3. Módulo de Processos e Integração CNJ Datajud
* **Prevenção de Duplicidade**: Validação no backend e frontend para impedir o cadastro acidental de números de processos repetidos.
* **Consulta ao Datajud**: Busca automatizada na API do Conselho Nacional de Justiça com preenchimento automático do histórico de movimentações processuais, classe, tribunal e órgão julgador.

### 4. Agendamentos, Atas e Próximos Compromissos
* **Controle de Agenda**: Agendamento de reuniões e prazos com algoritmo de prevenção de choques de horário.
* **Atas de Reunião**: Registro e edição de atas detalhadas vinculadas aos compromissos.
* **Visão 7 Dias**: Painel exclusivo com a relação dos compromissos dos próximos 7 dias do advogado logado.

### 5. Acessibilidade Digital (WCAG 2.1 AA)
* **Indicador `⏳ AGUARDE...`**: Alerta visual piscando em alto contraste vermelho e branco durante requisições à API.
* **Leitor de Tela**: Regiões `aria-live` e marcações ARIA semânticas para suporte ao NVDA/JAWS.
* **Recursos**: Modo Noturno (*Dark Mode*), ajuste do tamanho de fonte (A-, A, A+) e atalhos de teclado.

### 6. Responsividade Mobile
* **Menu Hambúrguer Retrátil**: Gaveta de navegação lateral (*drawer slide-over*) ativada em telas menores que 768px.
* **Tabelas Responsivas**: Contêineres `.table-responsive` com rolagem horizontal suave ao toque.
* **Ocultação Inteligente**: Ocultação automática de botões de atalhos de teclado desktop em smartphones.

---

## 🛠️ Tecnologias Utilizadas

| Camada | Tecnologias / Frameworks |
| :--- | :--- |
| **Frontend** | HTML5 Semântico, CSS3 (Variables, Flexbox, Grid), JavaScript ES6 Vanilla (Native Modules) |
| **Backend** | Python 3.12, FastAPI, SQLAlchemy ORM, Pydantic v2, Uvicorn ASGI |
| **Segurança** | OAuth2, JWT (JSON Web Tokens), Bcrypt Criptografia |
| **Banco de Dados** | PostgreSQL 16 Alpine, PG_Dump |
| **Conteinerização** | Docker, Docker Compose, Nginx Unprivileged |
| **Infraestrutura / VPS** | Hostinger KVM2, Ubuntu 24.04 LTS, UFW Firewall, Cron |

---

## 💻 Como Executar o Projeto Localmente

### Pré-requisitos
* **Docker Engine** e **Docker Compose** instalados.

### Passo a Passo

1. **Clonar o Repositório**:
   ```bash
   git clone https://github.com/seu-usuario/sistema-juridico.git
   cd sistema-juridico
   ```

2. **Configurar as Variáveis de Ambiente**:
   Crie um arquivo `.env` na raiz do projeto com base no exemplo:
   ```env
   POSTGRES_DB=sistema_juridico
   POSTGRES_USER=juridico_user
   POSTGRES_PASSWORD=sua_senha_segura
   SECRET_KEY=sua_chave_secreta_jwt
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=60
   ```

3. **Iniciar os Contêineres com Docker Compose**:
   ```bash
   docker-compose up -d --build
   ```

4. **Acessar a Aplicação**:
   * **Frontend**: `http://localhost:8080`
   * **Documentação da API (Swagger)**: `http://localhost:8000/docs`

---

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos como parte do **Projeto Integrador da UNIVESP**.

# UNIVERSIDADE VIRTUAL DO ESTADO DE SÃO PAULO

- Alexandre Henrique Sividal Marchiori, 24202285
- Glayce da Silva Nascimento, 23222805
- Hermeson Douglas Barbosa, 2008315
- José Roberto Fabbi Junior, 23214726
- Kleber Tandello Pereira, 2006481
- Matheus Rogério Wohnrath, 2222506
- Vinicius Rodrigues de Almondes, 24217873
- Rafaela Filomena Alves Guimarães, RA 24227315
- André Luis Borsato Sanchez, Orientador do PI




Evolução de um Sistema Web Integrado para Gestão de Escritório de Advocacia com Banco de Dados, APIs, Recursos de Acessibilidade e Computação em Nuvem 

Americana, Atibaia, Campo Limpo Paulista, Cosmópolis, Itatiba, Itupeva, Jaguariúna, Vinhedo - SP
2026

## RESUMO
Este trabalho apresenta a evolução de um sistema web destinado à gestão de escritórios de advocacia, desenvolvido a partir das demandas identificadas junto a um escritório de advocacia de pequeno porte participante da comunidade externa. O projeto tem como objetivo aprimorar uma solução previamente implementada para gerenciamento de clientes, processos e agendamentos, incorporando recursos de integração com APIs, acessibilidade, segurança da informação, testes de software e computação em nuvem. A metodologia adotada baseou-se em pesquisa bibliográfica, levantamento e análise de requisitos, reuniões com o responsável pelo escritório, estudo de soluções existentes e planejamento da arquitetura da aplicação. A partir das informações coletadas, foram identificadas oportunidades de melhoria relacionadas à centralização das informações, otimização dos processos administrativos, redução de falhas operacionais e ampliação da usabilidade do sistema. Como resultados parciais, foram revisados os requisitos funcionais e não funcionais, definidas as tecnologias a serem utilizadas, estruturadas as funcionalidades a serem implementadas e elaborada a proposta técnica para evolução da plataforma. Além disso, foram estabelecidos critérios para integração com serviços externos, implementação de mecanismos de acessibilidade e realização de testes visando garantir confiabilidade e qualidade da solução. Conclui-se que o projeto apresenta potencial para contribuir significativamente com a modernização da gestão do escritório participante, promovendo maior eficiência operacional, organização das informações e melhoria no atendimento aos clientes, ao mesmo tempo em que possibilita a aplicação prática dos conhecimentos adquiridos ao longo do curso na resolução de uma demanda real.
PALAVRAS-CHAVE: sistema web; gestão jurídica; acessibilidade; APIs; computação em nuvem; testes de software.
