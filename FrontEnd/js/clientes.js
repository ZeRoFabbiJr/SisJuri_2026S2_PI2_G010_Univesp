// MÓDULO DE GESTÃO DE CLIENTES (Com Validação e Formatação de CPF)
import { getApiBaseUrl, handleFetchError } from './config.js';
import { getAuthHeaders, getCurrentUser } from './auth.js';
import { populateAdvogadoDropdown } from './dropdowns.js';
import { announceToSR } from './accessibility.js';

/**
 * Valida se um número de CPF é matematicamente válido.
 * Avalia tamanho (11 dígitos), sequências repetidas e os dois dígitos verificadores.
 * @param {string} cpf - Número do CPF com ou sem pontuação.
 * @returns {boolean} - true se o CPF for válido, false caso contrário.
 */
export function validarCPF(cpf) {
    if (!cpf) return false;
    const clean = String(cpf).replace(/\D/g, '');

    // Deve possuir exatamente 11 dígitos
    if (clean.length !== 11) return false;

    // Rejeita sequências com todos os dígitos iguais (ex: 000.000.000-00, 111.111.111-11)
    if (/^(\d)\1{10}$/.test(clean)) return false;

    // Validação do 1º Dígito Verificador
    let soma = 0;
    for (let i = 0; i < 9; i++) {
        soma += parseInt(clean.charAt(i), 10) * (10 - i);
    }
    let resto = (soma * 10) % 11;
    if (resto === 10 || resto === 11) resto = 0;
    if (resto !== parseInt(clean.charAt(9), 10)) return false;

    // Validação do 2º Dígito Verificador
    soma = 0;
    for (let i = 0; i < 10; i++) {
        soma += parseInt(clean.charAt(i), 10) * (11 - i);
    }
    resto = (soma * 10) % 11;
    if (resto === 10 || resto === 11) resto = 0;
    if (resto !== parseInt(clean.charAt(10), 10)) return false;

    return true;
}

/**
 * Formata uma string de CPF para o padrão XXX.XXX.XXX-XX.
 * @param {string} cpf
 * @returns {string}
 */
export function formatarCPF(cpf) {
    const clean = String(cpf).replace(/\D/g, '');
    if (clean.length !== 11) return cpf;
    return clean.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
}

export async function renderClientes() {
    const tbody = document.getElementById("table-clientes-body");
    if (!tbody) return;

    const user = getCurrentUser();
    await populateAdvogadoDropdown("cli-advogado", user.tipo !== "master" ? user.id : null);

    try {
        const res = await fetch(`${getApiBaseUrl()}/clientes`, { headers: getAuthHeaders() });
        if (!res.ok) return;
        const clientes = await res.json();

        tbody.innerHTML = "";
        clientes.forEach(c => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td>${c.id}</td>
                <td>${c.nome}</td>
                <td>${formatarCPF(c.cpf)}</td>
                <td>${c.telefone}</td>
                <td>${c.email}</td>
                <td>${c.advogado_nome || '-'}</td>
                <td>
                    <button class="btn-action btn-secondary" onclick="editCliente(${c.id})">Editar</button>
                    <button class="btn-action btn-secondary" onclick="deleteCliente(${c.id})">Excluir</button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (err) {
        handleFetchError(err);
    }
}

export async function handleAddCliente(e) {
    e.preventDefault();
    const id = document.getElementById("cli-id").value;
    const nome = document.getElementById("cli-nome").value.trim();
    const cpfInput = document.getElementById("cli-cpf");
    const cpfRaw = cpfInput.value.trim();
    const telefone = document.getElementById("cli-telefone").value.trim();
    const email = document.getElementById("cli-email").value.trim();
    const advogado_id = parseInt(document.getElementById("cli-advogado").value, 10);

    // Validação matemática rigorosa do CPF
    if (!validarCPF(cpfRaw)) {
        alert("⚠️ O CPF informado é inválido. Por favor, verifique os dígitos digitados.");
        cpfInput.focus();
        return;
    }

    const cpf = formatarCPF(cpfRaw);
    const payload = { nome, cpf, telefone, email, advogado_id };
    const method = id ? "PUT" : "POST";
    const url = id ? `${getApiBaseUrl()}/clientes/${id}` : `${getApiBaseUrl()}/clientes`;

    try {
        const res = await fetch(url, { method, headers: getAuthHeaders(), body: JSON.stringify(payload) });

        if (!res.ok) {
            const err = await res.json().catch(() => ({}));
            alert("❌ " + (err.detail || "Erro ao salvar cadastro do cliente."));
            return;
        }

        document.getElementById("form-cliente").reset();
        document.getElementById("cli-id").value = "";
        const btnSave = document.getElementById("btn-save-cliente");
        if (btnSave) btnSave.textContent = "Cadastrar Cliente";
        renderClientes();
        announceToSR("Cliente salvo com sucesso.");
    } catch (err) {
        handleFetchError(err);
    }
}

export async function editCliente(id) {
    try {
        const res = await fetch(`${getApiBaseUrl()}/clientes`, { headers: getAuthHeaders() });
        if (!res.ok) return;
        const clientes = await res.json();
        const cli = clientes.find(c => c.id === id);
        if (!cli) return;

        document.getElementById("cli-id").value = cli.id;
        document.getElementById("cli-nome").value = cli.nome;
        document.getElementById("cli-cpf").value = formatarCPF(cli.cpf);
        document.getElementById("cli-telefone").value = cli.telefone;
        document.getElementById("cli-email").value = cli.email;
        if (cli.advogado_id) document.getElementById("cli-advogado").value = cli.advogado_id;

        const btnSave = document.getElementById("btn-save-cliente");
        if (btnSave) btnSave.textContent = "Atualizar Cliente";

        document.getElementById("cli-nome")?.focus();
        announceToSR(`Editando dados do cliente ${cli.nome}.`);
    } catch (err) {
        handleFetchError(err);
    }
}

export async function deleteCliente(id) {
    if (!confirm("Deseja excluir este cliente?")) return;
    try {
        const res = await fetch(`${getApiBaseUrl()}/clientes/${id}`, { method: "DELETE", headers: getAuthHeaders() });
        if (!res.ok) {
            alert("Erro ao excluir cliente.");
            return;
        }
        renderClientes();
        announceToSR("Cliente excluído com sucesso.");
    } catch (err) {
        handleFetchError(err);
    }
}
