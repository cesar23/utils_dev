#!/bin/bash

# ============================================================
#  INFORME DEL SERVIDOR DE CORREO — Postfix + Dovecot
#  Autor  : Ingeniero César Auris
#  Web    : https://solucionessystem.com
#  Tel    : 937516027
#  Genera : informe_server_mail.md
#
# curl -sSL https://raw.githubusercontent.com/cesar23/utils_dev/master/binarios/linux/util/informe_postfix.sh | bash
#
# ============================================================

VERSION="2.1"
VERSION_FECHA="2026-05-13"
VERSION_DESC="General multi-distro (Debian)"
# -------------------------------------------------------
# 🎨 COLORES
# -------------------------------------------------------
BGreen='\033[1;32m'
BYellow='\033[1;33m'
BRed='\033[1;31m'
BCyan='\033[1;36m'
BWhite='\033[1;37m'
Color_Off='\033[0m'


# -------------------------------------------------------
# FECHAS Y ARCHIVO DE SALIDA
# -------------------------------------------------------
_ts=$(date -u +%s 2>/dev/null)
_ts_pe=$(( _ts - 5 * 3600 ))
DATE_PE=$(date -u -d "@${_ts_pe}" "+%Y-%m-%d_%H:%M:%S" 2>/dev/null \
|| date -u "+%Y-%m-%d_%H:%M:%S")

INFORME="informe_postfix_mail.md"
> "$INFORME"   # limpia si existe

# -------------------------------------------------------
# FUNCIONES
# -------------------------------------------------------

# Encabezado de sección H2
seccion() {
echo -e "\n---\n" >> "$INFORME"
echo -e "## $1\n" >> "$INFORME"
}

# Subsección H3
subseccion() {
echo -e "\n### $1\n" >> "$INFORME"
}

# Ejecuta comando y lo muestra en bloque de código
cmd_md() {
local label="$1"; shift
echo -e "**${label}**\n" >> "$INFORME"
echo '```' >> "$INFORME"
  if command -v "$1" &>/dev/null; then
    "$@" 2>&1 >> "$INFORME"
  else
    echo "⚠ Comando '$1' no disponible." >> "$INFORME"
  fi
  echo '```' >> "$INFORME"
echo "" >> "$INFORME"
}

# Lee archivo y lo muestra en bloque de código
archivo_md() {
local label="$1"
local archivo="$2"
local lang="${3:-}"   # lenguaje opcional para resaltado
echo -e "**${label}** \`${archivo}\`\n" >> "$INFORME"
echo "\`\`\`${lang}" >> "$INFORME"
if [ -f "$archivo" ]; then
# Filtra líneas en blanco y comentarios para mayor claridad
grep -v '^\s*#' "$archivo" | grep -v '^\s*$' 2>/dev/null >> "$INFORME" || cat "$archivo" >> "$INFORME"
else
echo "⚠ Archivo no encontrado: $archivo" >> "$INFORME"
fi
echo '```' >> "$INFORME"
echo "" >> "$INFORME"
}

# Lee archivo completo (sin filtrar comentarios)
archivo_md_raw() {
local label="$1"
local archivo="$2"
local lang="${3:-}"
echo -e "**${label}** \`${archivo}\`\n" >> "$INFORME"
echo "\`\`\`${lang}" >> "$INFORME"
if [ -f "$archivo" ]; then
cat "$archivo" 2>&1 >> "$INFORME"
else
echo "⚠ Archivo no encontrado: $archivo" >> "$INFORME"
fi
echo '```' >> "$INFORME"
echo "" >> "$INFORME"
}

# Texto simple (sin bloque de código)
texto_md() {
local label="$1"; shift
echo -e "**${label}:** $*\n" >> "$INFORME"
}

# -------------------------------------------------------
# CABECERA DEL INFORME
# -------------------------------------------------------
cat >> "$INFORME" << EOF
# 📧 Informe del Servidor de Correo

