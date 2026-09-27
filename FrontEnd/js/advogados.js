// MÓDULO DE GESTÃO DE ADVOGADOS (MASTER)
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders, getCurrentUser } from './auth.js';
import { announceToSR } from './accessibility.js';

export async function renderAdvogados() {
  const tbody = document.getElementById("table-advogados-body");
  if (!tbody) return;

  try {
    const res = await fetch(`${getApiBaseUrl()}/usuarios`, { headers: getAuthHeaders() });
    if (!res.ok) return;
    const usuarios = await res.json();

    tbody.innerHTML = "";
    usuarios.forEach(u => {
      const isAtivo = u.ativo !== false;
      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td>${u.id}</td>
        <td>${u.nome}</td>
        <td>${u.email}</td>
        <td><span class="cnj-badge">${u.tipo}</span></td>
        <td>
          <span class="cnj-badge" style="background-color: ${isAtivo ? 'rgba(16, 185, 129, 0.15)' : 'rgba(239, 68, 68, 0.15)'}; color: ${isAtivo ? '#10b981' : '#ef4444'};">
            ${isAtivo ? 'Ativo' : 'Desativado'}
          </span>
        </td>
        <td>
          ${u.tipo !== 'master' ? `
            <button class="btn-action ${isAtivo ? 'btn-secondary' : 'btn-primary'}" onclick="toggleStatusAdvogado(${u.id}, ${isAtivo})">
              ${isAtivo ? 'Desativar' : 'Ativar'}
            </button>
          ` : '-'}
        </td>
      `;
      tbody.appendChild(tr);
    });
  } catch (err) {
    handleFetchError(err);
  }
}

export async function toggleStatusAdvogado(id, currentAtivo) {
  const novoStatus = !currentAtivo;
  const msg = currentAtivo 
    ? "Deseja realmente desativar este advogado? Ele perderá o acesso ao sistema." 
    : "Deseja reativar este advogado? A senha dele será cadastrada como '123456' para primeiro acesso/troca.";

  if (!confirm(msg)) return;

  try {
    const res = await fetch(`${getApiBaseUrl()}/usuarios/${id}/status`, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify({ ativo: novoStatus })
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      alert(errData.detail || "Erro ao alterar status do advogado.");
      return;
    }

    alert(novoStatus ? "Advogado reativado com sucesso! Senha padrão '123456' cadastrada." : "Advogado desativado com sucesso!");
    renderAdvogados();
  } catch (err) {
    handleFetchError(err);
  }
}

export async function handleAddAdvogado(e) {
  e.preventDefault();
  const nome = document.getElementById("adv-nome").value;
  const email = document.getElementById("adv-email").value;
  const senhaInput = document.getElementById("adv-senha");
  const senha = senhaInput.value;

  try {
    const res = await fetch(`${getApiBaseUrl()}/usuarios`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify({ nome, email, senha, tipo: "advogado" })
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      alert(errData.detail || "Erro ao cadastrar advogado.");
      return;
    }

    document.getElementById("form-advogado").reset();
    renderAdvogados();
    announceToSR("Advogado cadastrado com sucesso.");
  } catch (err) {
    handleFetchError(err);
  }
}
