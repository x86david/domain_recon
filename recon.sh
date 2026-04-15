#!/bin/bash

# ============================================
#  Automatic Domain Infrastructure Recon Tool
#  DNS + WHOIS + ASN + MX/NS + Auto‑Installation
#  Author: Flex (David Pérez)
#  Usage: ./infra_recon.sh domain.com
# ============================================

if [ -z "$1" ]; then
    echo "Usage: $0 domain.com"
    exit 1
fi

DOMAIN="$1"
TLD="${DOMAIN##*.}"

BASE_DIR="$(pwd)/$DOMAIN"
SUB_DIR="$BASE_DIR/subdomains"
OUTPUT_FILE="$BASE_DIR/REPORT_$DOMAIN.txt"

mkdir -p "$BASE_DIR" "$SUB_DIR"

echo "[*] Starting analysis for $DOMAIN..."
echo "[*] Directory created: $BASE_DIR"

# ============================================
# AUTOMATIC TOOL INSTALLATION
# ============================================

echo "[*] Installing required tools..."

sudo apt update -y
sudo apt install -y whois dnsutils dnsrecon fierce jq curl

# Install Subfinder if missing
if ! command -v subfinder >/dev/null 2>&1; then
    echo "[*] Installing Subfinder..."
    sudo apt install -y golang-go
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    sudo cp ~/go/bin/subfinder /usr/local/bin/
fi

# Install Amass if missing
if ! command -v amass >/dev/null 2>&1; then
    echo "[*] Installing Amass..."
    sudo snap install amass
fi

echo "[*] All tools installed successfully."

# ============================================
# PHASE 1 - WHOIS / RDAP
# ============================================

echo "==================================================" > "$OUTPUT_FILE"
echo "INFRASTRUCTURE REPORT: $DOMAIN" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"

echo -e "\n[PHASE 1] WHOIS / RDAP" >> "$OUTPUT_FILE"

WHOIS_DATA=$(whois "$DOMAIN" 2>/dev/null)

if echo "$WHOIS_DATA" | grep -qi "no whois server"; then
    echo "[!] Traditional WHOIS not available for .$TLD" >> "$OUTPUT_FILE"

    if [ "$TLD" = "es" ]; then
        echo "[*] .es domains do not expose standard WHOIS." >> "$OUTPUT_FILE"
        echo "[*] Manual lookup recommended:" >> "$OUTPUT_FILE"
        echo "    https://www.dominios.es/es/dominios/whois?dominio=$DOMAIN" >> "$OUTPUT_FILE"
    else
        echo "[*] Trying generic RDAP..." >> "$OUTPUT_FILE"
        RDAP=$(curl -s "https://rdap.org/domain/$DOMAIN")
        if [ -n "$RDAP" ]; then
            echo "$RDAP" >> "$OUTPUT_FILE"
        else
            echo "[!] RDAP not available for this TLD." >> "$OUTPUT_FILE"
        fi
    fi
else
    echo "$WHOIS_DATA" | grep -E "Registrant|Organization|OrgName|Name Server|Registrar|Country" >> "$OUTPUT_FILE"
fi

# ============================================
# PHASE 2 - SUBDOMAIN ENUMERATION
# ============================================

echo -e "\n[PHASE 2] ENUMERATED HOSTS" >> "$OUTPUT_FILE"
echo -e "HOST|IP" >> "$OUTPUT_FILE"

echo "[*] Enumerating subdomains for $DOMAIN..."

# 1. Subfinder
echo "[*] Running Subfinder..."
subfinder -silent -d "$DOMAIN" > "$SUB_DIR/subfinder.txt"

# 2. Amass
echo "[*] Running Amass..."
amass enum -passive -d "$DOMAIN" > "$SUB_DIR/amass.txt"

# 3. dnsrecon
echo "[*] Running dnsrecon..."
dnsrecon -d "$DOMAIN" -t brt -D /usr/share/wordlists/dnsmap.txt > "$SUB_DIR/dnsrecon_raw.txt"
grep -oP "([a-zA-Z0-9_-]+\.)+$DOMAIN" "$SUB_DIR/dnsrecon_raw.txt" | sort -u > "$SUB_DIR/dnsrecon.txt"

# 4. Fierce
echo "[*] Running Fierce..."
fierce --domain "$DOMAIN" > "$SUB_DIR/fierce_raw.txt"
grep -oP "([a-zA-Z0-9_-]+\.)+$DOMAIN" "$SUB_DIR/fierce_raw.txt" | sort -u > "$SUB_DIR/fierce.txt"

# 5. crt.sh
echo "[*] Querying crt.sh..."
curl -s "https://crt.sh/?q=$DOMAIN&output=json" \
    | jq -r '.[].name_value' 2>/dev/null \
    | sed 's/\*\.//g' \
    | grep -E "([a-zA-Z0-9_-]+\.)+$DOMAIN" \
    | sort -u > "$SUB_DIR/crtsh.txt"

# 6. Merge all results
cat "$SUB_DIR"/*.txt 2>/dev/null | sort -u > "$SUB_DIR/all.txt"

# 7. Resolve subdomains
echo "[*] Resolving subdomains..."
> "$SUB_DIR/resolved.txt"

while read -r sub; do
    [ -z "$sub" ] && continue
    ip=$(dig +short "$sub" | head -n1)
    if [ -n "$ip" ]; then
        echo "$sub|$ip" | tee -a "$SUB_DIR/resolved.txt" >> "$OUTPUT_FILE"
    fi
done < "$SUB_DIR/all.txt"

# ============================================
# PHASE 3 - ASN / NETWORK RANGES
# ============================================

echo -e "\n[PHASE 3] ASN / NETWORK RANGES" >> "$OUTPUT_FILE"

UNIQUE_IPS=$(cut -d'|' -f2 "$SUB_DIR/resolved.txt" | grep -E "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$" | sort -u)

if [ -z "$UNIQUE_IPS" ]; then
    echo "[!] No public IPs found for ASN analysis." >> "$OUTPUT_FILE"
else
    for ip in $UNIQUE_IPS; do
        echo "=== $ip ===" >> "$OUTPUT_FILE"
        whois "$ip" 2>/dev/null | grep -E "inetnum|NetRange|CIDR|route|origin|OriginAS|descr|Organization|OrgName" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done
fi

# ============================================
# PHASE 4 - MX / NS
# ============================================

echo -e "\n[PHASE 4] MAIL SERVERS (MX)" >> "$OUTPUT_FILE"
dig +short MX "$DOMAIN" >> "$OUTPUT_FILE"

echo -e "\n[PHASE 4] DNS SERVERS (NS)" >> "$OUTPUT_FILE"
dig +short NS "$DOMAIN" >> "$OUTPUT_FILE"

echo -e "\n[*] FULL REPORT GENERATED AT: $OUTPUT_FILE"
echo "[*] Subdomain data stored in: $SUB_DIR"
