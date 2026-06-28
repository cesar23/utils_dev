#!/bin/bash

# ============================================================
#  INFORME COMPLETO DE CYBERPANEL + OPENLITESPEED
#  Autor  : Ingeniero César Auris
#  Web    : https://solucionessystem.com
#  Tel    : 937516027
#
# curl -sSL https://raw.githubusercontent.com/cesar23/utils_dev/master/binarios/linux/util/informe_litespeed_cyberpanel.sh| bash
#
# ============================================================

VERSION="1.0"
VERSION_FECHA="2026-06-28"
VERSION_DESC="Informe especializado CyberPanel + OpenLiteSpeed"

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
# 🕒 FECHAS
# -------------------------------------------------------
DATE_LOCAL=$(date "+%Y-%m-%d_%H:%M:%S")
_ts=$(date -u +%s 2>/dev/null)
if [ -n "$_ts" ]; then
  _ts_pe=$(( _ts - 5 * 3600 ))
  DATE_PE=$(date -u -d "@${_ts_pe}" "+%Y-%m-%d_%H:%M:%S" 2>/dev/null \
         || date -r "${_ts_pe}" "+%Y-%m-%d_%H:%M:%S" 2>/dev/null \
         || date -u "+%Y-%m-%d_%H:%M:%S")
else
  DATE_PE=$(date -u "+%Y-%m-%d_%H:%M:%S")
fi
INFORME="informe_cyberpanel_litespeed_${DATE_PE}.log"

# -------------------------------------------------------
# 📁 RUTAS BASE (CyberPanel / OpenLiteSpeed)
# -------------------------------------------------------
LSWS_HOME="/usr/local/lsws"
LSWS_CONF="${LSWS_HOME}/conf"
LSWS_VHOSTS="${LSWS_CONF}/vhosts"
CYBERCP_HOME="/usr/local/CyberCP"
CYBERPANEL_LOG_DIR="/home/cyberpanel"

# -------------------------------------------------------
# 🔧 FUNCIONES AUXILIARES
# -------------------------------------------------------

titulo() {
  echo -e "\n\n╔══════════════════════════════════════════════╗" >> "$INFORME"
  printf   "║  %-44s║\n" " $1" >> "$INFORME"
  echo -e   "╚══════════════════════════════════════════════╝\n" >> "$INFORME"
}

subtitulo() {
  echo -e "\n── $1 ──────────────────────────────\n" >> "$INFORME"
}

separador() {
  echo -e "\n────────────────────────────────────────────────\n" >> "$INFORME"
}

# Ejecuta un comando solo si existe; si no, imprime aviso
cmd_run() {
  local label="$1"; shift
  echo -e "▶ $label:" >> "$INFORME"
  if command -v "$1" &>/dev/null; then
    "$@" >> "$INFORME" 2>&1
  else
    echo "  ⚠ Comando '$1' no disponible en este sistema." >> "$INFORME"
  fi
  echo "" >> "$INFORME"
}

# Lee un archivo si existe (completo)
leer_archivo() {
  local label="$1"
  local archivo="$2"
  echo -e "▶ $label" >> "$INFORME"
  echo "  Ruta: $archivo" >> "$INFORME"
  if [ -f "$archivo" ]; then
    echo "  ---------------------------------------------" >> "$INFORME"
    cat "$archivo" >> "$INFORME" 2>&1
    echo "  ---------------------------------------------" >> "$INFORME"
  else
    echo "  ⚠ Archivo no encontrado." >> "$INFORME"
  fi
  echo "" >> "$INFORME"
}

# Lee solo las últimas N líneas de un archivo (para logs largos)
leer_archivo_tail() {
  local label="$1"
  local archivo="$2"
  local lineas="${3:-40}"
  echo -e "▶ $label (últimas $lineas líneas)" >> "$INFORME"
  echo "  Ruta: $archivo" >> "$INFORME"
  if [ -f "$archivo" ]; then
    echo "  ---------------------------------------------" >> "$INFORME"
    tail -n "$lineas" "$archivo" >> "$INFORME" 2>&1
    echo "  ---------------------------------------------" >> "$INFORME"
  else
    echo "  ⚠ Archivo no encontrado." >> "$INFORME"
  fi
  echo "" >> "$INFORME"
}

# Detecta si hay sudo disponible sin contraseña
TIENE_SUDO=false
if sudo -n true 2>/dev/null; then
  TIENE_SUDO=true
