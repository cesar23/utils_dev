#!/bin/bash


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
#     $WP core update
#     echo "yes-----"
#   fi
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


# ----------------------------------------------------------------------
# 📋 view_vars_config
# ----------------------------------------------------------------------
# Descripción:
#   Muestra todas las variables de configuración actuales en formato legible.
#
# Uso:
#   view_vars_config
# ----------------------------------------------------------------------
view_vars_config() {


  echo -e "${Gray}"
  echo -e "╔═══════════════════════════════════════════════════════════"
  echo -e "║             🛠️  CONFIGURACIÓN ACTUAL V1.0.1 🛠️"
  echo -e "║"
  echo -e "║ 📅 DATE_HOUR:                ${DATE_HOUR}"
  echo -e "║ 👤 CURRENT_USER:             ${CURRENT_USER}"
  echo -e "║ 🖥️ CURRENT_PC_NAME:         ${CURRENT_PC_NAME}"
  echo -e "║ ℹ️ MY_INFO:                  ${MY_INFO}"
  echo -e "║ 📄 PATH_SCRIPT:              ${PATH_SCRIPT}"
  echo -e "║ 📜 SCRIPT_NAME:              ${SCRIPT_NAME}"
  echo -e "║ 📁 CURRENT_DIR:              ${CURRENT_DIR}"
  echo -e "║ 🗂️ NAME_DIR:                 ${NAME_DIR}"
  echo -e "║ 🗂️ BASE_DIR:                 ${BASE_DIR}"
  echo -e "║ 🗃️ TEMP_PATH_SCRIPT:        ${TEMP_PATH_SCRIPT}"
  echo -e "║ 📂 TEMP_PATH_SCRIPT_SYSTEM:  ${TEMP_PATH_SCRIPT_SYSTEM}"
  if [ -n "$ROOT_PATH" ]; then
    echo -e "║ 🏡 ROOT_PATH:                ${ROOT_PATH}"
  fi

  echo -e "╚═══════════════════════════════════════════════════════════"
  echo -e "${Color_Off}"
}


# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================

# Ruta base
BASE_DIR="/home/${CURRENT_USER}"
#BASE_DIR="/E/projects_webs_resources"


# Muestra las variables de configuración actuales
view_vars_config
confirm_continue

# Obtener lista de carpetas que parecen dominios en una variable (array)
mapfile -t DOMAINS < <(find "$BASE_DIR" -maxdepth 1 -type d -printf "%f\n" | grep -E '^[a-z0-9.-]+\.[a-z]{2,}$' | sort)

# Validar si hay dominios
if [ ${#DOMAINS[@]} -eq 0 ]; then
  msg "No se encontraron carpetas con nombres de dominio." "ERROR"
  exit 1
fi

# Mostrar lista al usuario
echo "📂 Dominios encontrados:"
for i in "${!DOMAINS[@]}"; do
  printf "  [%d] %s\n" "$i" "${DOMAINS[$i]}"
done

# Solicitar selección
echo -ne "\n🔢 Ingresa el número del dominio: "
read -r index

# Validar la entrada
if [[ ! "$index" =~ ^[0-9]+$ ]] || [ "$index" -lt 0 ] || [ "$index" -ge "${#DOMAINS[@]}" ]; then
  msg "Selección inválida." "ERROR"
  exit 1
fi

# Obtener dominio seleccionado
domain="${DOMAINS[$index]}"

# Rutas posibles del log
LOG_FILE1="${BASE_DIR}/${domain}/wp-content/debug.log"
LOG_FILE2="${BASE_DIR}/${domain}/error_log"

# Verificar cuál existe
if [ -f "$LOG_FILE1" ]; then
  LOG_FILE="$LOG_FILE1"
elif [ -f "$LOG_FILE2" ]; then
  LOG_FILE="$LOG_FILE2"
else
  msg "No se encontró ningún archivo de log en $domain" "WARNING"
  exit 1
fi

msg "${BYellow}============================ FECHA FORMATO [UTC-5 Perú]========================${Color_Off}" "INFO"
msg "${BYellow}Mostrando últimas 50 líneas de: $LOG_FILE${Color_Off}" "INFO"
tail -n 50 "$LOG_FILE" | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]", systime() - 18000), $0; fflush(); }'
echo ""
msg "${BYellow}============================ FECHA FORMATO [UTC-5 Perú]========================${Color_Off}" "INFO"
msg "${BYellow}Mostrando en tiempo real: $LOG_FILE${Color_Off}" "INFO"
tail -f "$LOG_FILE" |  awk '{ print strftime("[%Y-%m-%d %H:%M:%S]", systime() - 18000), $0; fflush(); }'

# ==================================================================
#  Uso
# ==================================================================
#curl -sSL -o cpanel_domain_logs_error.sh  https://raw.githubusercontent.com/cesar23/utils_dev/refs/heads/master/scripts/wordpress/cpanel_domain_logs_error.sh && \
#chmod +x cpanel_domain_logs_error.sh  && \
#./cpanel_domain_logs_error.sh  && \
#rm -rf cpanel_domain_logs_error.sh

