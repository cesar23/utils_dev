#!/bin/bash

# Variables de configuración iniciales
DATE_HOUR="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H):$(date +%M):$(date +%S)"  # Fecha y hora actuales en formato YYYY-MM-DD_HH:MM:SS.
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

source "${CURRENT_DIR}/vcursor_functions.sh"


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

  echo -en  "${Gray}"
  read -p "$mensaje"
  echo -en  "${Color_Off}"
}

# ==============================================================================
# ✅ Función: check_paths
#
# Descripción:
#   Verifica si las rutas dadas existen como archivos o directorios.
#   Soporta rutas en formato Unix y rutas estilo Windows (e.g., C:\ruta\archivo.txt),
#   convirtiéndolas automáticamente a formato Unix si es necesario.
#
# Parámetros:
#   $@ - Lista de rutas a verificar.
#
# Comportamiento:
#   - Si una ruta no existe, muestra un mensaje de error indicando si se esperaba
#     un archivo o un directorio, y marca la verificación como fallida.
#   - La salida de error se imprime en stderr.
#   - La función retorna 0 si todas las rutas existen, o 1 si alguna falla.
#
# Ejemplo de uso:
#   if check_paths "C:\Users\user\documento.txt" "/etc/passwd" "/no/existe"; then
#       echo "Todas las rutas son válidas"
#   else
#       echo "Ocurrió un error: Algunas rutas no existen" >&2
#       exit 1
#   fi
##

check_paths() {
    local error=0
    for ruta in "$@"; do
        # Convertir rutas de Windows a formato Unix si es necesario
        ruta_unix=$(echo "$ruta" | sed 's/\\/\//g' | sed 's/^\([A-Za-z]\):/\/mnt\/\L\1/')

        if [ -d "$ruta_unix" ] || [ -d "$ruta" ]; then
            continue
        elif [ -f "$ruta_unix" ] || [ -f "$ruta" ]; then
            continue
        else
            nombre=$(basename "$ruta")
            if [[ "$nombre" == *.* ]]; then
                echo -en "${BRed}"
                echo  "Error: El archivo '$ruta' no existe" >&2
                echo -en "${Color_Off}"
            else
              echo -en "${BRed}"
                echo "Error: El directorio '$ruta' no existe" >&2
                echo -en "${Color_Off}"
            fi
            error=1
        fi
    done
    return $error
}



# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================


instalarCursor(){
  # Descargar el instalador
  echo "Descargando Cursor..."
  curl -L -o "${CURRENT_DIR}/CursorInstaller.exe" "https://downloads.cursor.com/production/faa03b17cce93e8a80b7d62d57f5eda6bb6ab9fa/win32/x64/user-setup/CursorUserSetup-x64-1.2.2.exe"

  # Verificar si se descargó correctamente
  if [ -f "CursorInstaller.exe" ]; then
    echo "Instalador descargado. Ejecutando..."
     start "${CURRENT_DIR}/CursorInstaller.exe"
  else
    echo "Error: no se pudo descargar el instalador."
  fi
}


# Detectar si el script tiene permisos de administrador
if ! net session > /dev/null 2>&1; then
    echo "Reiniciando el script con permisos de administrador..."
    powershell -Command "Start-Process 'C:\\Program Files\\Git\\git-bash.exe' -ArgumentList '\"$0\"' -Verb RunAs"
    exit 0
fi


# Muestra las variables de configuración actuales
view_vars_config

# Buscar el proceso y eliminarlo
taskkill //IM "Cursor.exe" //F  >nul 2>&1

#%APPDATA%\Code\User\settings.json
# C:\Users\cesarPc\AppData\Roaming\Code\User

# Definir rutas
#SOURCE_DIR="/C/Users/cesarPc/AppData/Roaming/Termius"
SOURCE_DIR="${CURRENT_USER_HOME}/AppData/Roaming/Cursor"
SOURCE_DIR_PROGRAM="${CURRENT_USER_HOME}/AppData/Local/Programs/cursor"
BACKUP_FILE="${BACKUP_DIR}/settings.json.gz"
BACKUP_FILE_EXTENSIONS="${BACKUP_DIR}/vs-extensions.txt"
# format unix
BACKUP_FILE=$(echo "$BACKUP_FILE" | sed 's|^\([A-Za-z]\):|/\L\1|;s|\\|/|g')


#if check_paths "${SOURCE_DIR}" ; then
#    echo "Todas las rutas son válidas"
#else
#    echo "Ocurrió un error: Algunas rutas no existen" >&2
#    pause_continue
#    exit 1
#fi

msg "===================================================" "INFO"
msg "Eliminado Carpeta de instalacion antigua de Cursor" "INFO"
#rm -rf "${SOURCE_DIR}/*"
rm -rf $SOURCE_DIR
rm -rf $SOURCE_DIR_PROGRAM
pause_continue

msg "===================================================" "INFO"
msg "Instalando cursor" "INFO"
instalarCursor
#echo "${CURRENT_DIR}/CursorInstaller.exe"

msg "Ok" "SUCCESS"

pause_continue

# :::::comando para eliminar Cursor
# Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Cursor%'" | ForEach-Object { $_.Uninstall() }
#powershell.exe -Command "& Get-WmiObject -Query \"SELECT * FROM Win32_Product WHERE Name LIKE '%Cursor%'\" | ForEach-Object { \$_.Uninstall() }"
#powershell.exe -Command "& {docker exec -it -w /var/www/ wp-server pwd}"