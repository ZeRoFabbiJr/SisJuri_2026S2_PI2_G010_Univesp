// MÓDULO DE CONFIGURAÇÃO E TRATAMENTO DE ERROS DE REDE
let currentApiPort = "8000";

export function setApiPort(port) {
  currentApiPort = port;
  localStorage.setItem("api_port", port);
}

export function getApiBaseUrl() {
  const savedPort = localStorage.getItem("api_port") || currentApiPort;
  const hostname = window.location.hostname || "127.0.0.1";
  return `http://${hostname}:${savedPort}/api`;
}

export function handleFetchError(err) {
  console.error("Erro de conexão com o servidor:", err);
  const currentPort = localStorage.getItem("api_port") || "8000";
  const suggestedPort = currentPort === "8000" ? "8080" : "8000";
  
  if (confirm(`Não foi possível conectar ao backend na porta ${currentPort}. Deseja tentar a porta ${suggestedPort}?`)) {
    setApiPort(suggestedPort);
    window.location.reload();
  }
}
