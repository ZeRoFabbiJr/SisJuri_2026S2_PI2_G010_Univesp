// MÓDULO DE PREENCHIMENTO DE SELECTS / DROPDOWNS
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders } from './auth.js';

export async function populateAdvogadoDropdown(selectElementId, selectedId = null) {
  const select = document.getElementById(selectElementId);
  if (!select) return;

  try {
    const res = await fetch(`${getApiBaseUrl()}/usuarios?tipo=advogado`, { headers: getAuthHeaders() });
    if (!res.ok) return;
    const advogados = await res.json();

    select.innerHTML = selectElementId.includes("filter") ? '<option value="">Todos os Advogados</option>' : '<option value="">Selecione</option>';

    advogados.forEach(adv => {
      const opt = document.createElement("option");
      opt.value = adv.id;
      opt.textContent = adv.nome;
      if (selectedId && parseInt(selectedId) === adv.id) {
        opt.selected = true;
      }
      select.appendChild(opt);
    });
  } catch (err) {
    handleFetchError(err);
  }
}

export async function populateClienteDropdown(selectElementId, selectedId = null) {
  const select = document.getElementById(selectElementId);
  if (!select) return;

  try {
    const res = await fetch(`${getApiBaseUrl()}/clientes`, { headers: getAuthHeaders() });
    if (!res.ok) return;
    const clientes = await res.json();

    select.innerHTML = selectElementId.includes("filter") ? '<option value="">Todos os Clientes</option>' : '<option value="">Selecione</option>';

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
    handleFetchError(err);
  }
}
