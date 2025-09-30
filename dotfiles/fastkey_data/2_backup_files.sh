#!/usr/bin/env bash

# =============================================================================
# 🏆 SECTION: Configuración Inicial
# =============================================================================
# Establece la codificación a UTF-8 para evitar problemas con caracteres especiales.
export LC_ALL="es_ES.UTF-8"

# Variables de configuración iniciales
DATE_HOUR="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H):$(date +%M):$(date +%S)"  # Fecha y hora actuales en formato YYYY-MM-DD_HH:MM:SS.
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
# 🎨 SECTION: Colores para su uso7z

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

# =============================================================================
# ⚙️ SECTION: Core Function
# =============================================================================



# -----------------------------------------------------------------------------
# path_windows_to_path_shell
# -----------------------------------------------------------------------------
# Descripción:
#   Convierte una ruta en formato Windows a formato Unix.
#
# Uso:
#   path_windows_to_path_shell "C:\ruta\al\archivo"
#
# Parámetros:
#   PATH_REPO: Ruta en formato Windows que se quiere convertir.
#
# Ejemplo:
#   path_windows_to_path_shell "C:\laragon"
#   # Salida: /mnt/c/laragon
function path_windows_to_path_shell (){
    local PATH_REPO=$1

    if [[ -z "$PATH_REPO" ]]; then
        echo "Error: Debes proporcionar una ruta en formato Windows." >&2
        return 1
    fi

    # Convertir letra de unidad y backslashes a formato Unix
    local path_unix=$(echo "${PATH_REPO}" | sed 's|^\([A-Za-z]\):|/\L\1|;s|\\|/|g')

    if [[ -d "/mnt/c" ]]; then
      #  aqui convertir ejemplo: C:\laragon
      # a /mnt/c/laragon
        path_unix=$(echo "$PATH_REPO" | sed 's|^\([A-Za-z]\):|/mnt/\L\1|;s|\\|/|g')
        echo "$path_unix"
    else
        echo "$path_unix"
    fi
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

  local SHOW_DETAIL=1
  if [ -n "$SO_SYSTEM" ] && [ "$SO_SYSTEM" = "termux" ]; then
    SHOW_DETAIL=0
  fi


  case "$level" in
    INFO)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BBlue}[INFO]${Color_Off} ${message}"
        else
          echo -e "${BBlue}${timestamp} - [INFO]${Color_Off} ${message}"
        fi
        ;;
    WARNING)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BYellow}[WARNING]${Color_Off} ${message}"
        else
          echo -e "${BYellow}${timestamp} - [WARNING]${Color_Off} ${message}"
        fi
        ;;
    DEBUG)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BPurple}[DEBUG]${Color_Off} ${message}"
        else
          echo -e "${BPurple}${timestamp} - [DEBUG]${Color_Off} ${message}"
        fi
        ;;
    ERROR)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BRed}[ERROR]${Color_Off} ${message}"
        else
          echo -e "${BRed}${timestamp} - [ERROR]${Color_Off} ${message}"
        fi
        ;;
    SUCCESS)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BGreen}[SUCCESS]${Color_Off} ${message}"
        else
          echo -e "${BGreen}${timestamp} - ${BGreen}[SUCCESS]${Color_Off} ${message}"
        fi
        ;;
    *)
          echo -e "${BGray}[OTHER]${Color_Off} ${message}"
        ;;
  esac
}




