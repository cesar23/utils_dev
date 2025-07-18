#!/bin/bash

#!/usr/bin/env bash

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

# Ejemplo de uso:
# echo -e "${Red}Este texto se mostrará en rojo.${Color_Off}"

# =============================================================================
# ⚙️ SECTION: Core Function
# =============================================================================



# -----------------------------------------------------------------------------
# Function: show_date
# Description: Displays the current date and time in three formats:
#              - Readable format in Spanish (local system time)
#              - UTC time
#              - Peru time (calculated as UTC -5)
# Usage: Call the function without arguments: show_date
# -----------------------------------------------------------------------------
show_date() {
    # Readable date in Spanish
    readable_date=$(LC_TIME=es_ES.UTF-8 date "+%A %d de %B de %Y, %H:%M:%S")

    # Date in UTC
    utc_date=$(date -u "+%Y-%m-%d %H:%M:%S UTC")

    # Date in Peru (UTC -5)
    peru_date=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S UTC-5")

    # Display results
    echo "Fecha actual (formato legible): $readable_date"
    echo "Fecha actual en UTC:            $utc_date"
    echo "Fecha actual en Perú (UTC-5):   $peru_date"
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
  echo -e "║             🛠️  CONFIGURACIÓN ACTUAL 🛠️"
  echo -e "║"
  echo -e "║ 📅 DATE_HOUR:                ${DATE_HOUR}"
  echo -e "║ 👤 CURRENT_USER:             ${CURRENT_USER}"
  echo -e "║ 🖥️ CURRENT_PC_NAME:         ${CURRENT_PC_NAME}"
  echo -e "║ ℹ️ MY_INFO:                  ${MY_INFO}"
  echo -e "║ 📁 CURRENT_USER_HOME:        ${CURRENT_USER_HOME}"
  echo -e "║ 📄 PATH_SCRIPT:              ${PATH_SCRIPT}"
  echo -e "║ 📜 SCRIPT_NAME:              ${SCRIPT_NAME}"
  echo -e "║ 📁 CURRENT_DIR:              ${CURRENT_DIR}"
  echo -e "║ 🗂️ NAME_DIR:                 ${NAME_DIR}"
  echo -e "║ 🗃️ TEMP_PATH_SCRIPT:        ${TEMP_PATH_SCRIPT}"
  echo -e "║ 📂 TEMP_PATH_SCRIPT_SYSTEM:  ${TEMP_PATH_SCRIPT_SYSTEM}"
  if [ -n "$ROOT_PATH" ]; then
    echo -e "║ 🏡 ROOT_PATH:                ${ROOT_PATH}"
  fi
  echo -e "╚═══════════════════════════════════════════════════════════"
  echo -e "${Color_Off}"
}

# ----------------------------------------------------------------------
# ❌ check_error
# ----------------------------------------------------------------------
# Descripción:
#   Verifica el código de salida del último comando ejecutado y muestra un
#   mensaje de error personalizado si ocurrió una falla.
#
# Uso:
#   check_error "Mensaje de error personalizado"
# ----------------------------------------------------------------------
check_error() {
  local exit_code=$?  # Captura el código de salida del último comando.
  local error_message=$1  # Mensaje de error personalizado.

  if [ $exit_code -ne 0 ]; then
    echo -e "${BRed}❌ Error: ${error_message}${Color_Off}"
    echo -e "${BRed}❌ saliendo del script en 8 segundos...${Color_Off}" && sleep 8
    exit $exit_code
  fi
}

# ----------------------------------------------------------------------
# ✅ message_ok
# ----------------------------------------------------------------------
# Descripción:
#   Muestra un mensaje de éxito si el último comando se ejecutó correctamente.
#
# Uso:
#   message_ok "Operación completada con éxito"
# ----------------------------------------------------------------------
message_ok() {
  local exit_code=$?  # Captura el código de salida del último comando.
  local success_message=$1  # Mensaje de éxito personalizado.

  if [ $exit_code -eq 0 ]; then
    echo -e "${BGreen}✅ ${success_message}${Color_Off}"
  fi
}



# ----------------------------------------------------------------------
# 🚪 exit_custom
# ----------------------------------------------------------------------
# Descripción:
#   Finaliza la ejecución del script mostrando un mensaje personalizado y
#   esperando que el usuario presione Enter.
#
# Uso:
#   exit_custom "Mensaje de salida personalizado"
#   # Si no se proporciona un mensaje, se utilizará uno por defecto.
# ----------------------------------------------------------------------
# shellcheck disable=SC2120
exit_custom() {
  local msg=${1:-"Presiona Enter para salir..."}  # Mensaje de salida por defecto si no se proporciona uno.

  # Muestra el mensaje y espera la entrada del usuario.
  read -p "$(echo -e "${Gray}${msg}${Color_Off}")"
  exit 0
}



###############################################################################
# 🧹 FUNCION: limpiar_directorio_excluyendo
#
# Elimina TODO el contenido de un directorio, incluidos archivos ocultos,
# excepto una o más carpetas que se deseen conservar.
#
# 📌 Parámetros:
#   $1 -> Ruta del directorio a limpiar. Si no se indica, se usa el directorio actual.
#   $2, $3, ... -> Nombres de carpetas a excluir de la eliminación.
#
# 🧪 Ejemplos de uso:
#   limpiar_directorio_excluyendo "/e/empaquetado" "my_script"
#   limpiar_directorio_excluyendo "." "config" "docs" ".git"
#
###############################################################################