fi

sudo_run() {
  local label="$1"; shift
  echo -e "▶ $label:" >> "$INFORME"
  if $TIENE_SUDO; then
    sudo "$@" >> "$INFORME" 2>&1
  else
    echo "  ⚠ Se requiere sudo para: $*" >> "$INFORME"
  fi
  echo "" >> "$INFORME"
}

# Ejecuta consulta MySQL contra la BD cyberpanel usando /root/.my.cnf si existe
mysql_cyberpanel() {
  local label="$1"
  local query="$2"
  echo -e "▶ $label:" >> "$INFORME"
  if command -v mysql &>/dev/null; then
    if [ -f /root/.my.cnf ] && $TIENE_SUDO; then
      sudo mysql --defaults-extra-file=/root/.my.cnf -e "$query" cyberpanel >> "$INFORME" 2>&1
    elif $TIENE_SUDO; then
      sudo mysql -e "$query" cyberpanel >> "$INFORME" 2>&1
    else
      echo "  ⚠ Se requiere sudo/credenciales para consultar MySQL." >> "$INFORME"
    fi
  else
    echo "  ⚠ Cliente 'mysql' no disponible." >> "$INFORME"
  fi
  echo "" >> "$INFORME"
}

# -------------------------------------------------------
# 📝 ENCABEZADO DEL INFORME
# -------------------------------------------------------
echo -e "${BYellow}Iniciando generación del informe de CyberPanel + OpenLiteSpeed...${Color_Off}"
echo -e "${BCyan}  Versión : ${BWhite}v${VERSION}${BCyan} (${VERSION_FECHA}) — ${VERSION_DESC}${Color_Off}"
echo ""

cat > "$INFORME" <<EOF
╔═══════════════════════════════════════════════════════╗
║   INFORME COMPLETO DE CYBERPANEL + OPENLITESPEED       ║
╠═══════════════════════════════════════════════════════╣
║  Versión      : $VERSION ($VERSION_FECHA)
║  Descripción  : $VERSION_DESC
╠═══════════════════════════════════════════════════════╣
║  Fecha local  : $DATE_LOCAL
║  Fecha Perú   : $DATE_PE
╠═══════════════════════════════════════════════════════╣
║  Desarrollado por : Ingeniero César Auris             ║
║  Teléfono         : 937516027                         ║
║  Website          : https://solucionessystem.com      ║
╚═══════════════════════════════════════════════════════╝

EOF

# ============================================================
# 1. INFORMACIÓN BÁSICA DEL SERVIDOR
# ============================================================
titulo "1. INFORMACIÓN BÁSICA DEL SERVIDOR"

echo -e "▶ Hostname y sistema operativo:" >> "$INFORME"
echo "  Hostname  : $(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null)" >> "$INFORME"
echo "  FQDN      : $(hostname -f 2>/dev/null)" >> "$INFORME"
echo "" >> "$INFORME"

leer_archivo "Distribución y versión (OS Release)" "/etc/os-release"

echo -e "▶ Kernel y arquitectura (uname -a):" >> "$INFORME"
uname -a >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Uptime y carga del sistema:" >> "$INFORME"
uptime >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Recursos generales:" >> "$INFORME"
echo "  CPU(s)    : $(nproc 2>/dev/null)" >> "$INFORME"
free -h >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Uso de disco (df -hT):" >> "$INFORME"
df -hT >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ IP pública / privada del servidor:" >> "$INFORME"
echo "  IP detectada por 'hostname -I' : $(hostname -I 2>/dev/null)" >> "$INFORME"
if command -v ip &>/dev/null; then
  ip -4 addr show | grep -E "inet " >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 2. CYBERPANEL — INFORMACIÓN GENERAL Y VERSIÓN
# ============================================================
titulo "2. CYBERPANEL — INFORMACIÓN GENERAL"

echo -e "▶ Versión instalada de CyberPanel:" >> "$INFORME"
if [ -f "${CYBERCP_HOME}/version" ]; then
  cat "${CYBERCP_HOME}/version" >> "$INFORME"
elif command -v cyberpanel &>/dev/null; then
  cyberpanel version >> "$INFORME" 2>&1
else
  echo "  ⚠ No se encontró /usr/local/CyberCP/version ni el comando 'cyberpanel'." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Estado del servicio CyberPanel (lscpd):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo systemctl status lscpd --no-pager >> "$INFORME" 2>&1
