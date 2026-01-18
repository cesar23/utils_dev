#!/usr/bin/env bash

# =============================================================================
# 🏆 SECTION: Configuración Inicial
# =============================================================================

# Fecha y hora local
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")
# Fecha y hora en Perú (UTC-5)
DATE_HOUR_PE=$(TZ="America/Lima" date "+%Y-%m-%d_%H:%M:%S" 2>/dev/null || echo "$DATE_HOUR")

CURRENT_USER=$(id -un)
CURRENT_USER_HOME="${HOME:-$USERPROFILE}"
CURRENT_PC_NAME=$(hostname)
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"
PATH_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_NAME=$(basename "$PATH_SCRIPT")
CURRENT_DIR=$(dirname "$PATH_SCRIPT")
NAME_DIR=$(basename "$CURRENT_DIR")
TEMP_PATH_SCRIPT="${PATH_SCRIPT%.sh}.tmp"
TEMP_PATH_SCRIPT_SYSTEM="${TMPDIR:-/tmp}/${SCRIPT_NAME%.sh}.tmp"
ROOT_PATH=$(realpath -m "${CURRENT_DIR}/..")

# =============================================================================
# 🎨 SECTION: Colores
# =============================================================================

Color_Off='\033[0m'
BBlue='\033[1;34m'      # INFO
BYellow='\033[1;33m'    # WARNING
BRed='\033[1;31m'       # ERROR
BGreen='\033[1;32m'     # SUCCESS
BPurple='\033[1;35m'    # DEBUG
BGray='\033[1;90m'      # OTHER

# =============================================================================
# 📝 Función: msg
# =============================================================================

msg() {
  local message="$1"
  local level="${2:-INFO}"

  case "$level" in
    INFO)     echo -e "${BBlue}${message}${Color_Off}" ;;
    WARNING)  echo -e "${BYellow}${message}${Color_Off}" ;;
    ERROR)    echo -e "${BRed}${message}${Color_Off}" ;;
    SUCCESS)  echo -e "${BGreen}${message}${Color_Off}" ;;
    DEBUG)    echo -e "${BPurple}${message}${Color_Off}" ;;
    *)        echo -e "${BGray}${message}${Color_Off}" ;;
  esac
}

# =============================================================================
# 🚀 SECTION: Lógica Principal
# =============================================================================

# Detener proceso espansod.exe si está corriendo
msg "Deteniendo proceso espansod.exe (si existe)..." "INFO"
powershell.exe -Command "Stop-Process -Name espansod -Force -ErrorAction SilentlyContinue" >/dev/null 2>&1

# Usuario objetivo (ajustable)
USERNAME='cesarPc'

# Rutas
ESPANSO_CONFIG_DIR="/c/Users/$USERNAME/AppData/Roaming/espanso"
ESPANSO_BIN_DIR="/c/Users/$USERNAME/AppData/Local/Programs/Espanso"
ESPANSO_EXE="espansod.exe launcher"

# Validar que el directorio del script no esté vacío
if [ ! -f "$PATH_SCRIPT" ]; then
  msg "Error: No se puede determinar la ubicación del script." "ERROR"
  exit 1
fi

# Crear directorio de configuración
msg "Creando directorio de configuración: $ESPANSO_CONFIG_DIR" "INFO"
mkdir -p "$ESPANSO_CONFIG_DIR" || {
  msg "No se pudo crear el directorio de configuración." "ERROR"
  exit 1
}

# Limpiar contenido existente
msg "Limpiando configuraciones anteriores..." "DEBUG"
rm -rf "${ESPANSO_CONFIG_DIR:?}"/*

# Copiar archivos actuales (excluyendo este script si es necesario)
msg "Copiando nuevos archivos de configuración..." "INFO"
if ! cp -r "$CURRENT_DIR"/* "$ESPANSO_CONFIG_DIR/"; then
  msg "Error al copiar los archivos de configuración." "ERROR"
  exit 1
fi

msg "Configuración copiada exitosamente." "SUCCESS"

# Iniciar Espanso
if [ -d "$ESPANSO_BIN_DIR" ]; then
  msg "Iniciando Espanso desde: $ESPANSO_BIN_DIR" "INFO"
  cd "$ESPANSO_BIN_DIR" || {
    msg "No se pudo acceder al directorio de ejecución." "ERROR"
    exit 1
  }
  start $ESPANSO_EXE
  msg "Espanso iniciado en segundo plano." "SUCCESS"
else
  msg "Directorio de ejecución no encontrado: $ESPANSO_BIN_DIR" "ERROR"
  exit 1
fi