# ==============================================================================
# 📦 FUNCION: restaurar_backup
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Restaura un backup desde un archivo TAR.GZ a una carpeta especificada.
#
# 🔧 Parámetros:
#   $1 - Ruta del archivo de backup (obligatorio)
#   $2 - Ruta de la carpeta destino (obligatorio)
#
# 💡 Uso:
#   restaurar_backup "ruta/al/backup.tar.gz" "ruta/destino"
#
# 🎯 Devuelve:
#   0 - Restauración exitosa
#   1 - Error al restaurar el backup
#
# 📝 Notas:
#   La carpeta destino se crea si no existe.
#   El backup se extrae en la carpeta destino especificada.
#   Si hay un error durante la restauración, se muestra un mensaje de error.
# ==============================================================================
restaurar_backup() {
  local BACKUP_FILE="$1"
  local DEST_DIR="$2"

  if [[ ! -f "$BACKUP_FILE" ]]; then
    msg "${BRed}❌ Error: El archivo '$BACKUP_FILE' no existe.${Color_Off}"
    return 1
  fi

  if [[ -z "$DEST_DIR" ]]; then
    msg "${BRed}❌ Error: Debes indicar la ruta de destino.${Color_Off}"
    return 1
  fi

  mkdir -p "$DEST_DIR"

  msg "${BBlue}📦 Restaurando backup desde '${BACKUP_FILE}' a '${DEST_DIR}'...${Color_Off}"
  tar -xzvf "$BACKUP_FILE" -C "$DEST_DIR"

  if [[ $? -eq 0 ]]; then
    msg "${BGreen}✅ Restauración completada correctamente.${Color_Off}"
  else
    msg "${BRed}❌ Error durante la restauración.${Color_Off}"
    return 1
  fi
}

# ==============================================================================
# 📦 Función: realizar_backup
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Comprime los archivos `.fdb` de un directorio fuente en un archivo `.tar.gz`
#   de respaldo en un directorio destino.
#
# 🔧 Parámetros:
#   $1 - Ruta del directorio fuente (con los archivos .fdb)
#   $2 - Ruta del directorio donde guardar el backup (opcional)
#
# 💡 Uso:
#   realizar_backup "/C/Users/cesarPc/Documents/FastKeys"
#   realizar_backup "/C/Users/cesarPc/Documents/FastKeys" "./mis_backups"
#
# 🎨 Requiere:
#   - Herramienta `tar`
#   - Función msg() definida previamente
# ==============================================================================
realizar_backup() {
  local SOURCE_DIR="$1"
  local BACKUP_DIR="${2:-${CURRENT_DIR}/backup}"  # Si no se pasa $2, usa ./backup
  local BACKUP_NAME="FastKeys.tar.gz"

  if [[ -z "$SOURCE_DIR" || ! -d "$SOURCE_DIR" ]]; then
    msg "❌ Directorio fuente inválido o no existe: '$SOURCE_DIR'" "ERROR"
    return 1
  fi

  # Convertir ruta de backup a formato shell (si es Windows)
  BACKUP_DIR=$(path_windows_to_path_shell "$BACKUP_DIR")
  mkdir -p "$BACKUP_DIR"

  msg "📁 Fuente: $SOURCE_DIR"
  msg "📦 Destino: ${BACKUP_DIR}/${BACKUP_NAME}"

  local FILES=$(cd "$SOURCE_DIR" && ls *.fdb 2>/dev/null)
  if [[ -z "$FILES" ]]; then
    msg "⚠️ No se encontraron archivos .fdb en $SOURCE_DIR" "WARNING"
    return 1
  fi


  msg "tar -czvf \"${BACKUP_DIR}/${BACKUP_NAME}\" \
         -C \"${SOURCE_DIR}\" \
          \$(cd \"${SOURCE_DIR}\" && ls *.fdb)" "DEBUG"

  tar -czvf "${BACKUP_DIR}/${BACKUP_NAME}" -C "${SOURCE_DIR}" $FILES

  if [[ $? -eq 0 ]]; then
    msg "✅ Backup realizado exitosamente: ${BACKUP_DIR}/${BACKUP_NAME}" "INFO"
  else
    msg "❌ Error al crear el backup." "ERROR"
    return 1
  fi
}


# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================




# Limpia la terminal
clear

# Muestra las variables de configuración actuales
view_vars_config

# Buscar el proceso y eliminarlo
taskkill //IM "FastKeys.exe" //F  >/tmp/nul 2>&1

# C:\Users\cesarPc\Documents\FastKeys
# Definir rutas
SOURCE_DIR="/C/Users/cesarPc/Documents/FastKeys"
BACKUP_DIR="${CURRENT_DIR}/backup"



BACKUP_DIR=$(path_windows_to_path_shell "$BACKUP_DIR")

# Entrar al directorio de la fuente y regresar a su raíz
realizar_backup "${SOURCE_DIR}" "${BACKUP_DIR}"

