// PONTO DE ENTRADA PRINCIPAL (ENTRY POINT DO FRONTEND MODULARIZADO COM SUPORTE MOBILE)

import { initAccessibility, closeAllModals } from './accessibility.js';
import { checkAuth, handleLogin, handleLogout } from './auth.js';
import { navigateTo, setupMobileMenu, toggleMobileMenu, closeMobileMenu } from './navigation.js';
import { handleAddAdvogado, toggleStatusAdvogado } from './advogados.js';
import { handleAddCliente, editCliente, deleteCliente } from './clientes.js';
import { handleSaveProcesso, editProcesso, consultarCNJ, abrirModalHistorico, handleAddHistoricoManual, deleteProcesso } from './processos.js';
import { fetchAndRenderAgendamentosList, handleSaveAgendamento, editAgendamento, abrirModalAta, handleSaveAta, deleteAgendamento } from './agendamentos.js';
import { renderCompromissos } from './compromissos.js';
import { handleUpdatePerfil } from './perfil.js';

// VÍNCULOS GLOBAIS NO WINDOW PARA EVENTOS ONCLICK DINÂMICOS

window.navigateTo = navigateTo;
window.handleLogout = handleLogout;
window.closeAllModals = closeAllModals;
window.toggleMobileMenu = toggleMobileMenu;
window.closeMobileMenu = closeMobileMenu;
window.toggleStatusAdvogado = toggleStatusAdvogado;
window.editCliente = editCliente;
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
    setupMobileMenu();
    setupEvents();
    checkAuth();
});

function setupEvents() {
    document.getElementById("login-form")?.addEventListener("submit", handleLogin);
    document.getElementById("btn-logout")?.addEventListener("click", handleLogout);
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