else
  systemctl status lscpd --no-pager >> "$INFORME" 2>&1
fi
echo "" >> "$INFORME"

echo -e "▶ Estructura de directorios de CyberPanel (1 nivel):" >> "$INFORME"
ls -la "$CYBERCP_HOME" 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Cron de CyberPanel (crontab de root):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo crontab -l -u root 2>/dev/null >> "$INFORME" || echo "  Sin tareas cron para root." >> "$INFORME"
else
  echo "  ⚠ Se requiere sudo para ver el crontab de root." >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 3. OPENLITESPEED — INFORMACIÓN GENERAL Y SERVICIO
# ============================================================
titulo "3. OPENLITESPEED — INFORMACIÓN GENERAL"

echo -e "▶ Versión de OpenLiteSpeed:" >> "$INFORME"
if [ -x "${LSWS_HOME}/bin/openlitespeed" ]; then
  "${LSWS_HOME}/bin/openlitespeed" -v >> "$INFORME" 2>&1
else
  echo "  ⚠ Binario no encontrado en ${LSWS_HOME}/bin/openlitespeed" >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Estado del servicio LiteSpeed (lsws):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo systemctl status lsws --no-pager >> "$INFORME" 2>&1
else
  systemctl status lsws --no-pager >> "$INFORME" 2>&1
fi
echo "" >> "$INFORME"

echo -e "▶ Procesos de LiteSpeed en ejecución:" >> "$INFORME"
ps aux | grep -i "[l]itespeed\|[l]shttpd" >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Puertos en escucha relacionados a LiteSpeed (80/443/7080/8090):" >> "$INFORME"
ss -tulnp 2>/dev/null | grep -E ":80 |:443 |:7080 |:8090 " >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 4. ESTRUCTURA DE DIRECTORIOS DE OPENLITESPEED
# ============================================================
titulo "4. ESTRUCTURA DE DIRECTORIOS — OPENLITESPEED"

echo -e "▶ Árbol general de ${LSWS_HOME} (2 niveles):" >> "$INFORME"
find "$LSWS_HOME" -maxdepth 2 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Comando: ls /usr/local/lsws/conf" >> "$INFORME"
echo "  (directorio principal de configuración de OpenLiteSpeed)" >> "$INFORME"
echo "  ---------------------------------------------" >> "$INFORME"
ls -la "$LSWS_CONF" 2>/dev/null >> "$INFORME"
echo "  ---------------------------------------------" >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Comando: cd /usr/local/lsws/conf/vhosts  &&  ls -la" >> "$INFORME"
echo "  (carpetas de virtual hosts — un directorio por dominio configurado)" >> "$INFORME"
echo "  ---------------------------------------------" >> "$INFORME"
ls -la "$LSWS_VHOSTS" 2>/dev/null >> "$INFORME"
echo "  ---------------------------------------------" >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Resumen — dominios detectados como carpetas en vhosts/:" >> "$INFORME"
if [ -d "$LSWS_VHOSTS" ]; then
  for dom in "$LSWS_VHOSTS"/*/; do
    echo "  [$(basename "$dom")]" >> "$INFORME"
  done
else
  echo "  ⚠ No se encontró el directorio $LSWS_VHOSTS" >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Versiones de PHP (lsphp) instaladas:" >> "$INFORME"
ls -d "${LSWS_HOME}"/lsphp* 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 5. CONFIGURACIÓN PRINCIPAL — httpd_config.conf
# ============================================================
titulo "5. CONFIGURACIÓN PRINCIPAL — httpd_config.conf"

leer_archivo "Configuración global del servidor (httpd_config.conf)" "${LSWS_CONF}/httpd_config.conf"

subtitulo "Listeners detectados (resumen)"
echo -e "▶ Bloques 'listener' encontrados:" >> "$INFORME"
grep -n "^listener\|^  listener" "${LSWS_CONF}/httpd_config.conf" 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Mapas de dominio (map) por listener:" >> "$INFORME"
grep -n "map " "${LSWS_CONF}/httpd_config.conf" 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Bloques 'virtualHost' declarados:" >> "$INFORME"
grep -n "^virtualHost\|^  virtualHost" "${LSWS_CONF}/httpd_config.conf" 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 6. VIRTUAL HOSTS — vhost.conf POR DOMINIO
# ============================================================
titulo "6. VIRTUAL HOSTS — vhost.conf POR DOMINIO"

echo -e "▶ Dominios con virtual host configurado (carpetas en ${LSWS_VHOSTS}):" >> "$INFORME"
if [ -d "$LSWS_VHOSTS" ]; then
  for dom in "$LSWS_VHOSTS"/*/; do
    echo "  [$(basename "$dom")]" >> "$INFORME"
  done
