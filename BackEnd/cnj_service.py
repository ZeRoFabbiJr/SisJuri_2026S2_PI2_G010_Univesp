import requests
import re
import time

DATAJUD_API_KEY = "cDZHYzlZa0JadVREZDJCendQbXY6SkJlTzNjLV9TRENyQk1RdnFKZGRQdw=="
BASE_URL = "https://api-publica.datajud.cnj.jus.br"

TRIBUNAL_MAP = {
    "826": "tjsp", "819": "tjrj", "813": "tjmg", "821": "tjrs", "816": "tjpr",
    "824": "tjsc", "805": "tjba", "806": "tjce", "817": "tjpe", "807": "tjdft",
    "808": "tjes", "809": "tjgo", "810": "tjma", "811": "tjmt", "812": "tjms",
    "814": "tjpa", "815": "tjpb", "818": "tjpi", "820": "tjrn", "822": "tjro",
    "823": "tjrr", "825": "tjse", "827": "tjto", "801": "tjac", "802": "tjal",
    "803": "tjam", "804": "tjap", "401": "trf1", "402": "trf2", "403": "trf3",
    "404": "trf4", "405": "trf5", "406": "trf6", "501": "trt1", "502": "trt2",
    "503": "trt3", "504": "trt4", "505": "trt5", "506": "trt6", "507": "trt7",
    "508": "trt8", "509": "trt9", "510": "trt10", "515": "trt15", "300": "stj",
    "200": "tse", "500": "tst"
}

def extrair_alias_tribunal(numero_processo: str) -> str:
    clean_num = re.sub(r'\D', '', numero_processo)
    if len(clean_num) == 20:
        segmento = clean_num[13:16]
        return TRIBUNAL_MAP.get(segmento, "tjsp")
    return "tjsp"

def consultar_processo_cnj(numero_processo: str) -> dict:
    clean_num = re.sub(r'\D', '', numero_processo)
    alias = extrair_alias_tribunal(clean_num)

    url = f"{BASE_URL}/api_publica_{alias}/_search"
    headers = {
        "Authorization": f"APIKey {DATAJUD_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "query": {
            "match": {
                "numeroProcesso": clean_num
            }
        }
    }

    max_tentativas = 3
    for tentativa in range(1, max_tentativas + 1):
        try:
            response = requests.post(url, json=payload, headers=headers, timeout=(5, 30))
            if response.status_code == 200:
                data = response.json()
                hits = data.get("hits", {}).get("hits", [])
                if hits:
                    source = hits[0].get("_source", {})
                    return {
                        "sucesso": True,
                        "tribunal": source.get("tribunal", alias.upper()),
                        "classe": source.get("classe", {}).get("nome"),
                        "orgao_julgador": source.get("orgaoJulgador", {}).get("nome"),
                        "data_ajuizamento": source.get("dataAjuizamento"),
                        "movimentos": source.get("movimentos", [])
                    }
                return {"sucesso": False, "erro": "Processo não localizado na base do Datajud."}
            
            elif response.status_code == 429:
                if tentativa < max_tentativas:
                    time.sleep(2)
                    continue
                return {
                    "sucesso": False,
                    "erro": "O servidor do CNJ Datajud está temporariamente sobrecarregado (Fila do Elasticsearch cheia - HTTP 429). Aguarde 1 a 2 minutos e tente novamente."
                }
            else:
                return {"sucesso": False, "erro": f"Erro na resposta do CNJ Datajud (Código HTTP {response.status_code})."}

        except requests.exceptions.Timeout:
            return {"sucesso": False, "erro": "A API do CNJ Datajud demorou para responder (Read timed out)."}
        except requests.exceptions.RequestException as e:
            return {"sucesso": False, "erro": f"Falha de conexão com o Datajud: {str(e)}"}
        except Exception as e:
            return {"sucesso": False, "erro": f"Erro inesperado ao processar resposta do CNJ: {str(e)}"}

    return {"sucesso": False, "erro": "Não foi possível conectar ao CNJ Datajud após múltiplas tentativas."}
