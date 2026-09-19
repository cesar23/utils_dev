#!/bin/bash
set -e


# Fecha y hora actual en formato: YYYY-MM-DD_HH:MM:SS (hora local)
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")
# Fecha y hora actual en Perú (UTC -5)
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d_%H:%M:%S") # Fecha y hora actuales en formato YYYY-MM-DD_HH:MM:SS.
CURRENT_USER=$(id -un)             # Nombre del usuario actual.
CURRENT_PC_NAME=$(hostname)        # Nombre del equipo actual.
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"  # Información combinada del usuario y del equipo.
PATH_SCRIPT=$(readlink -f "${BASH_SOURCE:-$0}")  # Ruta completa del script actual.
SCRIPT_NAME=$(basename "$PATH_SCRIPT")           # Nombre del archivo del script.
CURRENT_DIR=$(dirname "$PATH_SCRIPT")            # Ruta del directorio donde se encuentra el script.
NAME_DIR=$(basename "$CURRENT_DIR")              # Nombre del directorio actual.
TEMP_PATH_SCRIPT=$(echo "$PATH_SCRIPT" | sed 's/.sh/.tmp/g')  # Ruta para un archivo temporal basado en el nombre del script.
TEMP_PATH_SCRIPT_SYSTEM=$(echo "${TMP}/${SCRIPT_NAME}" | sed 's/.sh/.tmp/g')  # Ruta para un archivo temporal en /tmp.
ROOT_PATH=$(realpath -m "${CURRENT_DIR}/..")

# =============================================================================
# 🎨 SECTION: Colores para su uso
# =============================================================================
# Definición de colores que se pueden usar en la salida del terminal.

# Colores Regulares
Color_Off='\e[0m'       # Reset de color.
Black='\e[0;30m'        # Negro.
Red='\e[0;31m'          # Rojo.
Green='\e[0;32m'        # Verde.
Yellow='\e[0;33m'       # Amarillo.
Blue='\e[0;34m'         # Azul.
Purple='\e[0;35m'       # Púrpura.
Cyan='\e[0;36m'         # Cian.
White='\e[0;37m'        # Blanco.
Gray='\e[0;90m'         # Gris.

# Colores en Negrita
BBlack='\e[1;30m'       # Negro (negrita).
BRed='\e[1;31m'         # Rojo (negrita).
BGreen='\e[1;32m'       # Verde (negrita).
BYellow='\e[1;33m'      # Amarillo (negrita).
BBlue='\e[1;34m'        # Azul (negrita).
BPurple='\e[1;35m'      # Púrpura (negrita).
BCyan='\e[1;36m'        # Cian (negrita).
BWhite='\e[1;37m'       # Blanco (negrita).
BGray='\e[1;90m'        # Gris (negrita).






# ==============================================================================
# 📝 Función: msg
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Imprime un mensaje con formato estándar, incluyendo:
#   - Marca de tiempo en UTC-5 (Perú)
#   - Tipo de mensaje (INFO, WARNING, ERROR, o personalizado)
#   - Colores para terminal (si están definidos previamente)
#
# 🔧 Parámetros:
#   $1 - Mensaje a mostrar (texto)
#   $2 - Tipo de mensaje (INFO | WARNING | ERROR | otro) [opcional, por defecto: INFO]
#
# 💡 Uso:
#   msg "Inicio del proceso"               # Por defecto: INFO
#   msg "Plugin no instalado" "WARNING"
#   msg "Error de conexión" "ERROR"
#   msg "Mensaje personalizado" "DEBUG"
#
# 🎨 Requiere:
#   Variables de color: BBlue, BYellow, BRed, BWhite, BGray, Color_Off
# ==============================================================================

msg() {
  local message="$1"
  local level="${2:-INFO}"
  local timestamp
  timestamp=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S")

  case "$level" in
    INFO) echo -e "${BBlue}${timestamp} ${BWhite}- [INFO]${Color_Off} ${message}" ;;
    WARNING) echo -e "${BYellow}${timestamp} ${BWhite}- [WARNING]${Color_Off} ${message}" ;;
    ERROR) echo -e "${BRed}${timestamp} ${BWhite}- [ERROR]${Color_Off} ${message}" ;;
    SUCCESS) echo -e "${BGreen}${timestamp} ${BWhite}- [SUCCESS]${Color_Off} ${message}" ;;
    *) echo -e "${BGray}${timestamp} ${BWhite}- [${level}]${Color_Off} ${message}" ;;
  esac
}


