// CONFIGURAÇÃO DINÂMICA DA API PARA TRAEFIK / PRODUÇÃO (V7)
export function getApiBaseUrl() {
    try {
        localStorage.removeItem("api_port");
    } catch(e) {}
    return `${window.location.origin}/api`;
}

export function handleFetchError(err) {
    console.error("Erro na comunicação com a API:", err);
}
