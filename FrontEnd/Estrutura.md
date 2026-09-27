### 📂 Arquitetura da Estrutura Modularizada

A nova organização separa o código JavaScript monolítico em arquivos especializados por responsabilidade dentro do diretório `FrontEnd/`:

```text
FrontEnd/
├── css/
│   └── style.css            # Estilos CSS responsivos e temas de acessibilidade
├── js/
│   ├── config.js            # Resolução dinâmica de URL da API e tratamento de erros de rede
│   ├── accessibility.js     # Modo noturno, controle de fontes, leitores de tela e atalhos (Alt+Key)
│   ├── auth.js               # Gestão de token JWT, controle de estado do usuário e login/logout
│   ├── navigation.js        # Roteamento e transição de páginas
│   ├── dropdowns.js         # Preenchimento dinâmico dos seletores de advogados e clientes
│   ├── dashboard.js         # Carregamento e exibição de métricas do painel inicial
│   ├── advogados.js         # Cadastro e alteração de status (Ativar/Desativar) pelo perfil Master
│   ├── clientes.js          # CRUD e vínculo de clientes com advogados
│   ├── processos.js         # Ações judiciais, consulta ao Datajud CNJ e histórico evolutivo
│   ├── agendamentos.js      # Agenda por período, compromissos e módulo de Ata de Reunião
│   ├── perfil.js            # Autogestão de e-mail e senha do usuário logado
│   └── main.js              # Ponto de entrada (Entry Point), inicialização e vínculos no window
└── index.html               # Documento HTML5 acessível importando 'js/main.js' como módulo
```

---

### 🛠️ Divisão de Responsabilidades e Arquivos Criados

1. **`js/config.js`**:
   - `getApiBaseUrl()`: Detecta a porta de execução da API FastAPI.
   - `handleFetchError()`: Tratamento de erros de conexão e ajuste amigável de porta.

2. **`js/accessibility.js`**:
   - `initAccessibility()`, `toggleDarkMode()`, `setFontSize()`, `announceToSR()`, `toggleA11yHelpModal()`, `closeAllModals()`: Suporte completo ao WCAG 2.1 AA e suporte aos atalhos por teclado (`Alt + D`, `Alt + A`, `Alt + C`, `Alt + P`, `Alt + G`, `Alt + M`, `Alt + S`, `Alt + N`, `Alt + H`).

3. **`js/auth.js`**:
   - `getAuthHeaders()`: Injeta o cabeçalho `Authorization: Bearer <token>`.
   - `checkAuth()`, `handleLogin()`, `handleLogout()`: Controle do fluxo de autenticação e estado global da sessão (`sessionStorage`).

4. **`js/navigation.js`**:
   - `navigateTo(pageId)`: Gerencia a visibilidade das páginas (`page-content`) e atualiza o estado ativo do menu lateral.

5. **`js/dropdowns.js`**:
   - `populateAdvogadoDropdown()`, `populateClienteDropdown()`: Alimenta dinamicamente os elementos `<select>` de formulários e filtros.

6. **`js/dashboard.js`**:
   - `renderDashboard()`: Carrega e exibe os indicadores de advogados, clientes, processos e agendamentos.

7. **`js/advogados.js`**:
   - `renderAdvogados()`, `toggleStatusAdvogado()`, `handleAddAdvogado()`: Gestão de advogados com suporte a ativação/desativação e atribuição da senha padrão pelo perfil Master.

8. **`js/clientes.js`**:
   - `renderClientes()`, `handleAddCliente()`, `deleteCliente()`: Operações de cadastro e vinculação de clientes.

9. **`js/processos.js`**:
   - `renderProcessos()`, `handleSaveProcesso()`, `editProcesso()`, `consultarCNJ()`, `abrirModalHistorico()`, `handleAddHistoricoManual()`, `deleteProcesso()`: Gestão de processos, integração com a API Pública do CNJ Datajud e inclusão de andamentos manuais.

10. **`js/agendamentos.js`**:
    - `renderAgendamentos()`, `fetchAndRenderAgendamentosList()`, `handleSaveAgendamento()`, `editAgendamento()`, `abrirModalAta()`, `handleSaveAta()`, `deleteAgendamento()`: Controle de agenda com filtro obrigatório por período, pauta e vinculação de Atas de Reunião.

11. **`js/perfil.js`**:
    - `renderPerfil()`, `handleUpdatePerfil()`: Atualização segura das credenciais de acesso do usuário logado.

12. **`js/main.js`**:
    - Importa todos os submódulos, atribui as funções de manipuladores de eventos diretamente ao objeto global `window` (para garantir a perfeita execução dos eventos `onclick` dinâmicos em tabelas) e inicializa a aplicação no ciclo de vida `DOMContentLoaded`.

13. **`index.html`**:
    - Atualizado com a chamada do script modular:
      ```html
      <script type="module" src="js/main.js"></script>
      ```
    - Mantém toda a estrutura semântica, formulários e modais acessíveis.

---

### 📦 Arquivos Gerados e Disponíveis para Download no Studio (à direita)

Os arquivos resultantes da modularização foram publicados e estão prontos no seu **painel Studio**:

* **`main.js.txt`**
* **`config.js.txt`**
* **`accessibility.js.txt`**
* **`auth.js.txt`**
* **`navigation.js.txt`**
* **`dropdowns.js.txt`**
* **`dashboard.js.txt`**
* **`advogados.js.txt`**
* **`clientes.js.txt`**
* **`processos.js.txt`**
* **`agendamentos.js.txt`**
* **`perfil.js.txt`**
* **`style.css.txt`**
* **`index.html.txt`**
