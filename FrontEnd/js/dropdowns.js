// MÓDULO DE PREENCHIMENTO DE SELECTS / DROPDOWNS (VERSÃO V7 - AUTO-FETCH GARANTIDO)
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders } from './auth.js';

export async function populateAdvogadoDropdown(selectElementId, selectedId = null) {
  const select = document.getElementById(selectElementId);
  if (!select) return;

  const isFilter = selectElementId.includes("filter");

  try {
    const url = `${getApiBaseUrl()}/usuarios`;
    const res = await fetch(url, { headers: getAuthHeaders() });

    if (!res.ok) {
      if (res.status === 401) {
        select.innerHTML = '<option value="">⚠️ Sessão expirada (Faça Logout e Login)</option>';
      } else {
        select.innerHTML = `<option value="">⚠️ Erro ao carregar advogados (HTTP ${res.status})</option>`;
      }
      return;
    }

    const todosUsuarios = await res.json();

    if (!Array.isArray(todosUsuarios) || todosUsuarios.length === 0) {
      select.innerHTML = isFilter 
        ? '<option value="">Todos os Advogados (Nenhum cadastrado)</option>' 
        : '<option value="">⚠️ Nenhum advogado cadastrado no banco</option>';
      return;
    }

    let advogados = todosUsuarios.filter(u => {
      if (!u.tipo) return true;
      const t = String(u.tipo).toLowerCase();
      return t === 'advogado' || t === 'master' || t === 'admin';
    });

    if (advogados.length === 0) {
      advogados = todosUsuarios;
    }

    select.innerHTML = isFilter 
      ? '<option value="">Todos os Advogados</option>' 
      : '<option value="">Selecione um Advogado</option>';

    advogados.forEach(adv => {
      const opt = document.createElement("option");
      opt.value = adv.id;
      const tipoLabel = adv.tipo ? ` (${adv.tipo.toUpperCase()})` : '';
      opt.textContent = `${adv.nome}${tipoLabel}`;
      if (selectedId && parseInt(selectedId) === adv.id) {
        opt.selected = true;
      }
      select.appendChild(opt);
    });
  } catch (err) {
    console.error("[populateAdvogadoDropdown] Erro:", err);
    select.innerHTML = '<option value="">⚠️ Erro de conexão com a API</option>';
    handleFetchError(err);
  }
}

export async function populateClienteDropdown(selectElementId, selectedId = null) {
  const select = document.getElementById(selectElementId);
  if (!select) return;

  const isFilter = selectElementId.includes("filter");

  try {
    const url = `${getApiBaseUrl()}/clientes`;
    const res = await fetch(url, { headers: getAuthHeaders() });

    if (!res.ok) {
      if (res.status === 401) {
        select.innerHTML = '<option value="">⚠️ Sessão expirada (Faça Logout e Login)</option>';
      } else {
        select.innerHTML = `<option value="">⚠️ Erro ao carregar clientes (HTTP ${res.status})</option>`;
      }
      return;
    }

    const clientes = await res.json();

    if (!Array.isArray(clientes) || clientes.length === 0) {
      select.innerHTML = isFilter 
        ? '<option value="">Todos os Clientes (Nenhum cadastrado)</option>' 
        : '<option value="">⚠️ Nenhum cliente cadastrado no banco</option>';
      return;
    }

    select.innerHTML = isFilter 
      ? '<option value="">Todos os Clientes</option>' 
      : '<option value="">Selecione um Cliente</option>';

    clientes.forEach(cli => {
      const opt = document.createElement("option");
      opt.value = cli.id;
      opt.textContent = cli.nome;
      if (selectedId && parseInt(selectedId) === cli.id) {
        opt.selected = true;
      }
      select.appendChild(opt);
    });
  } catch (err) {
    console.error("[populateClienteDropdown] Erro:", err);
    select.innerHTML = '<option value="">⚠️ Erro de conexão com a API</option>';
    handleFetchError(err);
  }
}

export function initDropdownAutoFetch() {
  const advogadoSelects = ["agd-advogado", "agd-filter-advogado", "proc-advogado", "cli-advogado"];
  const clienteSelects = ["agd-cliente", "proc-cliente"];

  advogadoSelects.forEach(id => {
    const el = document.getElementById(id);
    if (el) {
      const trigger = () => {
        if (el.options.length <= 1) {
          populateAdvogadoDropdown(id);
        }
      };
      el.addEventListener("focus", trigger);
      el.addEventListener("mousedown", trigger);
    }
  });

  clienteSelects.forEach(id => {
    const el = document.getElementById(id);
    if (el) {
      const trigger = () => {
        if (el.options.length <= 1) {
          populateClienteDropdown(id);
        }
      };
      el.addEventListener("focus", trigger);
      el.addEventListener("mousedown", trigger);
    }
  });
}
