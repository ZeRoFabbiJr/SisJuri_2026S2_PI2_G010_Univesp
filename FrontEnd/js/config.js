// CONFIGURAÇÃO DINÂMICA DA API PARA TRAEFIK / PRODUÇÃO
export function getApiBaseUrl() {
    // Detecta automaticamente o protocolo (https://) e o domínio (sistema-juridico.cloud)
    return `${window.location.origin}/api`;
}

export function handleFetchError(err) {
    console.error("Erro na comunicação com a API:", err);
    alert("❌ Ocorreu uma falha ao conectar com o servidor. Tente novamente em instantes.");
}