limpiar_directorio_excluyendo() {
  local TARGET_DIR="${1:-.}"
  shift
  local EXCLUDE_DIRS=("$@")  # Resto de argumentos como array

  echo "🧹 Limpiando contenido de: $TARGET_DIR"
  echo "🚫 Exceptuando las carpetas: ${EXCLUDE_DIRS[*]}"
  echo

  if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Error: El directorio '$TARGET_DIR' no existe."
    return 1
  fi

  shopt -s dotglob nullglob

  for item in "$TARGET_DIR"/* "$TARGET_DIR"/.*; do
    local basename="$(basename "$item")"

    # Ignorar ".", ".." y los directorios a excluir
    if [[ "$basename" == "." || "$basename" == ".." ]]; then
      continue
    fi

    local exclude=false
    for excl in "${EXCLUDE_DIRS[@]}"; do
      if [[ "$basename" == "$excl" ]]; then
        exclude=true
        break
      fi
    done

    if [ "$exclude" = true ]; then
      continue
    fi

    echo "🗑️  Eliminando: $item"
    rm -rf "$item"
  done

  shopt -u dotglob nullglob
  echo
  echo "✅ Limpieza completada. Directorios preservados: ${EXCLUDE_DIRS[*]}"
}

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
# ----------------------------------------
# Function: install_package
# Installs a package based on the detected operating system.
#
# Parameters:
#   $1 -> Name of the package to install
#
# Example usage:
#   install_package fzf
#   install_package neovim
#
# Notes:
# - If running on Git Bash, it only supports installing fzf.
# - If the system is unrecognized, manual installation is required.
# ----------------------------------------
install_package() {
    package=$1  # Package name

    case "$system" in
        ubuntu|wsl)
            echo "🟢 Installing $package on Ubuntu/Debian..."
            sudo apt update -y && sudo apt install -y "$package"
            ;;
        redhat)
            echo "🔵 Installing $package on Red Hat/CentOS/Fedora..."
            # Usa dnf si está disponible, sino yum
            if command -v dnf &> /dev/null; then
                sudo dnf install -y "$package"
            else
                sudo yum install -y "$package"
            fi
            ;;
        termux)
            echo "📱 Installing $package on Termux..."
            pkg update -y && pkg install -y "$package"
            ;;
        gitbash)
            if [ "$package" == "fzf" ]; then
                echo "🪟 Installing fzf on Git Bash..."
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install --all
            fi
            ;;
        *)
            echo "❌ Unrecognized system. Please install $package manually."
            ;;
    esac
}


# ----------------------------------------
# Function: check_and_install
# Checks if a package is installed, if not, installs it.
#
# Parameters:
#   $1 -> Name of the package to check and install
#   $2 -> Command to check in terminal (optional, defaults to $1)
#
# Example usage:
#   check_and_install fzf
#   check_and_install bat batcat
# ----------------------------------------
check_and_install() {
    local package="$1"  # Package name
    local command_to_check="${2:-$1}"  # Command to check (defaults to package name)

    # Primero prueba con 'which' si está disponible, de lo contrario usa 'command -v'
    if command -v which &> /dev/null; then
        if ! which "$command_to_check" &> /dev/null; then
            echo "⚠️ Command '${command_to_check}' (package: ${package}) is not installed. Installing now..."
            install_package "$package"
        fi
    else
        if ! command -v "$command_to_check" &> /dev/null; then
            echo "⚠️ Command '${command_to_check}' (package: ${package}) is not installed. Installing now..."
            install_package "$package"
        fi
    fi
}


# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================


# Detect operating system
system=$(detect_system)

# Check and install fzf if not installed (no message if already installed)
if [[ "$system" == "ubuntu" || "$system" == "wsl" ]]; then
    # echo "🔄 verificaciones para  Debian/WSL..."
    check_and_install zip zip
    check_and_install unzip unzip
elif [[ "$system" == "redhat" ]]; then
    # echo "🔄 Instalando fzf en CentOS/RHEL..."
    check_and_install zip zip
    check_and_install unzip unzip
elif [[ "$system" == "termux" ]]; then
    # echo "🔄 Instalando fzf en CentOS/RHEL..."
    check_and_install zip zip
    check_and_install unzip unzip
fi


msg "============================================================="
msg " Isntalacion de librerias de libs_shell para bashrc"
msg " version: 1.0.1"
msg " SO: ${system}"
msg "============================================================="
echo ""

view_vars_config
pause_continue


# URL del archivo zip
ZIP_URL="https://raw.githubusercontent.com/cesar23/utils_dev/refs/heads/master/dotfiles/bashrc/libs_shell.zip"

# Carpeta de destino
DEST_DIR="$CURRENT_USER_HOME/libs_shell"

# Ruta temporal para el zip descargado
TEMP_ZIP="/tmp/libs_shell.zip"

# Crear carpeta temporal si no existe
mkdir -p /tmp

# Descargar el archivo zip
msg "📥 Descargando archivo..."
curl -L "$ZIP_URL" -o "$TEMP_ZIP"

# Verifica si se descargó correctamente
if [ $? -ne 0 ]; then
  msg "Error al descargar el archivo." "ERROR"
  exit 1
fi

# Eliminar carpeta existente si ya existe
if [ -d "$DEST_DIR" ]; then
  msg "⚠️  Carpeta existente encontrada. Eliminando $DEST_DIR..."
  rm -rf "$DEST_DIR"
fi

# Descomprimir el zip en el directorio de usuario
msg "📂 Descomprimiendo en $CURRENT_USER_HOME..."
unzip -q "$TEMP_ZIP" -d "$CURRENT_USER_HOME"

# Confirmación
if [ -d "$DEST_DIR" ]; then
  msg "✅ Carpeta 'libs_shell' lista en: $DEST_DIR"
else
  msg "❌ Algo salió mal. No se encontró la carpeta 'libs_shell'." "ERROR"
fi
