#!/usr/bin/env bash

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



# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================
PATH_CLAUDE="${CURRENT_USER_HOME}/.claude"
BACKUP_DIR="$CURRENT_DIR/.claude"
BACKUP_LASTED="$BACKUP_DIR/claude_backup_lasted.tar.gz"

msg "🔄 Iniciando restauración de configuración Claude..." "INFO"
msg "🎯 Directorio destino: ${BWhite}${PATH_CLAUDE}${Color_Off}" "INFO"

# Verificar que existe el backup
if [ ! -f "$BACKUP_LASTED" ]; then
    msg "❌ El backup ${BRed}${BACKUP_LASTED}${Color_Off} no existe" "ERROR"
    msg "💡 Ejecuta primero el script de backup: 2_backup_files.sh" "WARNING"
    exit 1
fi

msg "✅ Backup encontrado: ${BGreen}${BACKUP_LASTED}${Color_Off}" "SUCCESS"
BACKUP_SIZE=$(du -h "$BACKUP_LASTED" | cut -f1)
msg "📊 Tamaño del backup: ${BCyan}${BACKUP_SIZE}${Color_Off}" "INFO"

# Paso 1: Verificar y eliminar directorio actual de Claude
echo ""
msg "═══════════════════════════════════════════════════════" "INFO"
msg "📍 PASO 1: Eliminando configuración actual de Claude" "INFO"
msg "═══════════════════════════════════════════════════════" "INFO"

if [ -d "$PATH_CLAUDE" ]; then
    CURRENT_SIZE=$(du -sh "$PATH_CLAUDE" 2>/dev/null | cut -f1)
    msg "📂 Directorio existente: ${BYellow}${PATH_CLAUDE}${Color_Off}" "WARNING"
    msg "📊 Tamaño actual: ${BYellow}${CURRENT_SIZE}${Color_Off}" "WARNING"
    msg "🗑️  Eliminando directorio..." "WARNING"

    if rm -rf "$PATH_CLAUDE" 2>/dev/null; then
        msg "✅ Directorio eliminado correctamente" "SUCCESS"
    else
        msg "❌ Error al eliminar el directorio" "ERROR"
        exit 1
    fi
else
    msg "ℹ️  No existe directorio previo en ${PATH_CLAUDE}" "INFO"
fi

# Paso 2: Descomprimir backup
echo ""
msg "═══════════════════════════════════════════════════════" "INFO"
msg "📍 PASO 2: Restaurando desde backup" "INFO"
msg "═══════════════════════════════════════════════════════" "INFO"

msg "📦 Archivo de backup: ${BCyan}${BACKUP_LASTED}${Color_Off}" "INFO"
msg "📂 Destino: ${BCyan}${CURRENT_USER_HOME}${Color_Off}" "INFO"
msg "🔄 Descomprimiendo archivos..." "INFO"

if tar -xzf "$BACKUP_LASTED" -C "${CURRENT_USER_HOME}" 2>/dev/null; then
    msg "✅ Backup descomprimido exitosamente" "SUCCESS"

    # Verificar que se restauró correctamente
    if [ -d "$PATH_CLAUDE" ]; then
        RESTORED_SIZE=$(du -sh "$PATH_CLAUDE" 2>/dev/null | cut -f1)
        msg "✅ Directorio restaurado: ${BGreen}${PATH_CLAUDE}${Color_Off}" "SUCCESS"
        msg "📊 Tamaño restaurado: ${BGreen}${RESTORED_SIZE}${Color_Off}" "SUCCESS"
    else
        msg "⚠️  Advertencia: No se encontró el directorio .claude después de la restauración" "WARNING"
    fi
else
    msg "❌ Error al descomprimir el backup" "ERROR"
    exit 1
fi

# Resumen final
echo ""
msg "═══════════════════════════════════════════════════════" "SUCCESS"
msg "🎉 RESTAURACIÓN COMPLETADA EXITOSAMENTE" "SUCCESS"
msg "═══════════════════════════════════════════════════════" "SUCCESS"
msg "📂 Configuración de Claude restaurada en:" "SUCCESS"
msg "   ${BGreen}${PATH_CLAUDE}${Color_Off}" "SUCCESS"
msg "🕒 Fecha de restauración: ${BGreen}${DATE_HOUR_PE}${Color_Off}" "SUCCESS"
echo ""

