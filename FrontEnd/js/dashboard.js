// MÓDULO DE PAINEL E MÉTRICAS
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders } from './auth.js';

export async function renderDashboard() {
  try {
    const res = await fetch(`${getApiBaseUrl()}/dashboard/metrics`, { headers: getAuthHeaders() });
    if (!res) return;
    if (res.status === 401) return;
    if (res.ok) {
      const data = await res.json();

      const elAdv = document.getElementById("metric-advogados");
      const elCli = document.getElementById("metric-clientes");
      const elProc = document.getElementById("metric-processos");
      const elAgd = document.getElementById("metric-agendamentos");

      if (elAdv) elAdv.textContent = data.total_advogados || 0;
      if (elCli) elCli.textContent = data.total_clientes || 0;
      if (elProc) elProc.textContent = data.total_processos || 0;
      if (elAgd) elAgd.textContent = data.total_agendamentos || 0;
    }
  } catch (err) {
    console.error("Erro ao carregar métricas do dashboard:", err);
  }
}
