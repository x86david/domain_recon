
# 🔎 Automatic Domain Infrastructure Recon – `recon.sh`  
### DNS Footprinting • Subdomain Enumeration • WHOIS/RDAP • ASN Mapping

This repository contains a Bash script designed to perform a **full infrastructure reconnaissance** of any domain.  
It automates the essential phases of a real‑world footprinting workflow:

- **Phase 1:** WHOIS / RDAP lookup  
- **Phase 2:** Subdomain enumeration (OSINT passive + brute force)  
- **Phase 3:** IP resolution, WHOIS by IP, ASN and network range discovery  
- **Phase 4:** MX and NS extraction  

The script generates a complete, ready‑to‑use report for penetration testing, OSINT investigations, or academic work.

---

## 🚀 Features

✔ Fully automated reconnaissance  
✔ Works with **any domain**  
✔ Intelligent WHOIS fallback (handles TLDs without WHOIS, like `.es`)  
✔ Advanced subdomain enumeration using:  
- **Subfinder**  
- **Amass**  
- **dnsrecon**  
- **Fierce**  
- **crt.sh**  

✔ Automatic installation of all required tools  
✔ Subdomain resolution + IP extraction  
✔ WHOIS + ASN mapping for each public IP  
✔ MX and NS enumeration  
✔ Clean folder structure per domain  
✔ Final report in plain text  

---

## 📦 Automatic Installation

The script automatically installs:

- subfinder  
- amass  
- dnsrecon  
- fierce  
- jq  
- whois  
- dig (dnsutils)  
- curl  
- Go (if needed for Subfinder)

No manual setup required.

---

## 🧩 Usage

Make the script executable:

```bash
chmod +x recon.sh
```

Run it with any domain:

```bash
./recon.sh domain.com
```

Example:

```bash
./recon.sh ual.es
```

This will generate:

```
ual.es/
 ├── REPORT_ual.es.txt
 └── subdomains/
      ├── subfinder.txt
      ├── amass.txt
      ├── dnsrecon.txt
      ├── fierce.txt
      ├── crtsh.txt
      ├── all.txt
      └── resolved.txt
```

---

## 📁 Report Structure

### **PHASE 1 – WHOIS / RDAP**
- Registrant  
- Organization  
- Registrar  
- Name servers  
- RDAP fallback for unsupported TLDs  

### **PHASE 2 – Subdomain Enumeration**
- Subdomains discovered  
- Source tools  
- Resolved IPs  

### **PHASE 3 – ASN / Network Ranges**
- WHOIS by IP  
- NetRange / inetnum  
- ASN (origin / originAS)  
- Provider information  

### **PHASE 4 – MX / NS**
- Mail servers  
- Authoritative DNS servers  

---

## 🛠 Requirements

Compatible with:

- Kali Linux  
- Debian / Ubuntu  
- Any apt‑based distribution  

The script handles all dependencies automatically.

---

## 🎯 Purpose

This tool is ideal for:

- Cybersecurity students  
- Pentesters  
- OSINT analysts  
- Red teamers  
- Infrastructure mapping  
- Academic assignments involving DNS footprinting  

---

## ⚠ Legal Disclaimer

This script is intended **only for authorized security testing, research, and educational use**.  
Running it against systems you do not own or have explicit permission to test may be illegal.

---

## 🤝 Author

**David Pérez**  
Cybersecurity · OSINT · Automation

---
