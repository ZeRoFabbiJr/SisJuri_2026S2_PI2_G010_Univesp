// MÓDULO DE AUTENTICAÇÃO, CONTROLE DE SESSÃO JWT E CRONÔMETRO (V19)
import { getApiBaseUrl, handleFetchError } from './config.js';
import { announceToSR } from './accessibility.js';
import { navigateTo } from './navigation.js';

let currentUser = JSON.parse(sessionStorage.getItem("currentUser")) || null;

// ==============================================================================
// CONTROLE DE CRONÔMETRO DE SESSÃO (15 MINUTOS = 900 SEGUNDOS)
// ==============================================================================
let sessionTimerInterval = null;
let remainingSeconds = 900; // 15 min
let lastResetTime = 0;

export function startSessionTimer() {
  stopSessionTimer();
  remainingSeconds = 900;
  lastResetTime = Date.now();
  updateTimerDisplay();

  const timerDisplay = document.getElementById("session-timer-display");
  if (timerDisplay) {
    timerDisplay.classList.remove("hidden");
  }

  sessionTimerInterval = setInterval(() => {
    remainingSeconds--;
    if (remainingSeconds <= 0) {
      stopSessionTimer();
      handleLogout();
      alert("⚠️ Sua sessão expirou após 15 minutos de inatividade. Você foi deslogado por segurança.");
      announceToSR("Sessão expirada por inatividade. Você foi deslogado por segurança.");
    } else {
      updateTimerDisplay();
    }
  }, 1000);
}

export function resetSessionTimer() {
  if (currentUser && remainingSeconds > 0) {
    const now = Date.now();
    if (now - lastResetTime > 1000 || remainingSeconds < 895) {
      remainingSeconds = 900;
      lastResetTime = now;
      updateTimerDisplay();
    }
  }
}

export function stopSessionTimer() {
  if (sessionTimerInterval) {
    clearInterval(sessionTimerInterval);
    sessionTimerInterval = null;
  }
  const timerDisplay = document.getElementById("session-timer-display");
  if (timerDisplay) {
    timerDisplay.classList.add("hidden");
  }
}

function updateTimerDisplay() {
  const timerDisplay = document.getElementById("session-timer-display");
  if (!timerDisplay) return;

  const minutes = Math.floor(remainingSeconds / 60);
  const seconds = remainingSeconds % 60;
  const mm = String(minutes).padStart(2, '0');
  const ss = String(seconds).padStart(2, '0');
  
  timerDisplay.textContent = "⏳ " + mm + ":" + ss;

  if (remainingSeconds <= 120) {
    timerDisplay.classList.add("timer-warning");
  } else {
    timerDisplay.classList.remove("timer-warning");
  }
}

if (typeof window !== "undefined") {
  const originalFetch = window.fetch;
  window.fetch = async function (...args) {
    resetSessionTimer();
    return originalFetch.apply(this, args);
  };

  const activityEvents = [
    "click",
    "touchstart",
    "touchend",
    "touchmove",
    "pointerdown",
    "mousemove",
    "keydown",
    "scroll",
    "submit"
  ];

  activityEvents.forEach(evt => {
    window.addEventListener(evt, () => {
      resetSessionTimer();
    }, { capture: true, passive: true });
  });
}

// ==============================================================================
// MÓDULO JWT E AUTENTICAÇÃO DE USUÁRIO
// ==============================================================================
export function getCurrentUser() {
  return currentUser;
}

export function setCurrentUser(user) {
  currentUser = user;
  if (user) {
    sessionStorage.setItem("currentUser", JSON.stringify(user));
  } else {
    sessionStorage.removeItem("currentUser");
  }
}

export function getAuthHeaders() {
  const token = sessionStorage.getItem("access_token");
  const headers = { "Content-Type": "application/json" };
  if (token) {
    headers["Authorization"] = "Bearer " + token;
  }
  return headers;
}

export function checkAuth() {
  const senhaInput = document.getElementById("senha");

  if (currentUser) {
    document.getElementById("login-screen").classList.add("hidden");
    document.getElementById("main-layout").classList.remove("hidden");
    
    document.getElementById("user-role-title").textContent = 
      currentUser.tipo === "master" ? "Master" : "Advogado";

    if (currentUser.tipo !== "master") {
      document.getElementById("nav-advogados")?.classList.add("hidden");
    } else {
      document.getElementById("nav-advogados")?.classList.remove("hidden");
    }

    if (senhaInput) {
      senhaInput.value = "";
      senhaInput.removeAttribute("disabled");
      senhaInput.removeAttribute("readonly");
    }

    startSessionTimer();
    navigateTo("dashboard");
  } else {
    document.getElementById("login-screen").classList.remove("hidden");
    document.getElementById("main-layout").classList.add("hidden");

    if (senhaInput) {
      senhaInput.value = "";
      senhaInput.removeAttribute("disabled");
      senhaInput.removeAttribute("readonly");
    }

    stopSessionTimer();
  }
}

export async function handleLogin(e) {
  e.preventDefault();
  const emailInput = document.getElementById("email");
  const senhaInput = document.getElementById("senha");

  const email = emailInput.value.trim();
  const senha = senhaInput.value;

  try {
    const url = getApiBaseUrl() + "/login";
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, senha })
    });

    if (!response.ok) {
      senhaInput.value = "";
      const errData = await response.json().catch(() => ({}));
      alert(errData.detail || "E-mail ou senha incorretos!");
      announceToSR("Falha no login. E-mail ou senha incorretos.");
      senhaInput.focus();
      return;
    }

    const data = await response.json();
    sessionStorage.setItem("access_token", data.access_token);
    setCurrentUser({ id: data.id, nome: data.nome, email: data.email, tipo: data.tipo });

    senhaInput.value = "";
    checkAuth();
    announceToSR("Login efetuado com sucesso. Redirecionando para o painel principal.");
  } catch (err) {
    senhaInput.value = "";
    handleFetchError(err);
  }
}

export function handleLogout() {
  stopSessionTimer();
  setCurrentUser(null);
  sessionStorage.removeItem("access_token");

  const senhaInput = document.getElementById("senha");
  if (senhaInput) senhaInput.value = "";

  const loginForm = document.getElementById("login-form");
  if (loginForm) loginForm.reset();

  checkAuth();
  announceToSR("Sessão encerrada.");
}
