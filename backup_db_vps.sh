#!/bin/bash 

# ============================================================================== 
# SCRIPT DE BACKUP DIÁRIO DO POSTGRESQL NO DOCKER (UBUNTU 24.04 / HOSTINGER) 
# ============================================================================== 

# Configurações gerais 
BACKUP_DIR="/home/ubuntu/backups_postgres" 
CONTAINER_NAME="sistema_juridico_db" 
DB_USER="juridico_user" 
DB_NAME="sistema_juridico" 
RETENTION_DAYS=7 # Número de dias para manter os backups guardados 
DATE=$(date +%Y-%m-%d_%H-%M-%S) 
BACKUP_FILE="$BACKUP_DIR/backup_${DB_NAME}_${DATE}.sql.gz" 

# Garante que a pasta de destino existe 
mkdir -p "$BACKUP\_DIR" 

echo "[$(date)] Iniciando backup do banco $DB\_NAME..." 
# Executa o dump dentro do contêiner e compacta diretamente com gzip 
docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER -d $DB_NAME | gzip > "$BACKUP_FILE" 
if [ ${PIPESTATUS[0]} -eq 0 ]; then
	echo "[$(date)] ✅ Backup gerado com sucesso em: $BACKUP_FILE" 
	# Remove backups antigos com mais de 7 dias para evitar lotar o disco da VPS 
	find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete 
	echo "[$(date)] 🧹 Limpeza concluída: backups com mais de $RETENTION_DAYS dias foram removidos." 
else 
	echo "[$(date)] ❌ Erro ao gerar o backup do banco de dados!" 
	# Remove arquivo corrompido de 0 bytes se houver erro 
	rm -f "$BACKUP\_FILE" 
fi

# Dê permissão de execução ao script no terminal do SO do VPS:
# chmod +x /home/ubuntu/backup_vps.sh

### 🔄 Como Restaurar um Backup quando Necessário
#* **Na VPS Ubuntu (Arquivo** **.sql.gz** **)**:
#
#zcat /home/ubuntu/backups_postgres/backup_sistema_juridico_2026-09-25_02-00-00.sql.gz | docker exec -i sistema_juridico_db psql -U juridico_user -d sistema_juridico