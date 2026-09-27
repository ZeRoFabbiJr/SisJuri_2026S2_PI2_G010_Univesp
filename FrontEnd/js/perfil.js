// MÓDULO DE PERFIL DO USUÁRIO
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders, getCurrentUser, setCurrentUser } from './auth.js';
import { announceToSR } from './accessibility.js';

export function renderPerfil() {
  const user = getCurrentUser();
  if (user) {
    const emailInput = document.getElementById("perfil-email");
    if (emailInput) emailInput.value = user.email;
  }
}

export async function handleUpdatePerfil(e) {
  e.preventDefault();
  const email = document.getElementById("perfil-email").value;
  const senha_atual = document.getElementById("perfil-senha-atual").value;
  const nova_senha = document.getElementById("perfil-nova-senha").value;

  const payload = {
    email,
    senha_atual,
    nova_senha: nova_senha || undefined
  };

  try {
    const res = await fetch(`${getApiBaseUrl()}/usuarios/me`, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      const err = await res.json();
      alert(err.detail || "Erro ao atualizar perfil.");
      return;
    }

    const updatedUser = await res.json();
    setCurrentUser(updatedUser);

    document.getElementById("perfil-senha-atual").value = "";
    document.getElementById("perfil-nova-senha").value = "";
    alert("Perfil atualizado com sucesso!");
    announceToSR("Perfil atualizado com sucesso.");
  } catch (err) {
    handleFetchError(err);
  }
}
