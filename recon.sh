#!/bin/bash

# Configuración
DOMINIO="ual.es"
WORKSPACE="ual_infra"
RESOURCE_FILE="auto_run.rc"
OUTPUT_FILE="INFRAESTRUCTURA_DETALLADA.txt"

echo "[*] Iniciando Recon-ng para $DOMINIO..."

# 1. Crear archivo de recursos para Recon-ng
cat <<EOF > $RESOURCE_FILE
workspaces create $WORKSPACE
db insert domains
$DOMINIO
Infraestructura Educativa

marketplace install recon/domains-hosts/brute_hosts
marketplace install recon/hosts-hosts/resolve
marketplace install reporting/csv

modules load recon/domains-hosts/brute_hosts
run
modules load recon/hosts-hosts/resolve
run
exit
EOF

# 2. Ejecutar Recon-ng
recon-ng -r $(pwd)/$RESOURCE_FILE

# 3. Procesar la información para las fases del profesor
echo "==================================================" > $OUTPUT_FILE
echo "INFORME DE INFRAESTRUCTURA: $DOMINIO" >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE

echo -e "\n[FASE 1] INFORMACIÓN PROCESADA WHOIS" >> $OUTPUT_FILE
# Sacamos datos reales del sistema para complementar
whois $DOMINIO | grep -E "Registrant|Name Server|Organization" || echo "Dominio .es: Titular Universidad de Almería" >> $OUTPUT_FILE

echo -e "\n[FASE 2 y 3] ENUMERACIÓN Y RANGOS DE IP" >> $OUTPUT_FILE
echo -e "HOST\t\t\tIP" >> $OUTPUT_FILE
# Extraemos los datos de la base de datos de Recon-ng directamente
sqlite3 ~/.recon-ng/workspaces/$WORKSPACE/data.db "SELECT host, ip_address FROM hosts WHERE ip_address IS NOT NULL;" >> $OUTPUT_FILE

echo -e "\n[LISTADO DE RANGOS CONTRATADOS]" >> $OUTPUT_FILE
MAIN_IP=$(dig +short $DOMINIO | tail -n1)
whois $MAIN_IP | grep -E "inetnum|route|descr" | head -n 5 >> $OUTPUT_FILE

echo -e "\n[FASE 4] CLASIFICACIÓN DE ACTIVOS" >> $OUTPUT_FILE
echo "--- Servidores de Email (SaaS/Cloud) ---" >> $REPORT
dig +short MX $DOMINIO >> $OUTPUT_FILE
echo "--- Servidores DNS (Infraestructura Propia/Híbrida) ---" >> $OUTPUT_FILE
dig +short NS $DOMINIO >> $OUTPUT_FILE

echo -e "\n[*] PROCESO FINALIZADO. Archivo generado: $OUTPUT_FILE"
cat $OUTPUT_FILE
