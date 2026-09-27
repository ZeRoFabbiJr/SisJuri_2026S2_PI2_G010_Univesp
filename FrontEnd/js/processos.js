// MÓDULO DE PROCESSO E CNJ DATAJUD
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders, getCurrentUser } from './auth.js';
import { populateAdvogadoDropdown, populateClienteDropdown } from './dropdowns.js';
import { announceToSR, closeAllModals } from './accessibility.js';

export async function renderProcessos() {
    const tbody = document.getElementById("table-processos-body");
    if (!tbody) return;

    const user = getCurrentUser();
    await populateClienteDropdown("proc-cliente");
    await populateAdvogadoDropdown("proc-advogado", user.tipo !== "master" ? user.id : null);

    try {
        const res = await fetch(`${getApiBaseUrl()}/processos`, { headers: getAuthHeaders() });
        if (!res.ok) return;
        const processos = await res.json();

        tbody.innerHTML = "";
        processos.forEach(p => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td>${p.id}</td>
                <td><strong>${p.numero_processo}</strong></td>
                <td>${p.descricao}</td>
                <td><span class="cnj-badge">${p.status}</span></td>
                <td>${p.cliente_nome || '-'}</td>
                <td>${p.advogado_nome || '-'}</td>
                <td>${p.tribunal || 'N/A'}</td>
                <td>
                    <button class="btn-action btn-cnj" onclick="consultarCNJ(${p.id}, this)">🔍 CNJ</button>
                    <button class="btn-action btn-primary" onclick="abrirModalHistorico(${p.id}, '${p.numero_processo}')">📜 Histórico</button>
                    <button class="btn-action btn-secondary" onclick="editProcesso(${p.id})">Editar</button>
                    <button class="btn-action btn-secondary" onclick="deleteProcesso(${p.id})">Excluir</button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (err) {
        handleFetchError(err);
    }
}

export async function handleSaveProcesso(e) {
    e.preventDefault();
    const id = document.getElementById("proc-id").value;
    const numero_processo = document.getElementById("proc-numero").value.trim();
    const descricao = document.getElementById("proc-descricao").value;
    const status = document.getElementById("proc-status").value;
    const cliente_id = parseInt(document.getElementById("proc-cliente").value);
    const advogado_id = parseInt(document.getElementById("proc-advogado").value);

    const payload = { numero_processo, descricao, status, cliente_id, advogado_id };
    const method = id ? "PUT" : "POST";
    const url = id ? `${getApiBaseUrl()}/processos/${id}` : `${getApiBaseUrl()}/processos`;

    try {
        const res = await fetch(url, { method, headers: getAuthHeaders(), body: JSON.stringify(payload) });
        if (!res.ok) {
            const errData = await res.json().catch(() => ({}));
            alert("⚠️ " + (errData.detail || "Não foi possível salvar o processo. Verifique os dados digitados."));
            document.getElementById("proc-numero")?.focus();
            return;
        }

        document.getElementById("form-processo").reset();
        document.getElementById("proc-id").value = "";
        document.getElementById("btn-save-processo").textContent = "Cadastrar Processo";
        renderProcessos();
        announceToSR("Processo salvo com sucesso.");
    } catch (err) {
        handleFetchError(err);
    }
}

export async function editProcesso(id) {
    try {
        const res = await fetch(`${getApiBaseUrl()}/processos`, { headers: getAuthHeaders() });
        if (!res.ok) return;
        const processos = await res.json();
        const proc = processos.find(p => p.id === id);
        if (!proc) return;

        document.getElementById("proc-id").value = proc.id;
        document.getElementById("proc-numero").value = proc.numero_processo;
        document.getElementById("proc-descricao").value = proc.descricao;
        document.getElementById("proc-status").value = proc.status;
        document.getElementById("proc-cliente").value = proc.cliente_id;
        document.getElementById("proc-advogado").value = proc.advogado_id;
        document.getElementById("btn-save-processo").textContent = "Atualizar Processo";
        document.getElementById("proc-numero")?.focus();
    } catch (err) {
        handleFetchError(err);
    }
}

export async function consultarCNJ(id, btnElement = null) {
    const btn = btnElement || (typeof event !== 'undefined' ? (event.currentTarget || event.target) : null);
    const textoOriginal = btn ? btn.textContent : "🔍 CNJ";

    if (btn) {
        btn.disabled = true;
        btn.textContent = "Consultando CNJ...";
    }

    if (typeof announceToSR === "function") {
        announceToSR("Consultando API do CNJ Datajud...");
    }

    try {
        const res = await fetch(`${getApiBaseUrl()}/processos/${id}/consultar-cnj`, {
            method: "POST",
            headers: getAuthHeaders()
        });

        const data = await res.json().catch(() => ({}));

        if (res.ok) {
            alert("✅ Dados e histórico atualizados via CNJ Datajud!");
            renderProcessos();
        } else if (res.status === 429) {
            alert("⚠️ " + (data.detail || "O CNJ bloqueou temporariamente as consultas por excesso de tentativas (Rate Limit). Aguarde 1 a 2 minutos e tente novamente."));
        } else {
            alert("❌ " + (data.detail || `Erro na resposta do servidor (Código HTTP ${res.status}).`));
        }
    } catch (err) {
        console.error("Erro na consulta CNJ:", err);
        if (typeof handleFetchError === "function") {
            handleFetchError(err);
        } else {
            alert("❌ Falha de conexão com o servidor backend.");
        }
    } finally {
        if (btn) {
            setTimeout(() => {
                btn.disabled = false;
                btn.textContent = textoOriginal;
            }, 10000);
        }
    }
}

export async function abrirModalHistorico(id, numero) {
    document.getElementById("modal-hist-numero").textContent = numero;
    document.getElementById("hist-processo-id").value = id;

    try {
        const res = await fetch(`${getApiBaseUrl()}/processos`, { headers: getAuthHeaders() });
        if (!res.ok) return;
        const processos = await res.json();
        const proc = processos.find(p => p.id === id);
        if (!proc) return;

        const metaBox = document.getElementById("modal-hist-meta");
        metaBox.innerHTML = `
          <p><strong>Tribunal:</strong> ${proc.tribunal || 'Não informado'}</p>
          <p><strong>Classe:</strong> ${proc.classe_processual || 'Não informada'}</p>
          <p><strong>Órgão Julgador:</strong> ${proc.orgao_julgador || 'Não informado'}</p>
          <p><strong>Data de Ajuizamento:</strong> ${proc.data_ajuizamento ? new Date(proc.data_ajuizamento).toLocaleDateString('pt-BR') : 'Não informada'}</p>
        `;

        const timeline = document.getElementById("timeline-historico");
        timeline.innerHTML = "";

        if (!proc.historicos || proc.historicos.length === 0) {
            timeline.innerHTML = "<p>Nenhuma movimentação registrada.</p>";
        } else {
            proc.historicos.forEach(h => {
                const item = document.createElement("div");
                item.className = "timeline-item";
                item.innerHTML = `
                  <div class="timeline-date">${new Date(h.data_hora).toLocaleString('pt-BR')} (${h.origem})</div>
                  <div class="timeline-title">${h.nome_movimento}</div>
                  <div class="timeline-desc">${h.descricao_detalhada || ''}</div>
                `;
                timeline.appendChild(item);
            });
        }

        document.getElementById("modal-historico").classList.remove("hidden");
    } catch (err) {
        handleFetchError(err);
    }
}

export async function handleAddHistoricoManual(e) {
    e.preventDefault();
    const procId = document.getElementById("hist-processo-id").value;
    const nome_movimento = document.getElementById("hist-nome-movimento").value;
    const descricao_detalhada = document.getElementById("hist-descricao").value;

    try {
        const res = await fetch(`${getApiBaseUrl()}/processos/${procId}/historico`, {
            method: "POST",
            headers: getAuthHeaders(),
            body: JSON.stringify({ nome_movimento, descricao_detalhada })
        });

        if (!res.ok) {
            alert("Erro ao adicionar histórico.");
            return;
        }

        document.getElementById("form-add-historico").reset();
        const numero = document.getElementById("modal-hist-numero").textContent;
        abrirModalHistorico(parseInt(procId), numero);
        renderProcessos();
    } catch (err) {
        handleFetchError(err);
    }
}

export async function deleteProcesso(id) {
    if (!confirm("Deseja excluir este processo?")) return;
    try {
        const res = await fetch(`${getApiBaseUrl()}/processos/${id}`, { method: "DELETE", headers: getAuthHeaders() });
        if (!res.ok) {
            alert("Erro ao excluir processo.");
            return;
        }
        renderProcessos();
    } catch (err) {
        handleFetchError(err);
    }
}
