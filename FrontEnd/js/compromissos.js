// MÓDULO DE PRÓXIMOS COMPROMISSOS (7 DIAS)
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders, getCurrentUser } from './auth.js';
import { announceToSR } from './accessibility.js';

export async function renderCompromissos() {
  const user = getCurrentUser();
  if (!user) return;

  const tbody = document.getElementById("table-compromissos-body");
  const rangeLabel = document.getElementById("compromissos-range-label");
  if (!tbody) return;

  // Calcula o intervalo de 7 dias (hoje até hoje + 6 dias)
  const today = new Date();
  const endDate = new Date(today);
  endDate.setDate(today.getDate() + 6);

  const startStr = today.toISOString().split('T')[0];
  const endStr = endDate.toISOString().split('T')[0];

  if (rangeLabel) {
    rangeLabel.textContent = `${today.toLocaleDateString('pt-BR')} até ${endDate.toLocaleDateString('pt-BR')}`;
  }

  // Busca agendamentos do advogado logado no período de 7 dias
  const url = `${getApiBaseUrl()}/agendamentos?data_inicio=${startStr}&data_fim=${endStr}&advogado_id=${user.id}`;

  try {
    const res = await fetch(url, { headers: getAuthHeaders() });
    if (!res.ok) return;
    const agendamentos = await res.json();

    tbody.innerHTML = "";

    if (agendamentos.length === 0) {
      tbody.innerHTML = `
        <tr>
          <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">
            Nenhum compromisso agendado para os próximos 7 dias.
          </td>
        </tr>
      `;
      return;
    }

    agendamentos.forEach(a => {
      const dt = new Date(a.data_hora);
      
      // Dia da semana formatado em português (ex: Segunda-feira)
      const rawDia = dt.toLocaleDateString('pt-BR', { weekday: 'long' });
      const diaSemanaFormatted = rawDia.charAt(0).toUpperCase() + rawDia.slice(1);
      const dataStr = dt.toLocaleDateString('pt-BR');
      
      // Hora formatada (ex: 14:30)
      const horaStr = dt.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });

      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td><strong>${diaSemanaFormatted}</strong><br><small style="color: var(--text-muted);">${dataStr}</small></td>
        <td><span class="cnj-badge">${horaStr}</span></td>
        <td>${a.cliente_nome || 'Não informado'}</td>
        <td><strong>${a.titulo}</strong><br><small style="color: var(--text-muted);">${a.descricao}</small></td>
        <td>
          <button class="btn-action btn-cnj" onclick="abrirModalAta(${a.id})">📜 Ata</button>
        </td>
      `;
      tbody.appendChild(tr);
    });

    announceToSR("Agenda de compromissos para os próximos 7 dias carregada.");
  } catch (err) {
    handleFetchError(err);
  }
}
