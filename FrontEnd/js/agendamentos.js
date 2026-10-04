// MÓDULO DE AGENDAMENTOS E ATAS DE REUNIÃO (V10 - MENSAGENS EXATAS DE CONFLITO)
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders, getCurrentUser } from './auth.js';
import { populateAdvogadoDropdown, populateClienteDropdown } from './dropdowns.js';
import { announceToSR, closeAllModals } from './accessibility.js';

function formatLocalDate(date) {
  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

function getDefaultDates() {
  const today = new Date();
  const dataInicio = formatLocalDate(today);
  const future = new Date();
  future.setDate(today.getDate() + 30);
  const dataFim = formatLocalDate(future);
  return { dataInicio, dataFim };
}

export async function renderAgendamentos() {
  let user = getCurrentUser();
  if (!user) {
    try {
      user = JSON.parse(sessionStorage.getItem("currentUser"));
    } catch (e) {
      user = null;
    }
  }

  const { dataInicio, dataFim } = getDefaultDates();

  const inputInicio = document.getElementById("agd-filter-inicio");
  const inputFim = document.getElementById("agd-filter-fim");

  if (inputInicio) inputInicio.value = dataInicio;
  if (inputFim) inputFim.value = dataFim;

  const userId = user ? user.id : null;
  const isMaster = user && user.tipo === "master";

  try {
    await Promise.allSettled([
      populateClienteDropdown("agd-cliente"),
      populateAdvogadoDropdown("agd-advogado", !isMaster ? userId : null),
      populateAdvogadoDropdown("agd-filter-advogado")
    ]);
  } catch (err) {
    console.error("[renderAgendamentos] Erro ao carregar dropdowns:", err);
  }

  await fetchAndRenderAgendamentosList();
}

export async function fetchAndRenderAgendamentosList() {
  const tbody = document.getElementById("table-agendamentos-body");
  if (!tbody) return;

  const inputInicio = document.getElementById("agd-filter-inicio");
  const inputFim = document.getElementById("agd-filter-fim");

  const { dataInicio, dataFim } = getDefaultDates();
  if (inputInicio && !inputInicio.value) inputInicio.value = dataInicio;
  if (inputFim && !inputFim.value) inputFim.value = dataFim;

  const data_inicio = inputInicio?.value || dataInicio;
  const data_fim = inputFim?.value || dataFim;
  const advogado_id = document.getElementById("agd-filter-advogado")?.value;

  let url = `${getApiBaseUrl()}/agendamentos?data_inicio=${data_inicio}&data_fim=${data_fim}`;
  if (advogado_id) {
    url += `&advogado_id=${advogado_id}`;
  }

  try {
    const res = await fetch(url, { headers: getAuthHeaders() });
    if (!res.ok) return;
    const agendamentos = await res.json();

    tbody.innerHTML = "";
    if (!Array.isArray(agendamentos) || agendamentos.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:1.5rem;">Nenhum agendamento encontrado para o período selecionado.</td></tr>';
      return;
    }

    agendamentos.forEach(a => {
      const dt = new Date(a.data_hora).toLocaleString('pt-BR');
      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td>${dt}</td>
        <td>${a.cliente_nome || 'N/A'}</td>
        <td>${a.advogado_nome || '-'}</td>
        <td><strong>${a.titulo}</strong><br><small>${a.descricao}</small></td>
        <td>
          <button class="btn-action btn-cnj" onclick="abrirModalAta(${a.id})">📜 Ata</button>
          <button class="btn-action btn-secondary" onclick="editAgendamento(${a.id})">Editar</button>
          <button class="btn-action btn-secondary" onclick="deleteAgendamento(${a.id})">Excluir</button>
        </td>
      `;
      tbody.appendChild(tr);
    });
  } catch (err) {
    handleFetchError(err);
  }
}

export async function handleSaveAgendamento(e) {
  e.preventDefault();
  const id = document.getElementById("agd-id").value;
  const titulo = document.getElementById("agd-titulo").value;
  const descricao = document.getElementById("agd-descricao").value;
  const data_hora = document.getElementById("agd-data-hora").value;
  const cliente_id = document.getElementById("agd-cliente").value ? parseInt(document.getElementById("agd-cliente").value) : null;
  const advogado_id = parseInt(document.getElementById("agd-advogado").value);

  if (!advogado_id) {
    alert("Por favor, selecione um advogado responsável.");
    return;
  }

  const payload = { titulo, descricao, data_hora, cliente_id, advogado_id };
  const method = id ? "PUT" : "POST";
  const url = id ? `${getApiBaseUrl()}/agendamentos/${id}` : `${getApiBaseUrl()}/agendamentos`;

  try {
    const res = await fetch(url, {
      method,
      headers: getAuthHeaders(),
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      const rawMsg = errData.detail || errData.details || errData.message;
      const msg = typeof rawMsg === "string" ? rawMsg : "Erro ao salvar agendamento.";
      alert(msg);
      announceToSR(msg);
      return;
    }

    document.getElementById("form-agendamento").reset();
    document.getElementById("agd-id").value = "";
    document.getElementById("btn-save-agendamento").textContent = "Cadastrar Agendamento";

    await populateClienteDropdown("agd-cliente");
    await populateAdvogadoDropdown("agd-advogado");

    fetchAndRenderAgendamentosList();
    alert("Agendamento salvo com sucesso!");
    announceToSR("Agendamento salvo com sucesso.");
  } catch (err) {
    handleFetchError(err);
  }
}

export async function editAgendamento(id) {
  try {
    const res = await fetch(`${getApiBaseUrl()}/agendamentos`, { headers: getAuthHeaders() });
    if (!res.ok) return;
    const agendamentos = await res.json();
    const agd = agendamentos.find(a => a.id === id);
    if (!agd) return;

    document.getElementById("agd-id").value = agd.id;
    document.getElementById("agd-titulo").value = agd.titulo;
    document.getElementById("agd-descricao").value = agd.descricao;
    document.getElementById("agd-data-hora").value = agd.data_hora.replace(":00.000Z", "");
    if (agd.cliente_id) document.getElementById("agd-cliente").value = agd.cliente_id;
    document.getElementById("agd-advogado").value = agd.advogado_id;
    document.getElementById("btn-save-agendamento").textContent = "Atualizar Agendamento";
  } catch (err) {
    handleFetchError(err);
  }
}

export async function abrirModalAta(id) {
  try {
    const res = await fetch(`${getApiBaseUrl()}/agendamentos`, { headers: getAuthHeaders() });
    if (!res.ok) return;
    const agendamentos = await res.json();
    const agd = agendamentos.find(a => a.id === id);
    if (!agd) return;

    document.getElementById("ata-agd-id").value = agd.id;
    document.getElementById("ata-info-titulo").textContent = agd.titulo;
    document.getElementById("ata-info-data-hora").textContent = new Date(agd.data_hora).toLocaleString('pt-BR');
    document.getElementById("ata-info-cliente").textContent = agd.cliente_nome || 'Não informado';
    document.getElementById("ata-info-advogado").textContent = agd.advogado_nome || 'Não informado';
    document.getElementById("ata-info-descricao").textContent = agd.descricao;
    document.getElementById("ata-conteudo").value = agd.ata_reuniao || '';

    document.getElementById("modal-ata").classList.remove("hidden");
  } catch (err) {
    handleFetchError(err);
  }
}

export async function handleSaveAta(e) {
  e.preventDefault();
  const id = document.getElementById("ata-agd-id").value;
  const ata_reuniao = document.getElementById("ata-conteudo").value;

  try {
    const res = await fetch(`${getApiBaseUrl()}/agendamentos/${id}/ata`, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify({ ata_reuniao })
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      const rawMsg = errData.detail || errData.details || errData.message;
      const msg = typeof rawMsg === "string" ? rawMsg : "Erro ao salvar ata de reunião.";
      alert(msg);
      return;
    }

    alert("Ata de reunião salva com sucesso!");
    closeAllModals();
    fetchAndRenderAgendamentosList();
  } catch (err) {
    handleFetchError(err);
  }
}

export async function deleteAgendamento(id) {
  if (!confirm("Deseja excluir este agendamento?")) return;
  try {
    const res = await fetch(`${getApiBaseUrl()}/agendamentos/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders()
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      const rawMsg = errData.detail || errData.details || errData.message;
      const msg = typeof rawMsg === "string" ? rawMsg : "Erro ao excluir agendamento.";
      alert(msg);
      return;
    }

    fetchAndRenderAgendamentosList();
  } catch (err) {
    handleFetchError(err);
  }
}
