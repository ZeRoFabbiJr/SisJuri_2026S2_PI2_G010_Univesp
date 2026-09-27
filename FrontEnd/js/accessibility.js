// MÓDULO DE ACESSIBILIDADE, RECURSOS DE TECLADO E MONITORAMENTO DE API

import { navigateTo } from './navigation.js';
import { getCurrentUser, handleLogout } from './auth.js';

let activeApiRequests = 0;

export function initAccessibility() {
  setupApiFetchInterceptor();

  const savedTheme = localStorage.getItem("theme");
  if (savedTheme === "dark") {
    document.body.classList.add("dark-mode");
    const btnTheme = document.getElementById("btn-toggle-theme");
    if (btnTheme) btnTheme.setAttribute("aria-pressed", "true");
  }

  const savedFontSize = localStorage.getItem("fontSize");
  if (savedFontSize) {
    setFontSize(savedFontSize);
  } else {
    setFontSize("font-normal");
  }

  document.addEventListener("keydown", (e) => {
    const user = getCurrentUser();

    if (e.altKey) {
      const key = e.key.toLowerCase();
      if (key === "0") {
        e.preventDefault();
        document.getElementById("main-content")?.focus();
      } else if (key === "d") {
        e.preventDefault();
        navigateTo("dashboard");
      } else if (key === "a") {
        e.preventDefault();
        if (user && user.tipo === "master") navigateTo("advogados");
      } else if (key === "c") {
        e.preventDefault();
        navigateTo("clientes");
      } else if (key === "p") {
        e.preventDefault();
        navigateTo("processos");
      } else if (key === "g") {
        e.preventDefault();
        navigateTo("agendamentos");
      } else if (key === "o" || key === "k") {
        e.preventDefault();
        navigateTo("compromissos");
      } else if (key === "m") {
        e.preventDefault();
        navigateTo("perfil");
      } else if (key === "s") {
        e.preventDefault();
        handleLogout();
      } else if (key === "n") {
        e.preventDefault();
        toggleDarkMode();
      } else if (key === "h") {
        e.preventDefault();
        toggleA11yHelpModal();
      } else if (key === "+" || key === "=") {
        e.preventDefault();
        setFontSize("font-large");
      } else if (key === "-") {
        e.preventDefault();
        setFontSize("font-small");
      } else if (key === "1") {
        e.preventDefault();
        setFontSize("font-normal");
      }
    } else if (e.key === "Escape") {
      closeAllModals();
    }
  });

  document.getElementById("btn-toggle-theme")?.addEventListener("click", toggleDarkMode);
  document.getElementById("btn-font-small")?.addEventListener("click", () => setFontSize("font-small"));
  document.getElementById("btn-font-normal")?.addEventListener("click", () => setFontSize("font-normal"));
  document.getElementById("btn-font-large")?.addEventListener("click", () => setFontSize("font-large"));
  document.getElementById("btn-a11y-help")?.addEventListener("click", toggleA11yHelpModal);
}

/**
 * INTERCEPTADOR GLOBAL DE FETCH (API DO BACKEND E REQUISIÇÕES EXTERNAS)
 * Exibe o aviso "Aguarde..." piscando em vermelho e branco na barra de acessibilidade
 * sempre que qualquer requisição de API estiver em andamento.
 */
export function setupApiFetchInterceptor() {
  if (window._apiInterceptorInitialized) return;
  window._apiInterceptorInitialized = true;

  const originalFetch = window.fetch;
  window.fetch = async function (...args) {
    showApiLoading();
    try {
      const response = await originalFetch.apply(this, args);
      return response;
    } finally {
      hideApiLoading();
    }
  };
}

export function showApiLoading() {
  activeApiRequests++;
  const indicator = document.getElementById("a11y-api-loading");
  if (indicator) {
    indicator.classList.remove("hidden");
  }
}

export function hideApiLoading() {
  activeApiRequests = Math.max(0, activeApiRequests - 1);
  if (activeApiRequests === 0) {
    const indicator = document.getElementById("a11y-api-loading");
    if (indicator) {
      indicator.classList.add("hidden");
    }
  }
}

export function toggleDarkMode() {
  const isDark = document.body.classList.toggle("dark-mode");
  localStorage.setItem("theme", isDark ? "dark" : "light");
  const btnTheme = document.getElementById("btn-toggle-theme");
  if (btnTheme) btnTheme.setAttribute("aria-pressed", isDark ? "true" : "false");
  announceToSR(isDark ? "Modo Noturno ativado." : "Modo Claro ativado.");
}

export function setFontSize(sizeClass) {
  document.body.classList.remove("font-small", "font-normal", "font-large");
  document.body.classList.add(sizeClass);
  localStorage.setItem("fontSize", sizeClass);

  let label = "Tamanho de fonte normal selecionado.";
  if (sizeClass === "font-small") label = "Tamanho de fonte pequena selecionado.";
  if (sizeClass === "font-large") label = "Tamanho de fonte grande selecionado.";

  announceToSR(label);
}

export function announceToSR(message) {
  const announcer = document.getElementById("sr-announcer");
  if (announcer) {
    announcer.textContent = "";
    setTimeout(() => {
      announcer.textContent = message;
    }, 100);
  }
}

export function toggleA11yHelpModal() {
  const modal = document.getElementById("modal-a11y-help");
  if (modal) {
    const isHidden = modal.classList.toggle("hidden");
    if (!isHidden) {
      modal.querySelector(".btn-close-modal")?.focus();
      announceToSR("Guia de atalhos de acessibilidade aberto.");
    }
  }
}

export function closeAllModals() {
  document.querySelectorAll(".modal-overlay").forEach(m => m.classList.add("hidden"));
}
