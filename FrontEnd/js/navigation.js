// MÓDULO DE NAVEGAÇÃO E TRANSITION DE PÁGINAS
import { renderDashboard } from './dashboard.js';
import { renderAdvogados } from './advogados.js';
import { renderClientes } from './clientes.js';
import { renderProcessos } from './processos.js';
import { renderAgendamentos } from './agendamentos.js';
import { renderCompromissos } from './compromissos.js';
import { renderPerfil } from './perfil.js';
import { getCurrentUser } from './auth.js';

export function navigateTo(pageId) {
  const user = getCurrentUser();
  if (!user) return;

  // No mobile, fecha a barra lateral ao selecionar qualquer item do menu
  const sidebar = document.querySelector(".sidebar");
  if (sidebar && window.innerWidth <= 768) {
    sidebar.classList.remove("active");
    const btn = document.getElementById("btn-toggle-menu");
    if (btn) btn.setAttribute("aria-expanded", "false");
  }

  if (pageId === "advogados" && user.tipo !== "master") {
    alert("Acesso restrito ao perfil Master.");
    return;
  }

  document.querySelectorAll(".page-content").forEach(page => {
    page.classList.add("hidden");
  });

  const targetPage = document.getElementById(`page-${pageId}`);
  if (targetPage) {
    targetPage.classList.remove("hidden");
    targetPage.focus();
  }

  document.querySelectorAll(".nav-item").forEach(btn => {
    btn.classList.remove("active");
    if (btn.getAttribute("data-page") === pageId) {
      btn.classList.add("active");
    }
  });

  if (pageId === "dashboard") renderDashboard();
  if (pageId === "advogados") renderAdvogados();
  if (pageId === "clientes") renderClientes();
  if (pageId === "processos") renderProcessos();
  if (pageId === "agendamentos") renderAgendamentos();
  if (pageId === "compromissos") renderCompromissos();
  if (pageId === "perfil") renderPerfil();
}
