# 🖥️ Documentação da Estrutura do Frontend Modular

Esta documentação apresenta a arquitetura, organização de diretórios e o detalhamento dos componentes do **Frontend Modularizado** do **Sistema Web de Gerenciamento para Escritório de Advocacia**.

A interface foi desenvolvida seguindo os padrões modernos da Web (HTML5 Semântico, CSS3 Flexbox/Grid e ES6 Native Modules), sem dependência de frameworks pesados, garantindo alta velocidade de carregamento, facilidade de manutenção e conformidade integral com as normas de **acessibilidade digital (WCAG 2.1 AA)**.

---

## 📂 1. Árvore de Diretórios do Frontend

```text
FrontEnd/
├── css/
│   └── style.css            # Estilos visuais, variáveis de design, modo noturno e fontes
├── js/
│   ├── config.js            # Resolução dinâmica da URL da API e tratamento de erros de rede
│   ├── accessibility.js     # Recursos WCAG 2.1 AA (Modo Noturno, fontes, leitor de tela, atalhos)
│   ├── auth.js               # Gestão do token JWT, estado da sessão do usuário e login/logout
│   ├── navigation.js        # Roteamento Single Page Application (SPA) e controle de permissões
│   ├── dropdowns.js         # Povoamento dinâmico dos seletores (<select>) de advogados e clientes
│   ├── dashboard.js         # Carregamento e renderização dos cards de métricas operacionais
│   ├── advogados.js         # Gestão de advogados e controle de status (Ativar/Desativar - Perfil Master)
│   ├── clientes.js          # CRUD de clientes e associação com advogados responsáveis
│   ├── processos.js         # Gestão de processos judiciais e consulta à API Pública do CNJ Datajud
│   ├── agendamentos.js      # Agenda por período, validação de conflitos e módulo de Ata de Reunião
│   ├── compromissos.js      # Visão especializada dos próximos 7 dias do advogado logado
│   ├── perfil.js            # Autogestão de e-mail e senha do perfil autenticado
│   └── main.js              # Ponto de entrada (Entry Point), inicialização e pontes no window
├── index.html               # Documento HTML5 principal com suporte semântico e modais
└── Dockerfile               # Configuração da imagem Nginx em Alpine Linux para produção
```

---

## 🛠️ 2. Detalhamento dos Módulos JavaScript (`FrontEnd/js/`)

### 🔑 `config.js` — Configuração da API e Rede
* **Funções principais**: `getApiBaseUrl()`, `handleFetchError()`.
* **Responsabilidade**: Identifica dinamicamente a porta de execução da API FastAPI (`8000`) e centraliza o tratamento amigável de exceções de conexão de rede.

### ♿ `accessibility.js` — Acessibilidade e Leitor de Tela (WCAG 2.1 AA)
* **Funções principais**: `initAccessibility()`, `toggleDarkMode()`, `setFontSize()`, `announceToSR()`, `toggleA11yHelpModal()`, `closeAllModals()`.
* **Responsabilidade**: 
  * Gerencia o tema Noturno (`dark-mode`) e o dimensionamento dinâmico de fonte (`font-small`, `font-normal`, `font-large`).
  * Emite anúncios sonoros para leitores de tela em tempo real (`#sr-announcer` via `aria-live`).
  * Escuta os atalhos de teclado globais (`Alt + D`, `Alt + A`, `Alt + C`, `Alt + P`, `Alt + G`, `Alt + O`, `Alt + M`, `Alt + S`, `Alt + N`, `Alt + H`).

### 🔐 `auth.js` — Autenticação e Controle de Sessão JWT
* **Funções principais**: `getCurrentUser()`, `setCurrentUser()`, `getAuthHeaders()`, `checkAuth()`, `handleLogin()`, `handleLogout()`.
* **Responsabilidade**: 
  * Armazena o token Bearer no `sessionStorage` e injeta os cabeçalhos HTTP de autorização.
  * Controla a visibilidade da tela de login versus o layout do painel principal.
  * Adapta a interface com base no perfil do usuário logado (`master` vs `advogado`).

### 🧭 `navigation.js` — Roteamento Interno
* **Função principal**: `navigateTo(pageId)`.
* **Responsabilidade**: Transiciona as seções visíveis (`page-content`), atualiza os estados ativos do menu lateral e aplica restrições de acesso ao perfil Master.

### 📋 `dropdowns.js` — Seletores Dinâmicos
* **Funções principais**: `populateAdvogadoDropdown()`, `populateClienteDropdown()`.
* **Responsabilidade**: Alimenta os elementos `<select>` de formulários e filtros com a lista atualizada de advogados ativos e clientes cadastrados.