else
  echo "  ⚠ No se encontró el directorio $LSWS_VHOSTS" >> "$INFORME"
fi
echo "" >> "$INFORME"

# -----------------------------------------------------------
# Host por defecto primero, siempre destacado (responde
# peticiones que no coinciden con ningún dominio mapeado)
# -----------------------------------------------------------
subtitulo "VHOST POR DEFECTO — [default]"
echo -e "▶ Ruta: ${LSWS_VHOSTS}/default/vhost.conf" >> "$INFORME"
leer_archivo "vhost.conf — [default]" "${LSWS_VHOSTS}/default/vhost.conf"

# -----------------------------------------------------------
# Resto de dominios (todo lo que no sea 'default'), cada uno
# con su ruta completa y contenido íntegro de vhost.conf
# -----------------------------------------------------------
echo -e "▶ Detalle completo de cada vhost.conf por dominio:" >> "$INFORME"
echo "" >> "$INFORME"

if [ -d "$LSWS_VHOSTS" ]; then
  for dom in "$LSWS_VHOSTS"/*/; do
    dominio=$(basename "$dom")
    if [ "$dominio" = "default" ]; then
      continue  # ya se mostró arriba
    fi
    vhostfile="${dom}vhost.conf"
    subtitulo "[$dominio]"
    echo -e "▶ Ruta: $vhostfile" >> "$INFORME"
    leer_archivo "vhost.conf — [$dominio]" "$vhostfile"
  done
else
  echo "  ⚠ Sin virtual hosts para detallar." >> "$INFORME"
fi

separador

# ============================================================
# 7. MÓDULOS Y CONFIGURACIONES ADICIONALES DE LITESPEED
# ============================================================
titulo "7. MÓDULOS Y CONFIGURACIONES ADICIONALES"

leer_archivo "Configuración de virtual hosts globales (vhosts.conf)" "${LSWS_CONF}/vhosts.conf"
leer_archivo "Configuración reCAPTCHA (lsrecaptcha.conf)" "${LSWS_CONF}/lsrecaptcha.conf"

echo -e "▶ Otros archivos .conf presentes en ${LSWS_CONF}:" >> "$INFORME"
find "$LSWS_CONF" -maxdepth 1 -name "*.conf" 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 8. CERTIFICADOS SSL (LET'S ENCRYPT / ACME)
# ============================================================
titulo "8. CERTIFICADOS SSL — LET'S ENCRYPT / ACME"

echo -e "▶ Dominios con certificado emitido (/etc/letsencrypt/live):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo ls -la /etc/letsencrypt/live/ 2>/dev/null >> "$INFORME"
else
  ls -la /etc/letsencrypt/live/ 2>/dev/null >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Fecha de expiración de cada certificado:" >> "$INFORME"
if $TIENE_SUDO && [ -d /etc/letsencrypt/live ]; then
  for dom in /etc/letsencrypt/live/*/; do
    dominio=$(basename "$dom")
    cert="${dom}fullchain.pem"
    if [ -f "$cert" ]; then
      fecha=$(sudo openssl x509 -enddate -noout -in "$cert" 2>/dev/null | cut -d= -f2)
      echo "  • $dominio  →  expira: $fecha" >> "$INFORME"
    fi
  done
else
  echo "  ⚠ Se requiere sudo o no existe /etc/letsencrypt/live" >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Configuración de acme.sh:" >> "$INFORME"
if [ -d /root/.acme.sh ] && $TIENE_SUDO; then
  sudo ls -la /root/.acme.sh/ 2>/dev/null | head -20 >> "$INFORME"
else
  echo "  ⚠ No accesible o no existe /root/.acme.sh" >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 9. CYBERPANEL — BASE DE DATOS (BD: cyberpanel)
# ============================================================
titulo "9. CYBERPANEL — BASE DE DATOS (cyberpanel)"

echo -e "▶ Nota: esta sección requiere acceso root a MySQL/MariaDB" >> "$INFORME"
echo "  (vía /root/.my.cnf o sudo mysql). Si no hay acceso, se omite." >> "$INFORME"
echo "" >> "$INFORME"

