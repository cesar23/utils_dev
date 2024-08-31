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

# Ejemplo de uso:
# echo -e "${Red}Este texto se mostrará en rojo.${Color_Off}"

# =============================================================================
# ⚙️ SECTION: Core Function
# =============================================================================

# ----------------------------------------------------------------------
# 🗂️ get_rootPath
# ----------------------------------------------------------------------
# Descripción:
#   Obtiene la ruta raíz del proyecto eliminando el nombre del directorio
#   actual de la ruta completa del script.
#
# Uso:
#   root_path=$(get_rootPath)
#
# Ejemplo:
#   Si la ruta completa del script es:
#     /home/usuario/proyectos/mi_proyecto/scripts/mis_script.sh
#   y el directorio actual es:
#     /home/usuario/proyectos/mi_proyecto/scripts
#   entonces:
#     root_path=$(get_rootPath)
#   resultará en:
#     /home/usuario/proyectos/mi_proyecto
#
# Retorna:
#   La ruta raíz del proyecto como una cadena de texto.
# ----------------------------------------------------------------------
get_rootPath() {
  local regex="s/\/${NAME_DIR}//"  # Expresión regular para eliminar el nombre del directorio actual.
  local root_path=$(echo "$CURRENT_DIR" | sed -e "$regex")  # Aplica la expresión regular a la ruta actual.
  echo "$root_path"  # Imprime la ruta raíz.
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

  # Si ROOT_PATH está definido, lo muestra.
  local ROOT_PATH=$(get_rootPath)
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

# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================

# Obtiene la ruta raíz del proyecto
ROOT_PATH=$(get_rootPath)

# Define la ruta a la carpeta de hooks de Git
PATH_HOOKS_GIT="${ROOT_PATH}/.git/hooks/"

# Verifica si el directorio de destino existe
if [ ! -d "$PATH_HOOKS_GIT" ]; then
    echo -en "${Red}[ERROR] No se encontró el directorio: ${PATH_HOOKS_GIT} ${Color_Off}\n"
    echo -en "${Red}Es recomendable inicializar el repositorio con: git init ${Color_Off}\n"
    exit 1
fi

# ----------------------------------------------------------------------
# 🔄 Bucle para copiar archivos sin extensión a la carpeta de hooks de Git
# ----------------------------------------------------------------------
# Recorre todos los archivos sin extensión en el directorio actual y los
# copia a la carpeta de hooks de Git, eliminando cualquier retorno de carro (CR).
# ----------------------------------------------------------------------
for archivo in $(find "$CURRENT_DIR" -type f ! -name "*.*"); do
    name_file=$(basename "$archivo")  # Obtiene el nombre del archivo sin extensión
    echo "======================================================================"
    cp "$archivo" "${PATH_HOOKS_GIT}"  # Copia el archivo a la carpeta de hooks
    echo "Archivo       : $archivo"
    echo "Destino       : ${PATH_HOOKS_GIT}${name_file}"

    # Elimina retornos de carro (CR) en los archivos copiados
    find "${PATH_HOOKS_GIT}" -type f -exec sed -i 's/\r//g' {} +
done


exit_custom