| Campo        | Valor |
|---|---|
| **Servidor** | $(hostname -f 2>/dev/null || hostname) |
| **IP**       | $(hostname -I 2>/dev/null | awk '{print $1}') |
| **Fecha UTC**| $(date -u "+%Y-%m-%d %H:%M:%S UTC") |
| **Fecha PE** | ${DATE_PE} |
| **OS**       | $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"') |
| **Kernel**   | $(uname -r) |
| **Autor**    | Ing. César Auris — solucionessystem.com |

> Informe generado automáticamente. Incluye configuración de Postfix, Dovecot, estado de servicios, puertos y últimas entradas de log.

EOF

# ===============================================================
# 1. ESTADO DE SERVICIOS DE CORREO
# ===============================================================
seccion "1. Estado de Servicios de Correo"

subseccion "1.1 Postfix"
cmd_md "Estado del servicio Postfix" systemctl status postfix --no-pager -l

subseccion "1.2 Dovecot"
cmd_md "Estado del servicio Dovecot" systemctl status dovecot --no-pager -l

subseccion "1.3 OpenDKIM"
cmd_md "Estado del servicio OpenDKIM" systemctl status opendkim --no-pager -l

subseccion "1.4 SpamAssassin"
cmd_md "Estado SpamAssassin" systemctl status spamassassin --no-pager -l

subseccion "1.5 Spampd"
cmd_md "Estado Spampd" systemctl status spampd --no-pager -l

# ===============================================================
# 2. PUERTOS Y CONEXIONES DE CORREO
# ===============================================================
seccion "2. Puertos y Conexiones de Correo"

subseccion "2.1 Puertos escuchando (SMTP / IMAP / POP3)"
echo '```' >> "$INFORME"
ss -tulnp 2>/dev/null | grep -E ':(25|587|465|110|995|143|993)\s' >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "2.2 Conexiones activas en puertos de correo"
echo '```' >> "$INFORME"
ss -tnp state established 2>/dev/null | grep -E ':(25|587|465|110|995|143|993)\s' >> "$INFORME" || echo "Sin conexiones activas en puertos de correo." >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "2.3 Resumen de procesos de correo activos"
echo '```' >> "$INFORME"
ps aux 2>/dev/null | grep -E 'postfix|dovecot|opendkim|spampd|spamd|master' | grep -v grep >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

# ===============================================================
# 3. CONFIGURACIÓN POSTFIX
# ===============================================================
seccion "3. Configuración de Postfix"

subseccion "3.1 Versión de Postfix"
cmd_md "Versión instalada" postconf mail_version

subseccion "3.2 main.cf — Configuración principal (sin comentarios)"
archivo_md "Archivo principal de Postfix" /etc/postfix/main.cf

subseccion "3.3 master.cf — Servicios y puertos (sin comentarios)"
archivo_md "Servicios de Postfix" /etc/postfix/master.cf

subseccion "3.4 Mapa SSL (vmail_ssl.map)"
archivo_md_raw "Mapa SSL por dominio" /etc/postfix/vmail_ssl.map

subseccion "3.5 Configuración MySQL — Dominios virtuales"
archivo_md "Consulta MySQL: dominios" /etc/postfix/mysql-virtual_domains.cf

subseccion "3.6 Configuración MySQL — Email to Email"
archivo_md "Consulta MySQL: email2email" /etc/postfix/mysql-virtual_email2email.cf

subseccion "3.7 Configuración MySQL — Reenvíos"
archivo_md "Consulta MySQL: forwardings" /etc/postfix/mysql-virtual_forwardings.cf

subseccion "3.8 Configuración MySQL — Buzones"
archivo_md "Consulta MySQL: mailboxes" /etc/postfix/mysql-virtual_mailboxes.cf

subseccion "3.9 Parámetros activos relevantes (postconf)"
echo '```' >> "$INFORME"
postconf 2>/dev/null | grep -E \
  'myhostname|mydomain|myorigin|inet_interfaces|inet_protocols|
   smtpd_tls|smtp_tls|virtual_|transport_maps|relay|
   smtpd_recipient|smtpd_sasl|smtpd_milters|mynetworks|
   message_size_limit|mailbox_size|queue_directory|
   smtpd_helo|disable_vrfy|smtpd_banner|
   postscreen|spf|dkim|alias' \
  2>/dev/null >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

