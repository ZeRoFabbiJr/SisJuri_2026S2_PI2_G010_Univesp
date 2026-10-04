// MÓDULO DE PERFIL DO USUÁRIO (V12 - SINTAXE CORRIGIDA E EMAIL BLOQUEADO)
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders, getCurrentUser, setCurrentUser } from './auth.js';
import { announceToSR } from './accessibility.js';

export function renderPerfil() {
  const user = getCurrentUser();
  if (user) {
    const emailInput = document.getElementById("perf-email") || document.getElementById("perfil-email");
    if (emailInput) {
      emailInput.value = user.email || "";
      emailInput.readOnly = true;
      emailInput.disabled = true;
    }
  }
}

export async function handleUpdatePerfil(e) {
  e.preventDefault();
  const emailInput = document.getElementById("perf-email") || document.getElementById("perfil-email");
  const senhaAtualInput = document.getElementById("perf-senha-atual") || document.getElementById("perfil-senha-atual");
  const novaSenhaInput = document.getElementById("perf-nova-senha") || document.getElementById("perfil-nova-senha");

  const email = emailInput ? emailInput.value.trim() : "";
  const senha_atual = senhaAtualInput ? senhaAtualInput.value : "";
  const nova_senha = novaSenhaInput ? novaSenhaInput.value : "";

  if (!senha_atual) {
    alert("Por favor, informe a senha atual para confirmar a alteração.");
    if (senhaAtualInput) senhaAtualInput.focus();
    return;
  }

  const payload = {
    email: email || undefined,
    senha_atual: senha_atual,
    nova_senha: nova_senha ? nova_senha : undefined
  };

  try {
    const url = `${getApiBaseUrl()}/usuarios/me`;
    const res = await fetch(url, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      const rawMsg = errData.detail || errData.details || errData.message;
      const msg = typeof rawMsg === "string" ? rawMsg : "Erro ao atualizar perfil.";
      alert(msg);
      announceToSR(msg);
      return;
    }

    const updatedUser = await res.json();
    setCurrentUser(updatedUser);

    if (senhaAtualInput) senhaAtualInput.value = "";
    if (novaSenhaInput) novaSenhaInput.value = "";

    alert("Perfil e senha atualizados com sucesso!");
    announceToSR("Perfil e senha atualizados com sucesso.");
  } catch (err) {
    handleFetchError(err);
  }
}