### 📊 `dashboard.js` — Painel Indicador
* **Função principal**: `renderDashboard()`.
* **Responsabilidade**: Requisita a rota `/api/dashboard/metrics` e preenche os indicadores numéricos de advogados, clientes, processos e agendamentos.

### 👨‍⚖️ `advogados.js` — Gestão de Advogados (Perfil Master)
* **Funções principais**: `renderAdvogados()`, `toggleStatusAdvogado()`, `handleAddAdvogado()`.
* **Responsabilidade**: Permite o cadastro de novos advogados e a alteração de status (Ativação/Desativação com redefinição de senha padrão para `'123456'`).

### 👤 `clientes.js` — Gestão de Clientes
* **Funções principais**: `renderClientes()`, `handleAddCliente()`, `deleteCliente()`.
* **Responsabilidade**: Listagem, cadastro, edição e exclusão de clientes e vinculação ao advogado responsável.

### ⚖️ `processos.js` — Processos e CNJ Datajud
* **Funções principais**: `renderProcessos()`, `handleSaveProcesso()`, `editProcesso()`, `consultarCNJ()`, `abrirModalHistorico()`, `handleAddHistoricoManual()`, `deleteProcesso()`.
* **Responsabilidade**: 
  * Cadastro de ações judiciais e integração direta com a API Pública do CNJ Datajud para recuperação do tribunal, classe TPU e linha do tempo de movimentações.
  * Permite o registro manual de andamentos internos.

### 📅 `agendamentos.js` — Gestão Completa de Agenda e Atas
* **Funções principais**: `renderAgendamentos()`, `fetchAndRenderAgendamentosList()`, `handleSaveAgendamento()`, `editAgendamento()`, `abrirModalAta()`, `handleSaveAta()`, `deleteAgendamento()`.
* **Responsabilidade**: 
  * Filtro obrigatório de agenda por período (Data Início/Fim).
  * Validação de conflito de agenda na mesma data e hora para o mesmo advogado ou cliente.
  * Redação e salvamento de Atas de Reunião em campo de texto longo.

### 🗓️ `compromissos.js` — Agenda dos Próximos 7 Dias
* **Funções principais**: `renderCompromissos()`, `fetchAndRenderCompromissosWeek()`.
* **Responsabilidade**: Apresenta a agenda semanal simplificada dos próximos 7 dias para o advogado autenticado (Dia da Semana, Hora, Cliente, Assunto e Atalho para Ata).

### ⚙️ `perfil.js` — Autogestão de Credenciais
* **Funções principais**: `renderPerfil()`, `handleUpdatePerfil()`.
* **Responsabilidade**: Atualização do e-mail e nova senha do usuário logado mediante validação obrigatória da senha atual.

### 🚀 `main.js` — Ponto de Entrada (Entry Point)
* **Responsabilidade**: Unifica as importações dos submódulos, mapeia as funções globais no objeto `window` (para suporte aos manipuladores `onclick` dinâmicos em tabelas) e inicializa os manipuladores de eventos após o `DOMContentLoaded`.

---

## 🎨 3. Camada de Estilo e Layout (`FrontEnd/css/style.css`)

O arquivo CSS utiliza variáveis do CSS (`:root`) para controle do sistema de design:

* **Paleta de Cores e Temas**: Suporte ao tema claro clássico e ao tema noturno (`body.dark-mode`).
* **Acessibilidade Visual**: Classes `.font-small`, `.font-normal` e `.font-large` para escalonamento proporcional do texto.
* **Componentização**:
  * `.login-card`: Card centralizado com z-index adequado para inserção de credenciais.
  * `.metrics-grid`: Grid responsivo para cards numéricos do painel.
  * `.data-table`: Tabelas semânticas estilizadas com alternância de linhas e estados de hover.
  * `.modal-overlay` e `.modal-card`: Estruturas para janelas flutuantes acessíveis.

---

## 📄 4. Estrutura HTML (`FrontEnd/index.html`)

O arquivo `index.html` fornece a estrutura semântica da aplicação:
* **Módulo ES6**: Importação única via `<script type="module" src="js/main.js"></script>`.
* **Recursos de Acessibilidade**:
  * `<div id="sr-announcer" class="sr-only" aria-live="polite">`: Região ao vivo para sintetizadores de voz.
  * `<a href="#main-content" class="skip-link">`: Atalho para pular diretamente ao conteúdo principal (`Alt + 0`).
  * Atributos `aria-label`, `aria-required`, `aria-modal` e rótulos `<label>` vinculados a cada input.

---

## 🐳 5. Containerização em Produção (`FrontEnd/Dockerfile`)

Imagem otimizada de entrega de arquivos estáticos utilizando o servidor Web Nginx sobre Alpine Linux:

```dockerfile
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY . /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---
*Documento elaborado para o Sistema Web de Gerenciamento para Escritório de Advocacia.*