# =============================================================================
# 📦 FUNCION: confirm_continue
# =============================================================================
# 🧾 DESCRIPCIÓN:
#   Pregunta al usuario si desea continuar y retorna 0 (sí) o 1 (no).
#
# 🧠 USO:
#   confirm_continue                # Muestra mensaje por defecto: ¿Deseas continuar? [s/n]
#   confirm_continue "¿Borrar todo?" # Muestra mensaje personalizado
#
# ✅ EJEMPLOS:
#   confirm_continue || continue
#   confirm_continue || exit 1
#   confirm_continue "¿Deseas sobrescribirlo? [s/n]" || exit 0
#   confirm_continue "¿Deseas sobrescribir el archivo?" || return
#   if confirm_continue "¿Deseas actualizar el core de WordPress? [s/n]"; then
#     $WP_CLI core update
#     echo "yes-----"
#   fi
# =============================================================================
confirm_continue() {
  local mensaje="${1:-¿Deseas continuar? [s/n]}"
  read -rp "$mensaje " respuesta
  respuesta="${respuesta,,}"  # Pasar a minúsculas

   if [[ "$respuesta" == "s" ]]; then
      msg "${Gray}✅ Continuando...${Color_Off}"
      return 0
   else
      msg "${Gray}❌ Operación cancelada por el usuario.${Color_Off}"
      return 1
   fi

}


check_install_wp_cli() {
  # Verificamos si el archivo ya existe
  if [ ! -f "wp-cli.phar" ]; then
  msg "📦 Descargando WP-CLI en ${CURRENT_DIR}..."
  curl -sSLO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar;
  fi
}


check_command() {
  command -v "$1" &>/dev/null || { msg "Comando requerido '$1' no encontrado" "ERROR"; exit 1; }
}


# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================

cd $CURRENT_DIR



check_command php
check_command grep


check_install_wp_cli


WP_CLI="php wp-cli.phar"

WP_CONFIG="wp-config.php"
if [[ ! -f "$WP_CONFIG" ]]; then
  msg "No se encontró el archivo wp-config.php en el directorio actual" "ERROR"
  exit 1
fi
DB_NAME=$(grep DB_NAME wp-config.php | cut -d \' -f 4)
DB_USER=$(grep DB_USER wp-config.php | cut -d \' -f 4)
DB_PASSWORD=$(grep DB_PASSWORD wp-config.php | cut -d \' -f 4)
DB_HOST=$(grep DB_HOST wp-config.php | cut -d \' -f 4)

msg "🔍 Verificando conexión a base de datos..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME;" &>/dev/null && \
  msg "Conexión a base de datos OK" "SUCCESS" || \
  { msg "No se pudo conectar a la base de datos $DB_NAME" "ERROR"; exit 1; }

# ==============================================================================
# 🔍 Diagnóstico de WordPress
# ==============================================================================
msg "🔍 Verificando versión de WordPress..."
$WP_CLI core version

msg "🔍 Verificando integridad del core..."
$WP_CLI core verify-checksums || msg "⚠️ Se detectaron archivos del core modificados" "WARNING"

msg "🔍 Listando plugins activos..."
$WP_CLI plugin list --status=active

msg "🔍 Listando temas activos..."
$WP_CLI theme list --status=active

msg "🔍 Opciones relacionadas a transients (autoload)..."
$WP_CLI option list --search=transient --fields=option_name,autoload

# ==============================================================================
# 🔁 Limpiar las URL permanentes
# ==============================================================================
msg "🔁 Regenerando URLs permanentes..."
if confirm_continue "¿Deseas regenerar las URLs permanentes? [s/n]"; then
  $WP_CLI rewrite flush --hard
fi

# ==============================================================================
# 🪵 Revisión de logs
# ==============================================================================
msg "🔍 Verificando últimos errores del log..."
if [[ -f "wp-content/debug.log" ]]; then
  tail -n 10 wp-content/debug.log
else
  msg "No se encontró debug.log o no está habilitado el modo debug" "WARNING"
fi

# ==============================================================================
# 🛡️ Permisos inseguros
# ==============================================================================
msg "🔍 Verificando permisos de archivos..."
INSECURE_FILES=$(find . -type f -perm /o+w | wc -l)
if (( INSECURE_FILES > 0 )); then
  find . -type f -perm /o+w -exec ls -l {} \; | head -n 5
  msg "⚠️ Se encontraron $INSECURE_FILES archivos con permisos inseguros (otros pueden escribir)" "WARNING"
else
  msg "No se encontraron archivos con permisos problemáticos" "SUCCESS"
fi

# ==============================================================================
# ✅ Fin
# ==============================================================================
msg "✅ Diagnóstico de WordPress completado" "SUCCESS"
