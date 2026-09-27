# Backup do PostgreSQL no Windows via PowerShell
# Linha de comando para execução:
# .\backup_db_windows.ps1

$date = Get-Date -Format "yyyy-MM-dd\_HH-mm-ss" 
$backupFolder = "$PSScriptRoot\\backups"

if (!(Test-Path $backupFolder)) {
	New-Item -ItemType Directory -Path $backupFolder | Out-Null 
} 

$backupFile = "$backupFolder\\_$date.sql" 

Write-Host "Iniciando backup do banco de dados no Docker..." -ForegroundColor Cyan 

docker exec -t sistema_juridico_db pg_dump -U juridico_prod_user -d sistema_juridico > $backupFile 

if (Test-Path $backupFile) {
	Write-Host "✅ Backup concluído com sucesso: $backupFile" -ForegroundColor Green 
} else {
	Write-Host "❌ Falha ao gerar o arquivo de backup." -ForegroundColor Red 
}

# Comandos para restaurar backup:
#
### 🔄 Como Restaurar um Backup quando Necessário
# * **No Windows**:
#
#### **Passo 1: Apagar e recriar o banco de dados limpo**
# docker exec -it sistema_juridico_db psql -U juridico_prod_user -d sistema_juridico -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
#
#### **Passo 2: Executar a restauração no banco limpo**
#
# Get-Content backups\\<nome-do-backup>.sql | docker exec -i sistema_juridico_db psql -U juridico_prod_user -d sistema_juridico
