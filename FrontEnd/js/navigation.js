// MÓDULO DE NAVEGAÇÃO E RESPONSIVIDADE MOBILE
import { renderAdvogados } from './advogados.js';
import { renderClientes } from './clientes.js';
import { renderProcessos } from './processos.js';
import { fetchAndRenderAgendamentosList } from './agendamentos.js';
import { renderCompromissos } from './compromissos.js';
import { renderPerfil } from './perfil.js';
import { renderDashboard } from './dashboard.js';
import { announceToSR } from './accessibility.js';

/**
 * Controla a exibição das páginas SPA (Single Page Application).
 * Fecha automaticamente o menu mobile ao navegar para uma página.
 * @param {string} pageTarget - Nome da página a ser exibida.
 */
export function navigateTo(pageTarget) {
    if (!pageTarget) return;

    // Oculta todas as seções de página
    document.querySelectorAll(".page-content").forEach(sec => sec.classList.add("hidden"));

    // Exibe a página selecionada
    const targetEl = document.getElementById(`page-${pageTarget}`);
    if (targetEl) {
        targetEl.classList.remove("hidden");
    }

    // Atualiza estado visual dos botões da sidebar
    document.querySelectorAll(".sidebar-nav .nav-item").forEach(btn => {
        if (btn.getAttribute("data-page") === pageTarget) {
            btn.classList.add("active");
        } else {
            btn.classList.remove("active");
        }
    });

    // Fecha a sidebar mobile se estiver aberta
    closeMobileMenu();

    // Invoca a renderização de dados específica da página
    switch (pageTarget) {
        case "dashboard":
            renderDashboard();
            announceToSR("Painel principal carregado.");
            break;
        case "advogados":
            renderAdvogados();
            announceToSR("Cadastro de advogados carregado.");
            break;
        case "clientes":
            renderClientes();
            announceToSR("Cadastro de clientes carregado.");
            break;
        case "processos":
            renderProcessos();
            announceToSR("Gerenciamento de processos carregado.");
            break;
        case "agendamentos":
            fetchAndRenderAgendamentosList();
            announceToSR("Agendamentos carregados.");
            break;
        case "compromissos":
            renderCompromissos();
            announceToSR("Compromissos dos próximos 7 dias carregados.");
            break;
        case "perfil":
            renderPerfil();
            announceToSR("Perfil do usuário carregado.");
            break;
        default:
            renderDashboard();
            break;
    }

    // Move o foco para o título da página para leitores de tela
    const pageTitle = targetEl?.querySelector(".page-title");
    if (pageTitle) {
        pageTitle.setAttribute("tabindex", "-1");
        pageTitle.focus();
    }
}

/**
 * Configura os ouvintes de eventos para o menu hambúrguer e a sidebar mobile.
 */
export function setupMobileMenu() {
    const btnMobile = document.getElementById("btn-mobile-menu");
    const btnClose = document.getElementById("btn-close-sidebar");
    const overlay = document.getElementById("sidebar-overlay");

    btnMobile?.addEventListener("click", toggleMobileMenu);
    btnClose?.addEventListener("click", closeMobileMenu);
    overlay?.addEventListener("click", closeMobileMenu);

    // Suporte ao envio de tecla ESC para fechar o menu mobile
    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
            closeMobileMenu();
        }
    });
}

/**
 * Alterna a visibilidade da sidebar e do overlay no celular.
 */
export function toggleMobileMenu() {
    const sidebar = document.getElementById("sidebar");
    const overlay = document.getElementById("sidebar-overlay");
    const btnMobile = document.getElementById("btn-mobile-menu");

    if (!sidebar) return;

    const isOpen = sidebar.classList.contains("mobile-open");

    if (isOpen) {
        closeMobileMenu();
    } else {
        sidebar.classList.add("mobile-open");
        overlay?.classList.remove("hidden");
        btnMobile?.setAttribute("aria-expanded", "true");
        announceToSR("Menu de navegação aberto.");
    }
}

/**
 * Fecha a sidebar mobile e oculta o overlay.
 */
export function closeMobileMenu() {
    const sidebar = document.getElementById("sidebar");
    const overlay = document.getElementById("sidebar-overlay");
    const btnMobile = document.getElementById("btn-mobile-menu");

    if (sidebar?.classList.contains("mobile-open")) {
        sidebar.classList.remove("mobile-open");
        overlay?.classList.add("hidden");
        btnMobile?.setAttribute("aria-expanded", "false");
        announceToSR("Menu de navegação fechado.");
    }
}
