#!/usr/bin/env bash

# Fecha y hora actual en formato: YYYY-MM-DD_HH:MM:SS (hora local)
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")
# Fecha y hora actual en Perú (UTC -5)
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d_%H:%M:%S") # Fecha y hora actuales en formato YYYY-MM-DD_HH:MM:SS.
CURRENT_USER=$(id -un)             # Nombre del usuario actual.
CURRENT_USER_HOME="${HOME:-$USERPROFILE}"  # Ruta del perfil del usuario actual.
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
Color_Off='\033[0m'       # Reset de color.
Black='\033[0;30m'        # Negro.
Red='\033[0;31m'          # Rojo.
Green='\033[0;32m'        # Verde.
Yellow='\033[0;33m'       # Amarillo.
Blue='\033[0;34m'         # Azul.
Purple='\033[0;35m'       # Púrpura.
Cyan='\033[0;36m'         # Cian.
White='\033[0;37m'        # Blanco.
Gray='\033[0;90m'         # Gris.

# Colores en Negrita
BBlack='\033[1;30m'       # Negro (negrita).
BRed='\033[1;31m'         # Rojo (negrita).
BGreen='\033[1;32m'       # Verde (negrita).
BYellow='\033[1;33m'      # Amarillo (negrita).
BBlue='\033[1;34m'        # Azul (negrita).
BPurple='\033[1;35m'      # Púrpura (negrita).
BCyan='\033[1;36m'        # Cian (negrita).
BWhite='\033[1;37m'       # Blanco (negrita).
BGray='\033[1;90m'        # Gris (negrita).



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

pause_continue() {
  # Descripción:
  #   Muestra un mensaje de pausa. Si se pasa un argumento, lo usa como descripción del evento.
  #   Si no se pasa nada, se muestra un mensaje por defecto.
  #
  # Uso:
  #   pause_continue                         # Usa mensaje por defecto
  #   pause_continue "Se instaló MySQL"      # Muestra "Se instaló MySQL. Presiona..."

  if [ -n "$1" ]; then
    local mensaje="🔹 $1. Presiona [ENTER] para continuar..."
  else
    local mensaje="✅ Comando ejecutado. Presiona [ENTER] para continuar..."
  fi

  msg  "${Gray}"
  read -p "$mensaje"
  msg  "${Color_Off}"
}




# ----------------------------------------
# Function: detect_system
# Detects the operating system distribution.
# Returns:
#   - "termux"  -> If running in Termux
#   - "wsl"     -> If running on Windows Subsystem for Linux
#   - "ubuntu"  -> If running on Ubuntu/Debian-based distributions
#   - "redhat"  -> If running on Red Hat, Fedora, CentOS, Rocky, or AlmaLinux
#   - "gitbash" -> If running on Git Bash
#   - "unknown" -> If the system is not recognized
#
# Example usage:
#   system=$(detect_system)
#   echo "Detected system: $system"
# ----------------------------------------
detect_system() {
    if [ -f /data/data/com.termux/files/usr/bin/pkg ]; then
        echo "termux"
    elif grep -q Microsoft /proc/version; then
        echo "wsl"
    elif [ -f /etc/os-release ]; then
        # Lee el ID de /etc/os-release
        source /etc/os-release
        case $ID in
            ubuntu|debian)
                echo "ubuntu"
                ;;
            rhel|centos|fedora|rocky|almalinux)
                echo "redhat"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    elif [ -n "$MSYSTEM" ]; then
        echo "gitbash"
    else
        echo "unknown"
    fi
}


# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================


system=$(detect_system)

case "$sistema" in
    ubuntu)
        echo "🟢 Instalando yt-dlp en Ubuntu/Debian..."
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
        chmod a+rx /usr/local/bin/yt-dlp
        ;;
    termux)
        echo "📱 Instalando yt-dlp en Termux..."
        pkg install python ffmpeg -y
        pip install -U yt-dlp
        ;;
    wsl)
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
        chmod a+rx /usr/local/bin/yt-dlp
        ;;
    *)
        echo "❌ Sistema no reconocido. Instala fzf manualmente."
        exit 1
        ;;
esac