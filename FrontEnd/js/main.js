// PONTO DE ENTRADA PRINCIPAL (ENTRY POINT DO FRONTEND MODULARIZADO)
import { initAccessibility, closeAllModals } from './accessibility.js';
import { checkAuth, handleLogin, handleLogout } from './auth.js';
import { navigateTo } from './navigation.js';
import { handleAddAdvogado, toggleStatusAdvogado } from './advogados.js';
import { handleAddCliente, deleteCliente } from './clientes.js';
import { handleSaveProcesso, editProcesso, consultarCNJ, abrirModalHistorico, handleAddHistoricoManual, deleteProcesso } from './processos.js';
import { fetchAndRenderAgendamentosList, handleSaveAgendamento, editAgendamento, abrirModalAta, handleSaveAta, deleteAgendamento } from './agendamentos.js';
import { renderCompromissos } from './compromissos.js';
import { handleUpdatePerfil } from './perfil.js';

// VÍNCULOS GLOBAIS NO WINDOW PARA EVENTOS ONCLICK DINÂMICOS
window.navigateTo = navigateTo;
window.handleLogout = handleLogout;
window.closeAllModals = closeAllModals;

window.toggleStatusAdvogado = toggleStatusAdvogado;
window.deleteCliente = deleteCliente;

window.consultarCNJ = consultarCNJ;
window.abrirModalHistorico = abrirModalHistorico;
window.editProcesso = editProcesso;
window.deleteProcesso = deleteProcesso;

window.abrirModalAta = abrirModalAta;
window.editAgendamento = editAgendamento;
window.deleteAgendamento = deleteAgendamento;
window.fetchAndRenderAgendamentosList = fetchAndRenderAgendamentosList;
window.renderCompromissos = renderCompromissos;

// INICIALIZAÇÃO
document.addEventListener("DOMContentLoaded", () => {
  initAccessibility();
  setupEvents();
  checkAuth();
});

function setupEvents() {
  document.getElementById("login-form")?.addEventListener("submit", handleLogin);
  document.getElementById("btn-logout")?.addEventListener("click", handleLogout);

  // Botão Toggle do Menu Mobile (com rolagem automática ao topo)
  const btnToggleMenu = document.getElementById("btn-toggle-menu");
  if (btnToggleMenu) {
    btnToggleMenu.addEventListener("click", () => {
      const sidebar = document.querySelector(".sidebar");
      if (sidebar) {
        const isOpen = sidebar.classList.toggle("active");
        btnToggleMenu.setAttribute("aria-expanded", isOpen ? "true" : "false");
        if (isOpen) {
          // Rola automaticamente para o topo da página para garantir a visibilidade do menu
          window.scrollTo({ top: 0, behavior: "smooth" });
          document.documentElement.scrollTop = 0;
          document.body.scrollTop = 0;
          const firstNav = sidebar.querySelector(".nav-item");
          if (firstNav) firstNav.focus();
        }
      }
    });
  }

  document.querySelectorAll("[data-page]").forEach(btn => {
    btn.addEventListener("click", (e) => {
      const pageTarget = e.currentTarget.getAttribute("data-page");
      navigateTo(pageTarget);
    });
  });

  document.getElementById("form-advogado")?.addEventListener("submit", handleAddAdvogado);
  document.getElementById("form-cliente")?.addEventListener("submit", handleAddCliente);
  document.getElementById("form-processo")?.addEventListener("submit", handleSaveProcesso);
  document.getElementById("form-agendamento")?.addEventListener("submit", handleSaveAgendamento);
  document.getElementById("form-filter-agendamento")?.addEventListener("submit", (e) => {
    e.preventDefault();
    fetchAndRenderAgendamentosList();
  });
  document.getElementById("form-add-historico")?.addEventListener("submit", handleAddHistoricoManual);
  document.getElementById("form-save-ata")?.addEventListener("submit", handleSaveAta);
  document.getElementById("form-perfil")?.addEventListener("submit", handleUpdatePerfil);
}