mysql_cyberpanel "Listado de websites registrados (websiteFunctions_websites)" \
  "SELECT id, domain, phpSelection, ssl, state, externalApp, admin_id, package_id FROM websiteFunctions_websites;"

mysql_cyberpanel "Dominios DNS internos (tabla domains)" \
  "SELECT id, name, type, admin_id FROM domains;"

mysql_cyberpanel "Subdominios / Child domains (websiteFunctions_childdomains)" \
  "SELECT * FROM websiteFunctions_childdomains;"

mysql_cyberpanel "Dominios alias (websiteFunctions_aliasdomains)" \
  "SELECT * FROM websiteFunctions_aliasdomains;"

mysql_cyberpanel "Paquetes de hosting (packages_package)" \
  "SELECT * FROM packages_package;"

mysql_cyberpanel "Bases de datos por sitio (databases_databases)" \
  "SELECT id, dbName, dbUser, website_id FROM databases_databases;"

mysql_cyberpanel "Administradores del panel (loginSystem_administrator)" \
  "SELECT id, userName, email, type FROM loginSystem_administrator;"

separador

# ============================================================
# 10. LOGS — CYBERPANEL Y LITESPEED
# ============================================================
titulo "10. LOGS — CYBERPANEL Y LITESPEED"

leer_archivo_tail "Log de errores del panel CyberPanel" "${CYBERPANEL_LOG_DIR}/error-logs.txt" 60

echo -e "▶ Comando de referencia: tail -f /usr/local/lsws/logs/error.log" >> "$INFORME"
echo "  (nota: 'tail -f' queda escuchando en vivo y nunca termina, por lo que" >> "$INFORME"
echo "   en este informe se toma una foto fija de las últimas líneas con 'tail -n')" >> "$INFORME"
echo "" >> "$INFORME"
leer_archivo_tail "Log de errores de OpenLiteSpeed (servidor)" "${LSWS_HOME}/logs/error.log" 60

echo -e "▶ Logs por sitio (errores), uno por dominio en /home/<dominio>/logs/:" >> "$INFORME"
if $TIENE_SUDO; then
  for dom in /home/*/; do
    dominio=$(basename "$dom")
    logfile="${dom}logs/${dominio}.error_log"
    if [ -f "$logfile" ]; then
      echo "  • $dominio → últimas 5 líneas:" >> "$INFORME"
      sudo tail -n 5 "$logfile" 2>/dev/null | sed 's/^/      /' >> "$INFORME"
    fi
  done
else
  echo "  ⚠ Se requiere sudo para leer logs por sitio en /home/*/logs/" >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 11. CACHÉ DE LITESPEED (LSCache)
# ============================================================
titulo "11. CACHÉ DE LITESPEED (LSCache)"

echo -e "▶ Tamaño de la caché por dominio (${LSWS_HOME}/cachedata):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo du -sh "${LSWS_HOME}/cachedata"/* 2>/dev/null >> "$INFORME"
else
  du -sh "${LSWS_HOME}/cachedata"/* 2>/dev/null >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 12. FIREWALL Y SEGURIDAD COMPLEMENTARIA (CSF / ModSecurity)
# ============================================================
titulo "12. SEGURIDAD COMPLEMENTARIA"

echo -e "▶ Estado de ConfigServer Firewall (CSF), si está instalado:" >> "$INFORME"
if command -v csf &>/dev/null; then
  if $TIENE_SUDO; then
    sudo csf -l 2>/dev/null | head -30 >> "$INFORME"
  else
    echo "  ⚠ Se requiere sudo para 'csf -l'." >> "$INFORME"
  fi
else
  echo "  CSF no instalado." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ ModSecurity (módulo cargado en OpenLiteSpeed):" >> "$INFORME"
if [ -x "${LSWS_HOME}/bin/openlitespeed" ]; then
  "${LSWS_HOME}/bin/openlitespeed" -v 2>&1 | grep -i "mod_security" >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 13. PHP — VERSIONES Y CONFIGURACIÓN
# ============================================================
titulo "13. PHP — VERSIONES Y CONFIGURACIÓN (lsphp)"

echo -e "▶ Versiones de PHP detectadas:" >> "$INFORME"
for phpdir in "${LSWS_HOME}"/lsphp*/bin/lsphp; do
  if [ -x "$phpdir" ]; then
    echo "  • $phpdir → $($phpdir -v 2>/dev/null | head -1)" >> "$INFORME"
  fi
