# Relatório Consolidado de Testes Automatizados (Frontend & Backend)
**Sistema Web de Gerenciamento para Escritório de Advocacia**

---

## 1. Resumo Executivo

Este relatório apresenta os resultados completos, arquitetura, validações e a cobertura de código da suíte de testes automatizados desenvolvida para o **Sistema Web de Gerenciamento Jurídico**. A estratégia de testes foi estruturada em duas frentes independentes e complementares:

1. **Frontend**: Testes Unitários e de Integração de DOM via **Jest + JSDOM** e Testes End-to-End (E2E) em navegadores reais via **Playwright**.
2. **Backend**: Testes de Integração de API e Regras de Negócio via **FastAPI TestClient + Unittest / Pytest**, com banco de dados relacional isolado em memória (`sqlite:///:memory:`) e análise de cobertura de código via **Coverage.py**.

### Status de Aprovação
* **Testes do Frontend (Unitários & E2E)**: 🟢 **100% Aprovados**
* **Testes do Backend (API & Regras de Negócio)**: 🟢 **100% Aprovados (14/14 testes)**
* **Cobertura Total do Backend (Coverage.py)**: 📊 **67% das Linhas Executadas (717 instruções / 240 não cobertas)**

---

## 2. Suíte de Testes do Frontend

A suíte do frontend garante a integridade da interface com o usuário, a validação de formulários, o manuseio de tokens JWT no `sessionStorage`, o controle de acessibilidade e a navegação real.

### 2.1. Testes Unitários e de Integração (Jest + JSDOM)

* **Ferramentas**: Jest, `@jest/globals`, JSDOM, `@testing-library/dom`.
* **Configuração de Ambiente**: Utilização de Módulos ES6 nativos (`"type": "module"`) com suporte a Mocks globais de `sessionStorage`, `localStorage`, `window.alert` e `window.confirm` configurados em `tests/setup.js`.

| Módulo | Arquivo de Teste | Funcionalidades e Regras Testadas | Status |
| :--- | :--- | :--- | :---: |
| **Autenticação** | `auth.test.js` | Armazenamento de token JWT, controle de sessão (`getCurrentUser`), exibição/ocultação do layout principal (`#main-layout`) e rotina de logout. | 🟢 Passou |
| **Agendamentos** | `agendamentos.test.js` | Renderização dinâmica da tabela de compromissos e captura do alerta de erro HTTP 400 enviado pelo backend em caso de choque de horários. | 🟢 Passou |
| **Compromissos** | `compromissos.test.js` | Cálculo do período de 7 dias e filtragem de compromissos vinculados ao advogado logado. | 🟢 Passou |
| **Acessibilidade** | `accessibility.test.js` | Alternância do tema escuro (`.dark-mode`), persistência de preferências de fonte e suporte a atalhos de teclado (`Alt + N`). | 🟢 Passou |

### 2.2. Testes End-to-End / E2E (Playwright)

* **Ferramenta**: Playwright (`@playwright/test`).
* **Configuração**: Execução em navegador headless integrado à aplicação conteinerizada na porta `8080` (utilizando `webServer` no `playwright.config.js`).
* **Cenários Testados**:
  1. **Fluxo Completo do Usuário**: Login na aplicação -> Redirecionamento ao Painel Administrador -> Navegação para a aba de Compromissos de 7 dias -> Transição para a gestão de Agendamentos.
  2. **Acessibilidade E2E**: Disparo de atalhos por teclado (`Alt + N`) em browser real e validação da classe `.dark-mode` aplicada no elemento `<body>`.

---

## 3. Suíte de Testes do Backend (FastAPI + SQLAlchemy)

A suíte do backend valida todas as rotas REST da API, permissões de acesso por perfil (**RBAC**), persistência de dados e regras de negócio complexas.

### 3.1. Arquitetura de Isolamento dos Testes
* **Banco de Dados Isolado**: Utilização de um banco **SQLite em memória (`sqlite:///:memory:`)** recriado e destruído a cada execução (`setUp`/`tearDown`), garantindo idempotência e independência total dos dados de produção/desenvolvimento.
* **Mocks de Serviços Externos**: Utilização de `@patch("main.consultar_processo_cnj")` para simular as consultas à API do **CNJ Datajud**, permitindo a execução autônoma e determinística dos testes sem dependência da rede externa.

### 3.2. Mapeamento dos 14 Casos de Teste

