

# **🔎 Infraestructura Automática – Footprinting DNS & Recon-ng**

Este script permite realizar un **análisis completo de infraestructura** para cualquier dominio, automatizando las fases típicas de footprinting:

- WHOIS  
- Enumeración DNS  
- Descubrimiento de hosts  
- Resolución de IPs  
- Rangos ASN  
- Servidores MX / NS  
- Informe final listo para entregar  

Ideal para prácticas de ciberseguridad, OSINT, pentesting o auditorías de superficie de ataque.

---

## 🚀 **Características**

✔️ Totalmente automático  
✔️ Acepta **cualquier dominio por parámetro**  
✔️ Crea una carpeta independiente por dominio  
✔️ Usa Recon-ng para brute-force + resolución  
✔️ Extrae WHOIS, rangos ASN, MX, NS  
✔️ Genera un informe final en texto plano  
✔️ No requiere modificar el script para cada dominio  

---

## 📦 **Requisitos**

Debes tener instalados:

- `recon-ng`
- `sqlite3`
- `whois`
- `dig` (dnsutils)
- Linux (Kali recomendado)

Instalación rápida:

```bash
sudo apt install recon-ng whois dnsutils sqlite3 -y
```

---

## 🧩 **Uso**

Ejecuta el script indicando el dominio:

```bash
./infra_recon.sh dominio.com
```

Ejemplo:

```bash
./infra_recon.sh ual.es
```

Esto generará:

```
ual.es/
 ├── auto_run.rc
 ├── INFORME_ual.es.txt
 ├── (workspace Recon-ng)
```

---

## 📁 **Estructura generada**

```
dominio.com/
 ├── auto_run.rc
 ├── INFORME_dominio.com.txt
 ├── workspace Recon-ng (interno)
```

---

## 📄 **Contenido del informe**

El informe incluye:

### **FASE 1 – WHOIS**
- Titular
- Organización
- Servidores DNS

### **FASE 2 – Enumeración**
- Hosts descubiertos
- IPs asociadas

### **FASE 3 – Rangos ASN**
- Bloques de red
- Proveedor
- ASN

### **FASE 4 – Clasificación**
- Servidores MX
- Servidores DNS

---

## 🛠️ **Personalización**

Puedes modificar:

- Nombre del workspace
- Formato del informe
- Módulos de Recon-ng
- Filtros WHOIS

Todo está claramente marcado en el script.

---

## 📜 **Licencia**

MIT License — úsalo, modifícalo y compártelo libremente.

---

## 🤝 **Autor**

**David Pérez**  
Auditoría de Infraestructura – OSINT – Ciberseguridad

---