done
echo "" >> "$INFORME"

echo -e "▶ Listado de extprocessors (LSAPI) configurados en httpd_config.conf:" >> "$INFORME"
grep -n "extprocessor" "${LSWS_CONF}/httpd_config.conf" 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 14. CAT DIRECTO DE FICHEROS CLAVE (resumen final, sin filtros)
# ============================================================
titulo "14. CAT DIRECTO DE FICHEROS CLAVE"

echo -e "▶ Esta sección hace 'cat' completo y sin filtros de los ficheros" >> "$INFORME"
echo "  de configuración más importantes para saber qué tiene el servidor" >> "$INFORME"
echo "  y qué dominios están configurados." >> "$INFORME"
echo "" >> "$INFORME"

# -----------------------------------------------------------
# 1) httpd_config.conf
# -----------------------------------------------------------
subtitulo "cat /usr/local/lsws/conf/httpd_config.conf"
echo "Ruta: ${LSWS_CONF}/httpd_config.conf" >> "$INFORME"
echo "---------------------------------------------" >> "$INFORME"
if [ -f "${LSWS_CONF}/httpd_config.conf" ]; then
  cat "${LSWS_CONF}/httpd_config.conf" >> "$INFORME" 2>&1
else
  echo "⚠ Archivo no encontrado." >> "$INFORME"
fi
echo "---------------------------------------------" >> "$INFORME"
echo "" >> "$INFORME"

# -----------------------------------------------------------
# 2) vhost.conf del dominio default
# -----------------------------------------------------------
subtitulo "cat /usr/local/lsws/conf/vhosts/default/vhost.conf"
echo "Ruta: ${LSWS_VHOSTS}/default/vhost.conf" >> "$INFORME"
echo "---------------------------------------------" >> "$INFORME"
if [ -f "${LSWS_VHOSTS}/default/vhost.conf" ]; then
  cat "${LSWS_VHOSTS}/default/vhost.conf" >> "$INFORME" 2>&1
else
  echo "⚠ Archivo no encontrado (este servidor puede no tener host por defecto configurado)." >> "$INFORME"
fi
echo "---------------------------------------------" >> "$INFORME"
echo "" >> "$INFORME"

# -----------------------------------------------------------
# 3) vhosts.conf (configuración global de virtual hosts)
# -----------------------------------------------------------
subtitulo "cat /usr/local/lsws/conf/vhosts.conf"
echo "Ruta: ${LSWS_CONF}/vhosts.conf" >> "$INFORME"
echo "---------------------------------------------" >> "$INFORME"
if [ -f "${LSWS_CONF}/vhosts.conf" ]; then
  cat "${LSWS_CONF}/vhosts.conf" >> "$INFORME" 2>&1
else
  echo "⚠ Archivo no encontrado." >> "$INFORME"
fi
echo "---------------------------------------------" >> "$INFORME"
echo "" >> "$INFORME"

# -----------------------------------------------------------
# 4) error.log de LiteSpeed
#    (tail -f no aplica en un informe que termina; se deja
#     constancia del comando y se vuelca el contenido actual)
# -----------------------------------------------------------
subtitulo "tail -f /usr/local/lsws/logs/error.log"
echo "Ruta: ${LSWS_HOME}/logs/error.log" >> "$INFORME"
echo "(nota: 'tail -f' se queda escuchando en vivo y no termina;" >> "$INFORME"
echo " aquí se vuelca el contenido completo disponible del log)" >> "$INFORME"
echo "---------------------------------------------" >> "$INFORME"
if [ -f "${LSWS_HOME}/logs/error.log" ]; then
  if $TIENE_SUDO; then
    sudo cat "${LSWS_HOME}/logs/error.log" >> "$INFORME" 2>&1
  else
    cat "${LSWS_HOME}/logs/error.log" >> "$INFORME" 2>&1
  fi
else
  echo "⚠ Archivo no encontrado." >> "$INFORME"
fi
echo "---------------------------------------------" >> "$INFORME"
echo "" >> "$INFORME"

# -----------------------------------------------------------
# 5) vhost.conf de TODOS los dominios encontrados en vhosts/
#    (recorre /usr/local/lsws/conf/vhosts/[dominio]/vhost.conf
#     uno por uno, automáticamente, sin importar cuántos haya)
# -----------------------------------------------------------
echo -e "▶ cat /usr/local/lsws/conf/vhosts/[dominio]/vhost.conf — TODOS los dominios:" >> "$INFORME"
echo "" >> "$INFORME"