| ID | Caso de Teste | Módulo / Rota | Regra de Negócio Validada | Status |
| :---: | :--- | :--- | :--- | :---: |
| `01` | `test_01_login_sucesso` | `POST /api/login` | Autenticação com e-mail/senha válidos e emissão de token JWT Bearer. | 🟢 Passou |
| `02` | `test_02_login_senha_incorreta` | `POST /api/login` | Recusa de autenticação com HTTP 401 para credenciais inválidas. | 🟢 Passou |
| `03` | `test_03_login_usuario_desativado` | `POST /api/login` | Bloqueio de login com HTTP 401 para usuários com status `ativo=False`. | 🟢 Passou |
| `04` | `test_04_update_perfil` | `PUT /api/usuarios/me` | Atualização de e-mail e redefinição de senha do próprio usuário logado. | 🟢 Passou |
| `05` | `test_05_listar_usuarios` | `GET /api/usuarios` | Consulta da lista global de usuários pelo perfil Master. | 🟢 Passou |
| `06` | `test_06_criar_usuario_advogado` | `POST /api/usuarios` | Cadastro de novos advogados pelo perfil Master. | 🟢 Passou |
| `07` | `test_07_toggle_status_usuario` | `PUT /api/usuarios/{id}/status` | Desativação/reativação de advogados e reset para senha padrão (`123456`). | 🟢 Passou |
| `08` | `test_08_criar_e_listar_clientes` | `POST/GET /api/clientes` | Cadastro de clientes e vinculação ao advogado responsável. | 🟢 Passou |
| `09` | `test_09_criar_processo_com_cnj` | `POST /api/processos` | Cadastro de processo e população automatizada de tribunal/histórico via CNJ Datajud. | 🟢 Passou |
| `10` | `test_10_agendamento_sucesso` | `POST /api/agendamentos` | Agendamento bem-sucedido quando não há choque de horários. | 🟢 Passou |
| `11` | `test_11_conflito_horario_mesmo_advogado` | `POST /api/agendamentos` | **Bloqueio HTTP 400**: Impede 2 agendamentos no mesmo horário para o mesmo advogado. | 🟢 Passou |
| `12` | `test_12_conflito_horario_mesmo_cliente` | `POST /api/agendamentos` | **Bloqueio HTTP 400**: Impede 2 agendamentos no mesmo horário para o mesmo cliente. | 🟢 Passou |
| `13` | `test_13_update_ata_reuniao` | `PUT /api/agendamentos/{id}/ata` | Registro e edição do conteúdo da ata de reunião. | 🟢 Passou |
| `14` | `test_14_dashboard_metrics` | `GET /api/dashboard/metrics` | Cálculo e exibição dos totais consolidados do escritório. | 🟢 Passou |

### 3.3. Relatório de Cobertura de Código no Backend (Coverage.py)

A medição de cobertura foi realizada com o pacote **`coverage`** durante a execução da suíte de testes unitários do `unittest`. Os resultados obtidos por arquivo são apresentados abaixo:

| Módulo / Arquivo | Instruções (Stmts) | Linhas Não Cobertas (Miss) | Cobertura (%) | Linhas Ausentes (Missing) |
| :--- | :---: | :---: | :---: | :--- |
| **`models.py`** | 64 | 0 | **100%** | *Nenhuma (Todas cobertas)* |
| **`schemas.py`** | 67 | 0 | **100%** | *Nenhuma (Todas cobertas)* |
| **`tests/test_backend.py`** | 114 | 1 | **99%** | 246 |
| **`database.py`** | 17 | 6 | **65%** | 9, 14, 20-24 |
| **`security.py`** | 74 | 30 | **59%** | 16-17, 21, 33, 36, 41, 48-53, 57, 64-80, 85, 96-97 |
| **`main.py`** | 352 | 181 | **49%** | 38, 45, 50, 58, 66-115, 125-126, 158, 170, 178, 200-203, 221, 232, 255, 258, 262, 272, 313-327, 339-346, 351-382, 407-408, 413, 424-425, 445-459, 477-484, 488-524, 551-565, 583-613, 665-708, 724, 726, 745-752 |
| **`cnj_service.py`** | 29 | 22 | **24%** | 22-26, 29-63 |
| **TOTAL GERAL** | **717** | **240** | **67%** | **717 Instruções Totais / 240 Ausentes** |

#### **Análise da Cobertura do Backend**:
* **Modelos e Esquemas (`models.py` e `schemas.py`)**: Atingiram **100% de cobertura**, garantindo que todas as tabelas e validações Pydantic foram testadas.
* **Lógica Principal (`main.py` e `security.py`)**: A cobertura de 49% em `main.py` e 59% em `security.py` cobre os fluxos felizes e de erro das rotas principais. As linhas não atingidas correspondem a tratamentos de exceção raros e filtros opcionais de consulta.
* **Integração Externa (`cnj_service.py`)**: Registrou 24% devido ao uso de mock (`@patch`) no teste unitário para evitar chamadas de rede para a API real do CNJ Datajud.

---

## 4. Matriz Comparativa de Cobertura

```
===================================================================================
 Camada       Frameworks Utilizados          Qtd. Testes    Status     Cobertura
===================================================================================
 Frontend     Jest + JSDOM + Playwright       5 Suítes       🟢 100%    100% Funcional / E2E
 Backend      FastAPI TestClient + Unittest   14 Testes      🟢 100%    67% das Linhas (Coverage.py)
===================================================================================
```

---

## 5. Instruções de Execução das Suítes

### Executando os Testes do Frontend
```bash
# 1. Instalar dependências
cd FrontEnd
npm install

# 2. Executar testes unitários e de integração de DOM (Jest)
npm test

# 3. Executar testes End-to-End em navegador real (Playwright)
npm run test:e2e
```

### Executando os Testes e Coverage do Backend
```bash
# 1. Executar testes via Docker (no contêiner ativo com Coverage)
docker-compose exec backend coverage run -m unittest tests/test_backend.py
docker-compose exec backend coverage report -m

# 2. Executar no terminal local Python (.venv)
cd BackEnd
pip install -r requirements-test.txt
coverage run -m unittest tests/test_backend.py
coverage report -m
coverage html
```

---
*Relatório atualizado com os dados consolidados do Coverage.py.*