# ===============================================================
# 4. CONFIGURACIÓN DOVECOT
# ===============================================================
seccion "4. Configuración de Dovecot"

subseccion "4.1 Versión de Dovecot"
cmd_md "Versión instalada" dovecot --version

subseccion "4.2 dovecot.conf — Configuración principal"
archivo_md "Configuración principal Dovecot" /etc/dovecot/dovecot.conf

subseccion "4.3 Archivos conf.d/ (configuración por módulo)"

for f in /etc/dovecot/conf.d/*.conf; do
fname=$(basename "$f")
echo -e "\n#### \`${fname}\`\n" >> "$INFORME"
echo '```' >> "$INFORME"
  grep -v '^\s*#' "$f" | grep -v '^\s*$' 2>/dev/null >> "$INFORME" || cat "$f" >> "$INFORME"
  echo '```' >> "$INFORME"
echo "" >> "$INFORME"
done

# ===============================================================
# 5. REGISTROS DNS DEL DOMINIO (MX, SPF, DKIM, DMARC)
# ===============================================================
seccion "5. Registros DNS de Correo"

# Detectar dominios desde Postfix
DOMINIOS=$(postconf virtual_mailbox_domains 2>/dev/null \
| sed 's/virtual_mailbox_domains = //' \
| tr ',' '\n' | tr ' ' '\n' \
| grep -v 'mysql\|hash\|^$' \
| head -10)

if [ -z "$DOMINIOS" ]; then
DOMINIOS=$(postconf mydomain 2>/dev/null | awk '{print $3}')
fi

for DOMINIO in $DOMINIOS; do
[ -z "$DOMINIO" ] && continue
subseccion "DNS para: $DOMINIO"

echo '```' >> "$INFORME"
echo "▶ Registro MX:" >> "$INFORME"
dig MX "$DOMINIO" +short 2>/dev/null || host -t MX "$DOMINIO" 2>/dev/null || echo "No disponible"
echo "" >> "$INFORME"

echo "▶ Registro SPF (TXT):" >> "$INFORME"
dig TXT "$DOMINIO" +short 2>/dev/null | grep -i spf || echo "Sin registro SPF encontrado"
echo "" >> "$INFORME"

echo "▶ Registro DMARC:" >> "$INFORME"
dig TXT "_dmarc.${DOMINIO}" +short 2>/dev/null || echo "Sin registro DMARC encontrado"
echo "" >> "$INFORME"

echo "▶ Registro DKIM (selector 'default'):" >> "$INFORME"
dig TXT "default._domainkey.${DOMINIO}" +short 2>/dev/null || echo "Sin registro DKIM (selector default)"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"
done >> "$INFORME" 2>&1

# ===============================================================
# 6. COLAS DE CORREO
# ===============================================================
seccion "6. Colas de Correo (Postfix)"

subseccion "6.1 Resumen de colas"
cmd_md "Estado general de colas" postqueue -p

subseccion "6.2 Conteo de mensajes en cola"
echo '```' >> "$INFORME"
TOTAL=$(postqueue -p 2>/dev/null | tail -1)
echo "$TOTAL" >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "6.3 Mensajes diferidos (deferred) — primeros 20"
echo '```' >> "$INFORME"
postqueue -p 2>/dev/null | grep -A2 'Deferred' | head -40 >> "$INFORME" \
  || echo "No hay mensajes diferidos." >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

# ===============================================================
# 7. ESTADÍSTICAS Y ÚLTIMAS ENTRADAS DEL LOG
# ===============================================================
seccion "7. Logs de Correo (/var/log/mail.log)"

LOG_MAIL="/var/log/mail.log"

subseccion "77.1 Últimas 75 líneas del log"
echo '```' >> "$INFORME"
if [ -f "$LOG_MAIL" ]; then
  tail -75 "$LOG_MAIL" >> "$INFORME"
else
  echo "⚠ No se encontró $LOG_MAIL" >> "$INFORME"
fi
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "7.2 Errores recientes (últimas 24h)"
echo '```' >> "$INFORME"
if [ -f "$LOG_MAIL" ]; then
  grep -iE 'error|fatal|panic|reject|refused|timeout|bounced|failed' "$LOG_MAIL" \
    | tail -75 >> "$INFORME"
else
  echo "⚠ Log no disponible." >> "$INFORME"
fi
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "7.3 Intentos de autenticación fallidos"
echo '```' >> "$INFORME"
if [ -f "$LOG_MAIL" ]; then
  grep -iE 'authentication failed|SASL.*failed|535|LOGIN.*failed' "$LOG_MAIL" \
    | tail -50 >> "$INFORME" \
    || echo "Sin intentos fallidos recientes." >> "$INFORME"
else
  echo "⚠ Log no disponible." >> "$INFORME"
fi
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "7.4 Correos enviados exitosamente (status=sent)"
echo '```' >> "$INFORME"
if [ -f "$LOG_MAIL" ]; then
  grep 'status=sent' "$LOG_MAIL" | tail -40 >> "$INFORME" \
    || echo "Sin registros de envíos recientes." >> "$INFORME"
else
  echo "⚠ Log no disponible." >> "$INFORME"
fi
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "7.5 Correos rechazados (reject)"
echo '```' >> "$INFORME"
if [ -f "$LOG_MAIL" ]; then
  grep ' reject:' "$LOG_MAIL" | tail -40 >> "$INFORME" \
    || echo "Sin rechazos recientes." >> "$INFORME"
else
  echo "⚠ Log no disponible." >> "$INFORME"
fi
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "7.6 Resumen rápido de actividad (conteos)"
echo '```' >> "$INFORME"
if [ -f "$LOG_MAIL" ]; then
  echo "Correos enviados (status=sent):     $(grep -c 'status=sent'     "$LOG_MAIL" 2>/dev/null)"
  echo "Correos rebotados (status=bounced): $(grep -c 'status=bounced'  "$LOG_MAIL" 2>/dev/null)"
  echo "Correos diferidos (status=deferred):$(grep -c 'status=deferred' "$LOG_MAIL" 2>/dev/null)"
  echo "Rechazos (reject):                  $(grep -c ' reject:'        "$LOG_MAIL" 2>/dev/null)"
  echo "Errores SASL/auth:                  $(grep -ci 'sasl.*fail\|authentication failed' "$LOG_MAIL" 2>/dev/null)"
else
  echo "⚠ Log no disponible."
fi >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

# ===============================================================
# 8. CERTIFICADOS TLS
# ===============================================================
seccion "8. Certificados TLS"

subseccion "8.1 Certificados configurados en Postfix"
echo '```' >> "$INFORME"
postconf 2>/dev/null | grep -E 'tls_cert_file|tls_key_file|tls_CAfile|tls_security_level' >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "8.2 Vencimiento de certificados TLS"
echo '```' >> "$INFORME"
{
  CERT=$(postconf smtpd_tls_cert_file 2>/dev/null | awk '{print $3}')
  if [ -n "$CERT" ] && [ -f "$CERT" ]; then
    echo "Certificado: $CERT"
    openssl x509 -in "$CERT" -noout -subject -issuer -dates 2>/dev/null
  else
    echo "No se encontró smtpd_tls_cert_file o el archivo no existe: $CERT"
  fi
} >> "$INFORME"

echo "" >> "$INFORME"
echo '```' >> "$INFORME"

# Certificados del mapa SSL si existe
if [ -f /etc/postfix/vmail_ssl.map ]; then
echo "Certificados en vmail_ssl.map:" >> "$INFORME"
while read -r linea; do
[[ "$linea" =~ ^# ]] && continue
[[ -z "$linea" ]] && continue
cert_file=$(echo "$linea" | awk '{print $2}' | cut -d: -f1)
[ -f "$cert_file" ] && {
echo "  → $cert_file"
openssl x509 -in "$cert_file" -noout -subject -dates 2>/dev/null | sed 's/^/    /'
}
done < /etc/postfix/vmail_ssl.map
fi >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

# ===============================================================
# 9. OPENDKIM
# ===============================================================
seccion "9. OpenDKIM"

subseccion "9.1 Configuración OpenDKIM"
archivo_md_raw "Configuración OpenDKIM" /etc/opendkim.conf

subseccion "9.2 Tabla de claves DKIM"
echo '```' >> "$INFORME"
KEYTABLE=$(grep -i 'KeyTable' /etc/opendkim.conf 2>/dev/null | awk '{print $2}')
if [ -n "$KEYTABLE" ] && [ -f "$KEYTABLE" ]; then
cat "$KEYTABLE" 2>/dev/null
else
# Rutas comunes
for ruta in /etc/opendkim/key.table /etc/opendkim/KeyTable; do
[ -f "$ruta" ] && cat "$ruta" && break
done || echo "No se encontró KeyTable."
fi >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "9.3 Tabla de firmas (SigningTable)"
echo '```' >> "$INFORME"
SIGNTABLE=$(grep -i 'SigningTable' /etc/opendkim.conf 2>/dev/null | awk '{print $2}' | sed 's/refile://')
if [ -n "$SIGNTABLE" ] && [ -f "$SIGNTABLE" ]; then
  cat "$SIGNTABLE" 2>/dev/null
else
  for ruta in /etc/opendkim/signing.table /etc/opendkim/SigningTable; do
    [ -f "$ruta" ] && cat "$ruta" && break
  done || echo "No se encontró SigningTable."
fi >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

# ===============================================================
# 10. BUZONES Y USUARIOS DE CORREO
# ===============================================================
seccion "10. Buzones y Usuarios de Correo"

subseccion "10.1 Uso de disco — directorio de buzones"
echo '```' >> "$INFORME"
VMAIL_DIR=$(postconf virtual_mailbox_base 2>/dev/null | awk '{print $3}')
[ -z "$VMAIL_DIR" ] && VMAIL_DIR="/home/vmail"
if [ -d "$VMAIL_DIR" ]; then
  echo "Directorio de buzones: $VMAIL_DIR"
  du -sh "$VMAIL_DIR"/* 2>/dev/null | sort -rh | head -20
else
  echo "Directorio de buzones no encontrado: $VMAIL_DIR"
fi >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "10.2 Total de buzones (desde MySQL)"
echo '```' >> "$INFORME"
DB_CONF="/etc/postfix/mysql-virtual_mailboxes.cf"
if [ -f "$DB_CONF" ]; then
DB_USER=$(grep '^user'     "$DB_CONF" | awk '{print $3}')
DB_PASS=$(grep '^password' "$DB_CONF" | awk '{print $3}')
DB_NAME=$(grep '^dbname'   "$DB_CONF" | awk '{print $3}')
DB_HOST=$(grep '^hosts'    "$DB_CONF" | awk '{print $3}')
DB_QUERY=$(grep '^query'   "$DB_CONF" | sed 's/query = //')

if [ -n "$DB_USER" ] && [ -n "$DB_NAME" ]; then
mysql -u"$DB_USER" -p"$DB_PASS" -h"${DB_HOST:-127.0.0.1}" "$DB_NAME" \
-e "SELECT COUNT(*) AS total_buzones FROM mailbox;" 2>/dev/null \
|| echo "No se pudo conectar a MySQL para contar buzones."
else
echo "No se pudo leer credenciales de $DB_CONF"
fi
else
echo "Archivo $DB_CONF no encontrado."
fi >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

subseccion "10.3 Dominios virtuales (desde MySQL)"
echo '```' >> "$INFORME"
DB_CONF_DOM="/etc/postfix/mysql-virtual_domains.cf"
if [ -f "$DB_CONF_DOM" ]; then
DB_USER=$(grep '^user'     "$DB_CONF_DOM" | awk '{print $3}')
DB_PASS=$(grep '^password' "$DB_CONF_DOM" | awk '{print $3}')
DB_NAME=$(grep '^dbname'   "$DB_CONF_DOM" | awk '{print $3}')
DB_HOST=$(grep '^hosts'    "$DB_CONF_DOM" | awk '{print $3}')

if [ -n "$DB_USER" ] && [ -n "$DB_NAME" ]; then
mysql -u"$DB_USER" -p"$DB_PASS" -h"${DB_HOST:-127.0.0.1}" "$DB_NAME" \
-e "SELECT domain, active FROM domain ORDER BY domain;" 2>/dev/null \
|| echo "No se pudo conectar a MySQL para listar dominios."
else
echo "No se pudo leer credenciales de $DB_CONF_DOM"
fi
else
echo "Archivo $DB_CONF_DOM no encontrado."
fi >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

# ===============================================================
# 11. REGLAS DE FIREWALL RELACIONADAS AL CORREO
# ===============================================================
seccion "11. Reglas de Firewall — Puertos de Correo"

echo '```' >> "$INFORME"
{
  iptables -L -n -v 2>/dev/null \
    | grep -E ':25|:587|:465|:143|:993|:110|:995' \
    || echo "No se encontraron reglas de correo en iptables."
} >> "$INFORME"
echo '```' >> "$INFORME"
echo "" >> "$INFORME"

# ===============================================================
# 12. RESUMEN FINAL Y RECOMENDACIONES
# ===============================================================
seccion "12. Resumen Final"

echo '```' >> "$INFORME"
echo "=== RESUMEN DEL SERVIDOR DE CORREO ===" >> "$INFORME"
echo "" >> "$INFORME"
echo "Hostname  : $(hostname -f 2>/dev/null || hostname)" >> "$INFORME"
echo "IP pública: $(hostname -I 2>/dev/null | awk '{print $1}')" >> "$INFORME"
echo "" >> "$INFORME"

# Estado de servicios clave
for SVC in postfix dovecot opendkim spamassassin spampd; do
STATUS=$(systemctl is-active "$SVC" 2>/dev/null)
ICON="✅"
[ "$STATUS" != "active" ] && ICON="❌"
printf "${ICON}  %-20s %s\n" "$SVC" "$STATUS" >> "$INFORME"
done

echo "" >> "$INFORME"
echo "Puertos escuchando:" >> "$INFORME"
ss -tulnp 2>/dev/null \
| grep -E ':(25|587|465|110|995|143|993)\s' \
| awk '{print "  " $5 " → " $7}' >> "$INFORME"

echo "" >> "$INFORME"
if [ -f "$LOG_MAIL" ]; then
echo "Actividad del log:" >> "$INFORME"
echo "  Enviados    : $(grep -c 'status=sent'     "$LOG_MAIL" 2>/dev/null)" >> "$INFORME"
echo "  Diferidos   : $(grep -c 'status=deferred' "$LOG_MAIL" 2>/dev/null)" >> "$INFORME"
echo "  Rebotados   : $(grep -c 'status=bounced'  "$LOG_MAIL" 2>/dev/null)" >> "$INFORME"
echo "  Rechazados  : $(grep -c ' reject:'        "$LOG_MAIL" 2>/dev/null)" >> "$INFORME"
fi

echo '```' >> "$INFORME"

# PIE DEL INFORME
cat >> "$INFORME" << 'EOF'

---

> **Generado por:** informe_postfix.sh
> **Autor:** Ing. César Auris — [solucionessystem.com](https://solucionessystem.com) — Tel: 937516027
> _Este informe es confidencial. Contiene configuración sensible del servidor de correo._
EOF

# -------------------------------------------------------
# MENSAJE FINAL EN CONSOLA
# -------------------------------------------------------

# -------------------------------------------------------
# 📝 ENCABEZADO DEL INFORME
# -------------------------------------------------------
echo -e "${BYellow}Iniciando generación del informe Postfix...${Color_Off}"
echo -e "${BCyan}  Versión : ${BWhite}v${VERSION}${BCyan} (${VERSION_FECHA}) — ${VERSION_DESC}${Color_Off}"
echo ""
echo ""
echo "✅ Informe generado: $INFORME"
echo "   Puedes verlo con:  cat $INFORME"
echo "   O abrirlo en un editor Markdown compatible."
echo ""