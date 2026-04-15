#!/bin/bash

# ============================================
#  Infraestructura Automática (Recon-ng + WHOIS)
#  Autor: Flex (David Pérez)
#  Uso: ./infra_recon.sh dominio.com
# ============================================

if [ -z "$1" ]; then
    echo "Uso: $0 dominio.com"
    exit 1
fi

DOMINIO="$1"
BASE_DIR=$(pwd)/"$DOMINIO"
WORKSPACE="${DOMINIO}_ws"
RESOURCE_FILE="$BASE_DIR/auto_run.rc"
OUTPUT_FILE="$BASE_DIR/INFORME_$DOMINIO.txt"

mkdir -p "$BASE_DIR"

echo "[*] Iniciando análisis para $DOMINIO..."
echo "[*] Carpeta creada: $BASE_DIR"

# ============================================
# 1. Crear archivo de recursos para Recon-ng
# ============================================

cat <<EOF > "$RESOURCE_FILE"
workspaces create $WORKSPACE
db insert domains
$DOMINIO
Dominio objetivo

marketplace install recon/domains-hosts/brute_hosts
marketplace install recon/hosts-hosts/resolve

modules load recon/domains-hosts/brute_hosts
run

modules load recon/hosts-hosts/resolve
run

exit
EOF

echo "[*] Ejecutando Recon-ng..."
recon-ng -r "$RESOURCE_FILE"

# ============================================
# 2. Generar informe
# ============================================

echo "==================================================" > "$OUTPUT_FILE"
echo "INFORME DE INFRAESTRUCTURA: $DOMINIO" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"

# ---------- FASE 1 ----------
echo -e "\n[FASE 1] WHOIS" >> "$OUTPUT_FILE"
whois "$DOMINIO" | grep -E "Registrant|Organization|Name Server" >> "$OUTPUT_FILE"

# ---------- FASE 2 ----------
echo -e "\n[FASE 2] HOSTS ENUMERADOS" >> "$OUTPUT_FILE"
echo -e "HOST\t\tIP" >> "$OUTPUT_FILE"

sqlite3 ~/.recon-ng/workspaces/$WORKSPACE/data.db \
"SELECT host, ip_address FROM hosts WHERE ip_address IS NOT NULL;" >> "$OUTPUT_FILE"

# ---------- FASE 3 ----------
echo -e "\n[FASE 3] RANGOS ASN" >> "$OUTPUT_FILE"

MAIN_IP=$(dig +short "$DOMINIO" | tail -n1)

whois "$MAIN_IP" | grep -E "inetnum|route|descr|origin" >> "$OUTPUT_FILE"

# ---------- FASE 4 ----------
echo -e "\n[FASE 4] SERVIDORES DE CORREO (MX)" >> "$OUTPUT_FILE"
dig +short MX "$DOMINIO" >> "$OUTPUT_FILE"

echo -e "\n[FASE 4] SERVIDORES DNS (NS)" >> "$OUTPUT_FILE"
dig +short NS "$DOMINIO" >> "$OUTPUT_FILE"

echo -e "\n[*] INFORME COMPLETO GENERADO EN: $OUTPUT_FILE"
