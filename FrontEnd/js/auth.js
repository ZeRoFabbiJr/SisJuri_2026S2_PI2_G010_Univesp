// MÓDULO DE AUTENTICAÇÃO E CONTROLE DE SESSÃO JWT
import { getApiBaseUrl, handleFetchError } from './config.js';
import { announceToSR } from './accessibility.js';
import { navigateTo } from './navigation.js';

let currentUser = JSON.parse(sessionStorage.getItem("currentUser")) || null;

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
    headers["Authorization"] = `Bearer ${token}`;
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
    navigateTo("dashboard");
  } else {
    document.getElementById("login-screen").classList.remove("hidden");
    document.getElementById("main-layout").classList.add("hidden");

    if (senhaInput) {
      senhaInput.value = "";
      senhaInput.removeAttribute("disabled");
      senhaInput.removeAttribute("readonly");
    }
  }
}

export async function handleLogin(e) {
  e.preventDefault();
  const emailInput = document.getElementById("email");
  const senhaInput = document.getElementById("senha");

  const email = emailInput.value.trim();
  const senha = senhaInput.value;

  try {
    const response = await fetch(`${getApiBaseUrl()}/login`, {
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
  setCurrentUser(null);
  sessionStorage.removeItem("access_token");

  const senhaInput = document.getElementById("senha");
  if (senhaInput) senhaInput.value = "";

  const loginForm = document.getElementById("login-form");
  if (loginForm) loginForm.reset();

  checkAuth();
  announceToSR("Sessão encerrada.");
}
