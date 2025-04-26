#!/bin/bash
set -e  # Detener script al primer error

# =============================================================================
# 🏆 SECTION: Configuración Inicial
# =============================================================================
# Establece la codificación a UTF-8 para evitar problemas con caracteres especiales.
export LC_ALL="es_ES.UTF-8"

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
local level="${2:-INFO}"  # INFO por defecto si no se especifica
local timestamp
timestamp=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S")

case "$level" in
INFO)
echo -e "${BBlue}${timestamp} ${BWhite}- [INFO]${Color_Off} ${message}"
;;
WARNING)
echo -e "${BYellow}${timestamp} ${BWhite}- [WARNING]${Color_Off} ${message}"
;;
ERROR)
echo -e "${BRed}${timestamp} ${BWhite}- [ERROR]${Color_Off} ${message}"
;;
*)
echo -e "${BGray}${timestamp} ${BWhite}- [${level}]${Color_Off} ${message}"
;;
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
# =============================================================================
confirm_continue() {
local mensaje="${1:-¿Deseas continuar? [s/n]}"
read -rp "$mensaje " respuesta

case "$respuesta" in
[sS])
msg "${Gray}✅ Continuando...${Color_Off}"
return 0
;;
[nN])
msg "${Gray}❌ Operación cancelada por el usuario.${Color_Off}"
return 1
;;
*)
msg "${Gray}⚠️ Entrada inválida. Usa 's' o 'n'.${Color_Off}"
return 1
;;
esac
}


# Verificamos si el archivo ya existe
if [ ! -f "wp-cli.phar" ]; then
msg "📦 Descargando WP-CLI en ${PATH_DOMAIN}..."
curl -sSLO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar;
fi


# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================

cd $CURRENT_DIR

# Alias rápido
WP="php wp-cli.phar"


msg "🚀 Iniciando mantenimiento completo de WordPress..."

# Actualizar núcleo de WordPress
# msg "Actualizar núcleo de WordPress"
# $WP core update

# Actualizar plugins y temas
#msg "🛠️ Actualizar plugins y temas"
# $WP plugin update --all
#$WP theme update --all

# Actualizar traducciones
msg "Actualizar traducciones"
$WP language core update

# Optimizar y reparar base de datos
msg "Optimizar y reparar base de datos"
$WP db optimize
$WP db repair

# Limpiar transients y caché
msg "Limpiar transients y caché"
$WP transient delete --all
$WP cache flush


msg "Elimina todos los comentarios marcados como spam"
$WP comment delete $($WP comment list --status=spam --format=ids)

msg "Elimina todos los comentarios en papelera."
$WP comment delete $($WP comment list --status=trash --format=ids)

msg "Elimina todas las entradas y páginas en papelera."
$WP post delete $($WP post list --post_status=trash --format=ids)

msg "(Si tienes algún plugin compatible) Limpia residuos en la base de datos."
$WP db clean

msg "Borra archivos multimedia que están en la papelera"
$WP media delete


# Verificar integridad de archivos
msg "Verificar integridad de archivos"
$WP core verify-checksums

# Regenerar reglas de enlaces permanentes
msg "Regenerar reglas de enlaces permanentes"
$WP rewrite flush --hard

msg "✅ Mantenimiento completado exitosamente."
confirm_continue