if [ -d "$LSWS_VHOSTS" ]; then
  for dom in "$LSWS_VHOSTS"/*/; do
    dominio=$(basename "$dom")
    vhostfile="${dom}vhost.conf"
    subtitulo "cat /usr/local/lsws/conf/vhosts/[$dominio]/vhost.conf"
    echo "Ruta: $vhostfile" >> "$INFORME"
    echo "---------------------------------------------" >> "$INFORME"
    if [ -f "$vhostfile" ]; then
      cat "$vhostfile" >> "$INFORME" 2>&1
    else
      echo "⚠ Archivo no encontrado en esta carpeta." >> "$INFORME"
    fi
    echo "---------------------------------------------" >> "$INFORME"
    echo "" >> "$INFORME"
  done
else
  echo "⚠ No se encontró el directorio $LSWS_VHOSTS" >> "$INFORME"
fi

separador



cat >> "$INFORME" <<'REF'
▶ Reiniciar/estado LiteSpeed:
  sudo systemctl restart lsws
  sudo systemctl status lsws

▶ Reiniciar/estado CyberPanel:
  sudo systemctl restart lscpd
  sudo systemctl status lscpd

▶ Listar websites (CLI):
  cyberpanel listWebsitesJson
  cyberpanel listWebsitesPretty

▶ Cambiar versión de PHP de un sitio:
  cyberpanel changePHP --domainName ejemplo.com --php 8.2

▶ Emitir/renovar SSL (CLI):
  cyberpanel issueSSL --domainName ejemplo.com

▶ Cambiar password del panel de LiteSpeed (no el de CyberPanel):
  cd /usr/local/lsws/admin/misc && ./admpass.sh

▶ Cambiar password del admin de CyberPanel:
  adminPass nuevopassword

▶ Limpiar caché de LiteSpeed:
  rm -rf /usr/local/lsws/cachedata/*

▶ Ver logs en vivo:
  tail -f /usr/local/lsws/logs/error.log
  tail -f /home/cyberpanel/error-logs.txt
REF
echo "" >> "$INFORME"

separador

# ============================================================
# ✅ PIE DEL INFORME
# ============================================================
echo -e "\n\n════════════════════════════════════════════════" >> "$INFORME"
echo -e "  Informe generado el: $(date)" >> "$INFORME"
echo -e "  Usuario que ejecutó: $(whoami)" >> "$INFORME"
echo -e "  Hostname            : $(hostname 2>/dev/null)" >> "$INFORME"
echo -e "════════════════════════════════════════════════" >> "$INFORME"

# ============================================================
# RESUMEN EN CONSOLA
# ============================================================
echo ""
echo -e "${BGreen}╔═══════════════════════════════════════════════╗${Color_Off}"
echo -e "${BGreen}║   ✔  Informe generado exitosamente            ║${Color_Off}"
echo -e "${BGreen}╚═══════════════════════════════════════════════╝${Color_Off}"
echo ""
echo -e "${BCyan}  Versión : ${BWhite}v${VERSION}${BCyan} (${VERSION_FECHA})${Color_Off}"
echo -e "${BYellow}📄 Archivo : ${BWhite}$(realpath "$INFORME")${Color_Off}"
echo -e "${BYellow}📦 Tamaño  : ${BWhite}$(du -sh "$INFORME" | cut -f1)${Color_Off}"
echo ""
echo -e "${BCyan}Secciones incluidas:${Color_Off}"
SCRIPT_PATH="${BASH_SOURCE[0]}"
if [ -f "$SCRIPT_PATH" ]; then
  grep -E '^titulo "[0-9]+\.' "$SCRIPT_PATH" | sed 's/titulo "//;s/".*//' | while read -r linea; do
    echo "  • $linea"
  done
else
  echo "  • Ver secciones en el archivo de log generado."
fi
echo ""

if ! $TIENE_SUDO; then
  echo -e "${BRed}⚠ Aviso: el script se ejecutó sin sudo sin contraseña.${Color_Off}"
  echo -e "${BRed}  Algunas secciones (BD MySQL, logs por sitio, certificados, CSF)${Color_Off}"
  echo -e "${BRed}  pueden estar incompletas. Ejecuta con: sudo bash $0${Color_Off}"
  echo ""
fi