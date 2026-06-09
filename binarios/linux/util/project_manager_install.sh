#!/bin/bash
VERSION_SCRIPT="1.0.2"
# ==============================================================================
# 📦 Script: setup_nvim.sh
# 📝 Descripción: Instala y configura Neovim con plugins, fuentes y acceso rápido.
#                 Ejecución completamente desatendida (sin intervención del usuario).
# ==============================================================================

set -euo pipefail   # -e: salir al primer error | -u: variables no definidas = error | -o pipefail: pipe falla si cualquier parte falla

# =============================================================================
# 🎨 SECTION: Colores
# =============================================================================
Color_Off='\033[0m'
Black='\033[0;30m';  Red='\033[0;31m';    Green='\033[0;32m'
Yellow='\033[0;33m'; Blue='\033[0;34m';   Purple='\033[0;35m'
Cyan='\033[0;36m';   White='\033[0;37m';  Gray='\033[0;90m'

BBlack='\033[1;30m'; BRed='\033[1;31m';   BGreen='\033[1;32m'
BYellow='\033[1;33m';BBlue='\033[1;34m';  BPurple='\033[1;35m'
BCyan='\033[1;36m';  BWhite='\033[1;37m'; BGray='\033[1;90m'
# ── Si no hay terminal interactiva (ej: Ansible), desactivar colores ──────────
if [ ! -t 1 ]; then
    Color_Off=''; Black='';   Red='';    Green=''
    Yellow='';    Blue='';    Purple=''; Cyan='';   White=''; Gray=''
    BBlack='';    BRed='';    BGreen=''
    BYellow='';   BBlue='';   BPurple=''
    BCyan='';     BWhite='';  BGray=''
fi


# =============================================================================
# ⚙️ SECTION: Variables del entorno
# =============================================================================
PATH_SCRIPT=$(readlink -f "${BASH_SOURCE:-$0}")
SCRIPT_NAME=$(basename "$PATH_SCRIPT")
CURRENT_DIR=$(dirname "$PATH_SCRIPT")
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(hostname)

PROJECT_MANAGER_FILE="/usr/local/bin/pm"

# =============================================================================
# 📝 SECTION: Funciones de utilidad
# =============================================================================

# ------------------------------------------------------------------------------
# msg: Imprime mensajes con colores según el nivel
# Uso: msg "texto" "INFO|WARNING|ERROR|SUCCESS|DEBUG"
# ------------------------------------------------------------------------------
msg() {
  local message="$1"
  local level="${2:-OTHER}"
  local timestamp
  timestamp=$(date "+%H:%M:%S")

  case "$level" in
    INFO)    echo -e "${BBlue}[${timestamp}] ℹ  ${message}${Color_Off}" ;;
    WARNING) echo -e "${BYellow}[${timestamp}] ⚠  ${message}${Color_Off}" ;;
    DEBUG)   echo -e "${BPurple}[${timestamp}] 🔍 ${message}${Color_Off}" ;;
    ERROR)   echo -e "${BRed}[${timestamp}] ✗  ${message}${Color_Off}" >&2 ;;
    SUCCESS) echo -e "${BGreen}[${timestamp}] ✔  ${message}${Color_Off}" ;;
    STEP)    echo -e "\n${BCyan}[${timestamp}] ══ ${message} ══${Color_Off}" ;;
    *)       echo -e "${BGray}[${timestamp}]    ${message}${Color_Off}" ;;
  esac
}

# ------------------------------------------------------------------------------
# run_cmd: Muestra y ejecuta un comando. Retorna el exit code del comando.
# Uso: run_cmd apt-get install -y neovim
# ------------------------------------------------------------------------------
run_cmd() {
  echo -e "  ${BGray}›${Color_Off} ${BYellow}$*${Color_Off}"
  "$@"
  local exit_code=$?
  return $exit_code
}

# ------------------------------------------------------------------------------
# run_cmd_silent: Ejecuta el comando suprimiendo stdout (stderr visible).
# Uso: run_cmd_silent fc-cache -fv
# ------------------------------------------------------------------------------
run_cmd_silent() {
  echo -e "  ${BGray}›${Color_Off} ${BYellow}$*${Color_Off} ${BGray}(silencioso)${Color_Off}"
  "$@" > /dev/null
  local exit_code=$?
  return $exit_code
}

# ------------------------------------------------------------------------------
# check_cmd: Verifica si un comando existe en el PATH
# Uso: check_cmd nvim || exit 1
# ------------------------------------------------------------------------------
check_cmd() {
  if command -v "$1" &>/dev/null; then
    msg "'$1' encontrado: $(command -v "$1")" "DEBUG"
    return 0
  else
    msg "'$1' no encontrado en PATH." "WARNING"
    return 1
  fi
}

# =============================================================================
# 🛡️ SECTION: Manejador Global de Errores
# =============================================================================

handle_error() {
  local exit_code=$1
  local line_number=$2
  msg "=================================================" "ERROR"
  msg "💥 ERROR CRÍTICO NO MANEJADO" "ERROR"
  msg "=================================================" "ERROR"
  msg "Código de salida : ${exit_code}" "ERROR"
  msg "Línea del error  : ${line_number}" "ERROR"
  msg "Comando          : ${BASH_COMMAND:-N/A}" "ERROR"
  msg "Script           : ${PATH_SCRIPT}" "ERROR"
  msg "Función          : ${FUNCNAME[1]:-main}" "ERROR"
  msg "Usuario          : ${CURRENT_USER}@${CURRENT_PC_NAME}" "ERROR"
  msg "=================================================" "ERROR"
  exit "${exit_code}"
}

cleanup_on_exit() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    msg "Script finalizado con errores (código: ${exit_code})." "ERROR"
  fi
}

trap 'handle_error $? $LINENO' ERR
trap 'cleanup_on_exit'          EXIT

# =============================================================================
# 🚦 SECTION: Validaciones previas
# =============================================================================

check_root() {
  if [[ $EUID -ne 0 ]]; then
    msg "Este script debe ejecutarse como root o con sudo." "ERROR"
    msg "Usa: sudo bash ${SCRIPT_NAME}" "INFO"
    exit 1
  fi
}

# =============================================================================
# 📥 SECTION: Code
# =============================================================================

check_root

msg "PASO 1/2 — Instalando project_manager en ${PROJECT_MANAGER_FILE}" "STEP"

cat > "${PROJECT_MANAGER_FILE}" << 'PROJECT_EOF'

#!/usr/bin/env bash

# =============================================================================
# 📦 INSTALACIÓN
# =============================================================================
# 1. Copiar el script
#    sudo cp project_manager.sh /usr/local/bin/pm
#
# 2. Darle permisos de ejecución
#    sudo chmod +x /usr/local/bin/pm
#
# 3. Probar
#    pm
#    pm list
#    pm help
# =============================================================================
# Uso instalacion automatica:
#   curl -sSL https://raw.githubusercontent.com/cesar23/utils_dev/refs/heads/master/binarios/linux/util/project_manager_install.sh  | sudo bash
# =============================================================================

set -e  # Detener script al primer error

# =============================================================================
# 🏆 SECTION: Configuración Inicial
# =============================================================================

# Fecha y hora actual en formato: YYYY-MM-DD_HH:MM:SS (hora local)
# Fecha y hora actual en Perú (UTC -5)
DATE_HOUR=$(date -u -d "-5 hours" "+%Y-%m-%d_%H:%M:%S" 2>/dev/null || TZ="America/Lima" date "+%Y-%m-%d_%H:%M:%S" 2>/dev/null || date "+%Y-%m-%d_%H:%M:%S")
CURRENT_USER=$(id -un)             # Nombre del usuario actual.
CURRENT_USER_HOME="${HOME:-$USERPROFILE}"  # Ruta del perfil del usuario actual.
CURRENT_PC_NAME=$(hostname)        # Nombre del equipo actual.
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"  # Información combinada del usuario y del equipo.
PATH_SCRIPT=$(readlink -f "${BASH_SOURCE:-$0}")  # Ruta completa del script actual.
SCRIPT_NAME=$(basename "$PATH_SCRIPT")           # Nombre del archivo del script.
CURRENT_DIR=$(dirname "$PATH_SCRIPT")            # Ruta del directorio donde se encuentra el script.
NAME_DIR=$(basename "$CURRENT_DIR")              # Nombre del directorio actual.
TEMP_PATH_SCRIPT=$(echo "$PATH_SCRIPT" | sed 's/.sh/.tmp/g')  # Ruta para un archivo temporal basado en el nombre del script.
TEMP_PATH_SCRIPT_SYSTEM=$(echo "${TMP:-/tmp}/${SCRIPT_NAME}" | sed 's/.sh/.tmp/g')  # Ruta para un archivo temporal en /tmp.
ROOT_PATH=$(realpath -m "${CURRENT_DIR}/..")

# =============================================================================
# 📦 SECTION: Configuración del Gestor de Proyectos
# =============================================================================

# Archivo JSON donde se almacenan los proyectos (ubicado en el home del usuario)
PROJECTS_JSON="${CURRENT_USER_HOME}/project_manager.json"

# Archivo temporal para operaciones de escritura en el JSON (ubicado en home del usuario)
TEMP_FILE_JQ="${CURRENT_USER_HOME}/.project_manager.tmp"

# =============================================================================
# 🎨 SECTION: Colores para su uso
# =============================================================================

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

# =============================================================================
# ⚙️ SECTION: Core Functions
# =============================================================================

# ==============================================================================
# 📝 Función: msg
# ==============================================================================
msg() {
  local message="$1"
  local level="${2:-OTHER}"

  case "$level" in
    INFO)    echo -e "${BBlue}${message}${Color_Off}" ;;
    WARNING) echo -e "${BYellow}${message}${Color_Off}" ;;
    DEBUG)   echo -e "${BPurple}${message}${Color_Off}" ;;
    ERROR)   echo -e "${BRed}${message}${Color_Off}" ;;
    SUCCESS) echo -e "${BGreen}${message}${Color_Off}" ;;
    *)       echo -e "${BGray}${message}${Color_Off}" ;;
  esac
}

# ==============================================================================
# 📝 Función: run_cmd
# ==============================================================================
run_cmd() {
  echo -e "  ${BGray}›${Color_Off} ${BYellow}$*${Color_Off}"
  "$@"
}

# ==============================================================================
# 📝 Función: handle_error
# ==============================================================================
handle_error() {
  local exit_code=$1
  local line_number=$2

  msg "=================================================" "ERROR"
  msg "💥 ERROR CRÍTICO NO MANEJADO" "ERROR"
  msg "=================================================" "ERROR"
  msg "Código de salida: ${exit_code}" "ERROR"
  msg "Línea del error: ${line_number}" "ERROR"
  msg "Comando: ${BASH_COMMAND:-N/A}" "ERROR"
  msg "Script: ${PATH_SCRIPT}" "ERROR"
  msg "Función: ${FUNCNAME[1]:-main}" "ERROR"
  msg "Usuario: ${USER:-$(id -un 2>/dev/null || echo 'N/A')}" "ERROR"
  msg "Directorio: ${CURRENT_DIR:-N/A}" "ERROR"
  msg "=================================================" "ERROR"
  exit "${exit_code}"
}

# ==============================================================================
# 📝 Función: cleanup_on_exit
# ==============================================================================
cleanup_on_exit() {
  local exit_code=$?
  if [[ -n "${TEMP_FILE_OK:-}" ]] && [[ -f "${TEMP_FILE_OK}" ]]; then
    rm -f "${TEMP_FILE_OK}" 2>/dev/null || true
  fi
  if [[ -n "${TEMP_FILE_ERR:-}" ]] && [[ -f "${TEMP_FILE_ERR}" ]]; then
    rm -f "${TEMP_FILE_ERR}" 2>/dev/null || true
  fi
  if [[ -n "${TEMP_FILE_JQ:-}" ]] && [[ -f "${TEMP_FILE_JQ}" ]]; then
    rm -f "${TEMP_FILE_JQ}" 2>/dev/null || true
  fi
}

# Configurar traps
trap 'handle_error $? $LINENO' ERR
trap 'cleanup_on_exit' EXIT

# ==============================================================================
# 📝 Función: pause_continue
# ==============================================================================
pause_continue() {
  local input_msg="${1:-}"
  if [ -n "$input_msg" ]; then
    local mensaje="🔹 $input_msg. Presiona [ENTER] para continuar..."
  else
    local mensaje="✅ Comando ejecutado. Presiona [ENTER] para continuar..."
  fi
  echo -en "${Gray}"
  read -p "$mensaje"
  echo -en "${Color_Off}"
}

# ==============================================================================
# 📝 Función: path_shell_to_path_windows
# ==============================================================================
function path_shell_to_path_windows() {
    local PATH_REPO=$1
    local result
    result=$(echo "${PATH_REPO}" | sed -r -e 's@^/drives/([a-zA-Z]+)/(.*)@/\1/\2@')
    result=$(echo "${result}" | sed "s@/@\\\\@/g")
    result=$(echo "${result}" | sed -r -e 's@^\\([a-zA-Z]+)\\(.*)$@\1:\\2@')
    echo "$result"
}

# ==============================================================================
# 📝 Función: path_windows_to_path_shell
# ==============================================================================
function path_windows_to_path_shell() {
    local PATH_REPO=$1
    if [[ -z "$PATH_REPO" ]]; then
        echo "Error: Debes proporcionar una ruta en formato Windows." >&2
        return 1
    fi
    local path_unix=$(echo "${PATH_REPO}" | sed 's|^\([A-Za-z]\):|/\L\1|;s|\\|/|g')
    if [[ -d "/mnt/c" ]]; then
        path_unix=$(echo "$PATH_REPO" | sed 's|^\([A-Za-z]\):|/mnt/\L\1|;s|\\|/|g')
        echo "$path_unix"
    else
        echo "$path_unix"
    fi
}

# ==============================================================================
# 📝 Función: path_to_laragon_format
# ==============================================================================
function path_to_laragon_format() {
    local PATH_INPUT="$1"
    local result
    if [[ -z "$PATH_INPUT" ]]; then
        echo "Error: Debes proporcionar una ruta." >&2
        return 1
    fi
    if [[ "$PATH_INPUT" =~ ^[A-Za-z]:\\ ]]; then
        result=$(echo "$PATH_INPUT" | sed -r -e 's@^([A-Za-z]):@\U\1:@' -e 's@\\@/@g')
    elif [[ "$PATH_INPUT" =~ ^/[A-Za-z]/ ]]; then
        result=$(echo "$PATH_INPUT" | sed -r -e 's@^/([a-zA-Z])@\U\1:@' -e 's@/@/@g')
    elif [[ "$PATH_INPUT" =~ ^/mnt/[A-Za-z]/ ]]; then
        result=$(echo "$PATH_INPUT" | sed -r -e 's@^/mnt/([a-zA-Z])@\U\1:@' -e 's@/@/@g')
    else
        echo "Error: Formato de ruta no reconocido." >&2
        return 1
    fi
    echo "\"${result}\""
}

# =============================================================================
# 🗃️ SECTION: Funciones de Gestión del JSON
# =============================================================================

# ==============================================================================
# 📝 Función: check_jq
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Verifica que jq esté instalado. Si no, intenta instalarlo o muestra instrucciones.
# ==============================================================================
check_jq() {
  if ! command -v jq &>/dev/null; then
    msg "⚠️  'jq' no está instalado." "WARNING"
    msg "Intentando instalar jq..." "INFO"
    if command -v apt-get &>/dev/null; then
      sudo apt-get install -y jq 2>/dev/null && return 0
    elif command -v yum &>/dev/null; then
      sudo yum install -y jq 2>/dev/null && return 0
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm jq 2>/dev/null && return 0
    fi
    msg "❌ No se pudo instalar jq automáticamente." "ERROR"
    msg "   Instálalo manualmente: sudo apt-get install jq" "ERROR"
    exit 1
  fi
}

# ==============================================================================
# 📝 Función: init_json
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Inicializa el archivo JSON si no existe, con estructura base.
# ==============================================================================
init_json() {
  if [[ ! -f "$PROJECTS_JSON" ]]; then
    msg "📄 Creando archivo de proyectos: ${PROJECTS_JSON}" "INFO"
    cat > "$PROJECTS_JSON" <<'EOF'
{
  "projects": []
}
EOF
    msg "✅ Archivo creado correctamente." "SUCCESS"
  fi
}

# ==============================================================================
# 📝 Función: get_next_id
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Calcula el siguiente ID disponible para un nuevo proyecto.
#   Usa el máximo ID existente + 1, así los IDs no se reusan al eliminar.
# ==============================================================================
get_next_id() {
  local max_id
  max_id=$(jq '[.projects[].id] | if length == 0 then 0 else max end' "$PROJECTS_JSON")
  echo $((max_id + 1))
}

# ==============================================================================
# 📝 Función: get_project_count
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Devuelve el número total de proyectos registrados.
# ==============================================================================
get_project_count() {
  jq '.projects | length' "$PROJECTS_JSON"
}

# ==============================================================================
# 📝 Función: project_exists_by_id
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Verifica si existe un proyecto con el ID dado.
#   Retorna 0 (existe) o 1 (no existe).
# ==============================================================================
project_exists_by_id() {
  local id="$1"
  local count
  count=$(jq --argjson id "$id" '[.projects[] | select(.id == $id)] | length' "$PROJECTS_JSON")
  [[ "$count" -gt 0 ]]
}

# ==============================================================================
# 📝 Función: project_exists_by_path
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Verifica si ya existe un proyecto con la ruta dada (evita duplicados).
# ==============================================================================
project_exists_by_path() {
  local path="$1"
  local count
  count=$(jq --arg path "$path" '[.projects[] | select(.path == $path)] | length' "$PROJECTS_JSON")
  [[ "$count" -gt 0 ]]
}

# =============================================================================
# 📋 SECTION: Funciones de Visualización
# =============================================================================

# ==============================================================================
# 📝 Función: print_header
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Imprime el encabezado principal del gestor de proyectos.
# ==============================================================================
print_header() {
  echo ""
  echo -e "${BCyan}╔══════════════════════════════════════════════════════════╗${Color_Off}"
  echo -e "${BCyan}║${BWhite}         📁  GESTOR DE RUTAS DE PROYECTOS              ${BCyan}  ║${Color_Off}"
  echo -e "${BCyan}║${BGray}         ${MY_INFO}  •  ${DATE_HOUR}${BCyan}            ║${Color_Off}"
  echo -e "${BCyan}╚══════════════════════════════════════════════════════════╝${Color_Off}"
  echo ""
}

# ==============================================================================
# 📝 Función: print_separator
# ==============================================================================
print_separator() {
  echo -e "${BGray}──────────────────────────────────────────────────────────${Color_Off}"
}

# ==============================================================================
# 📝 Función: list_projects
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Lista todos los proyectos guardados en el JSON con formato visual.
#
# 💡 Uso:
#   list_projects              # Lista todos
#   list_projects "busqueda"   # Filtra por descripción o ruta
# ==============================================================================
list_projects() {
  local filter="${1:-}"

  print_header

  local count
  count=$(get_project_count)

  if [[ "$count" -eq 0 ]]; then
    msg "  ℹ️  No hay proyectos registrados aún." "WARNING"
    msg "  Usa la opción [A] para agregar tu primer proyecto." "INFO"
    echo ""
    return 0
  fi

  if [[ -n "$filter" ]]; then
    msg "  🔍 Filtrando por: \"${filter}\"" "INFO"
    print_separator
    echo ""
  fi

  # Leer proyectos del JSON y mostrarlos
  local projects_json_output
  if [[ -n "$filter" ]]; then
    # Filtrar por descripción o ruta (case-insensitive)
    projects_json_output=$(jq -r --arg f "$filter" '
      .projects[]
      | select(
          (.description | ascii_downcase | contains($f | ascii_downcase)) or
          (.path | ascii_downcase | contains($f | ascii_downcase))
        )
      | "\(.id)|\(.description)|\(.path)|\(.created_at // "N/A")"
    ' "$PROJECTS_JSON")
  else
    projects_json_output=$(jq -r '
      .projects[]
      | "\(.id)|\(.description)|\(.path)|\(.created_at // "N/A")"
    ' "$PROJECTS_JSON")
  fi

  if [[ -z "$projects_json_output" ]]; then
    msg "  ⚠️  No se encontraron proyectos con ese filtro." "WARNING"
    echo ""
    return 0
  fi

  local displayed=0
  while IFS='|' read -r id description path created_at; do
    displayed=$((displayed + 1))
    echo -e "  ${BYellow}[${id}]${Color_Off} ${BCyan}📁 ${BWhite}${description}${Color_Off}"
    echo -e "       ${BGray}${path}${Color_Off}"
    echo -e "       ${Gray}🕒 Agregado: ${created_at}${Color_Off}"
    echo ""
  done <<< "$projects_json_output"

  print_separator
  if [[ -n "$filter" ]]; then
    msg "  📊 ${displayed} proyecto(s) encontrado(s) con filtro \"${filter}\"" "INFO"
  else
    msg "  📊 Total: ${count} proyecto(s) registrado(s)" "INFO"
  fi
  echo ""
}

# ==============================================================================
# 📝 Función: show_project_detail
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Muestra el detalle completo de un proyecto por su ID.
# ==============================================================================
show_project_detail() {
  local id="$1"

  if ! project_exists_by_id "$id"; then
    msg "❌ No existe ningún proyecto con ID: ${id}" "ERROR"
    return 1
  fi

  echo ""
  print_separator
  echo -e "  ${BYellow}Detalle del Proyecto ID: ${id}${Color_Off}"
  print_separator
  jq -r --argjson id "$id" '
    .projects[] | select(.id == $id) |
    "  📝 ID:          \(.id)\n" +
    "  📌 Descripción: \(.description)\n" +
    "  📁 Ruta:        \(.path)\n" +
    "  🕒 Creado:      \(.created_at // "N/A")\n" +
    "  ✏️  Actualizado: \(.updated_at // "N/A")"
  ' "$PROJECTS_JSON"
  print_separator
  echo ""
}

# =============================================================================
# ➕ SECTION: Funciones de Escritura (CRUD)
# =============================================================================

# ==============================================================================
# 📝 Función: add_project
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Agrega un nuevo proyecto al archivo JSON.
#   Valida duplicados de ruta antes de insertar.
#
# 💡 Uso interactivo:
#   add_project
#
# 💡 Uso con parámetros:
#   add_project "Descripción del proyecto" "/ruta/al/proyecto"
# ==============================================================================
add_project() {
  local description="${1:-}"
  local path="${2:-}"

  echo ""
  msg "➕ AGREGAR NUEVO PROYECTO" "INFO"
  print_separator

  # Solicitar descripción si no se pasó como argumento
  if [[ -z "$description" ]]; then
    echo -en "  ${BWhite}📌 Descripción del proyecto: ${Color_Off}"
    read -r description
  fi

  if [[ -z "$description" ]]; then
    msg "❌ La descripción no puede estar vacía." "ERROR"
    return 1
  fi

  # Solicitar ruta si no se pasó como argumento
  if [[ -z "$path" ]]; then
    echo -en "  ${BWhite}📁 Ruta del proyecto: ${Color_Off}"
    read -r path
  fi

  if [[ -z "$path" ]]; then
    msg "❌ La ruta no puede estar vacía." "ERROR"
    return 1
  fi

  # Verificar duplicado de ruta
  if project_exists_by_path "$path"; then
    msg "⚠️  Ya existe un proyecto registrado con esa ruta:" "WARNING"
    jq -r --arg p "$path" '
      .projects[] | select(.path == $p) |
      "  [ID: \(.id)] \(.description) → \(.path)"
    ' "$PROJECTS_JSON"
    echo ""
    echo -en "  ${BYellow}¿Deseas agregarlo de todas formas? [s/N]: ${Color_Off}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
      msg "  ↩️  Operación cancelada." "WARNING"
      return 0
    fi
  fi

  # Calcular nuevo ID y timestamp
  local new_id
  new_id=$(get_next_id)
  local now
  now=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || TZ="America/Lima" date "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date "+%Y-%m-%d %H:%M:%S")

  # Insertar en JSON usando jq
  local tmp_file
  tmp_file="${TEMP_FILE_JQ}"
  jq --argjson id "$new_id" \
     --arg desc "$description" \
     --arg path "$path" \
     --arg now "$now" \
     '.projects += [{
        "id": $id,
        "description": $desc,
        "path": $path,
        "created_at": $now,
        "updated_at": $now
      }]' "$PROJECTS_JSON" > "$tmp_file" && mv "$tmp_file" "$PROJECTS_JSON"

  echo ""
  msg "✅ Proyecto agregado exitosamente con ID: ${new_id}" "SUCCESS"
  echo -e "  ${BGray}Descripción : ${description}${Color_Off}"
  echo -e "  ${BGray}Ruta        : ${path}${Color_Off}"
  echo ""
}

# ==============================================================================
# 📝 Función: edit_project
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Edita la descripción y/o ruta de un proyecto existente por su ID.
#   Muestra los valores actuales y permite dejarlos en blanco para no cambiarlos.
#
# 💡 Uso:
#   edit_project        # Solicita ID interactivamente
#   edit_project 3      # Edita el proyecto con ID 3
# ==============================================================================
edit_project() {
  local id="${1:-}"

  echo ""
  msg "✏️  EDITAR PROYECTO" "INFO"
  print_separator

  if [[ -z "$id" ]]; then
    list_projects
    echo -en "  ${BWhite}🔢 ID del proyecto a editar: ${Color_Off}"
    read -r id
  fi

  if ! [[ "$id" =~ ^[0-9]+$ ]]; then
    msg "❌ ID inválido. Debe ser un número." "ERROR"
    return 1
  fi

  if ! project_exists_by_id "$id"; then
    msg "❌ No existe ningún proyecto con ID: ${id}" "ERROR"
    return 1
  fi

  # Mostrar valores actuales
  local current_desc current_path
  current_desc=$(jq -r --argjson id "$id" '.projects[] | select(.id == $id) | .description' "$PROJECTS_JSON")
  current_path=$(jq -r --argjson id "$id" '.projects[] | select(.id == $id) | .path' "$PROJECTS_JSON")

  echo ""
  echo -e "  ${BGray}Valores actuales:${Color_Off}"
  echo -e "  ${BYellow}[${id}]${Color_Off} ${BCyan}${current_desc}${Color_Off}"
  echo -e "       ${BGray}${current_path}${Color_Off}"
  echo ""
  msg "  (Deja en blanco y presiona ENTER para mantener el valor actual)" "DEBUG"
  echo ""

  echo -en "  ${BWhite}📌 Nueva descripción [${current_desc}]: ${Color_Off}"
  read -r new_desc

  echo -en "  ${BWhite}📁 Nueva ruta [${current_path}]: ${Color_Off}"
  read -r new_path

  # Usar valores actuales si el usuario no ingresó nada
  [[ -z "$new_desc" ]] && new_desc="$current_desc"
  [[ -z "$new_path" ]] && new_path="$current_path"

  # Verificar si hubo cambios
  if [[ "$new_desc" == "$current_desc" && "$new_path" == "$current_path" ]]; then
    msg "  ℹ️  No se realizaron cambios." "WARNING"
    return 0
  fi

  local now
  now=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || TZ="America/Lima" date "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date "+%Y-%m-%d %H:%M:%S")

  local tmp_file
  tmp_file="${TEMP_FILE_JQ}"
  jq --argjson id "$id" \
     --arg desc "$new_desc" \
     --arg path "$new_path" \
     --arg now "$now" \
     '.projects = [.projects[] | if .id == $id then
        .description = $desc | .path = $path | .updated_at = $now
      else . end]' "$PROJECTS_JSON" > "$tmp_file" && mv "$tmp_file" "$PROJECTS_JSON"

  echo ""
  msg "✅ Proyecto ID ${id} actualizado exitosamente." "SUCCESS"
  echo -e "  ${BGray}Descripción : ${new_desc}${Color_Off}"
  echo -e "  ${BGray}Ruta        : ${new_path}${Color_Off}"
  echo ""
}

# ==============================================================================
# 📝 Función: delete_project
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Elimina un proyecto del JSON por su ID. Solicita confirmación antes de borrar.
#
# 💡 Uso:
#   delete_project       # Solicita ID interactivamente
#   delete_project 3     # Elimina el proyecto con ID 3
# ==============================================================================
delete_project() {
  local id="${1:-}"

  echo ""
  msg "🗑️  ELIMINAR PROYECTO" "INFO"
  print_separator

  if [[ -z "$id" ]]; then
    list_projects
    echo -en "  ${BWhite}🔢 ID del proyecto a eliminar: ${Color_Off}"
    read -r id
  fi

  if ! [[ "$id" =~ ^[0-9]+$ ]]; then
    msg "❌ ID inválido. Debe ser un número." "ERROR"
    return 1
  fi

  if ! project_exists_by_id "$id"; then
    msg "❌ No existe ningún proyecto con ID: ${id}" "ERROR"
    return 1
  fi

  # Mostrar el proyecto a eliminar
  local desc path
  desc=$(jq -r --argjson id "$id" '.projects[] | select(.id == $id) | .description' "$PROJECTS_JSON")
  path=$(jq -r --argjson id "$id" '.projects[] | select(.id == $id) | .path' "$PROJECTS_JSON")

  echo ""
  echo -e "  ${BRed}⚠️  Vas a eliminar el siguiente proyecto:${Color_Off}"
  echo ""
  echo -e "  ${BYellow}[${id}]${Color_Off} ${BWhite}${desc}${Color_Off}"
  echo -e "       ${BGray}${path}${Color_Off}"
  echo ""
  echo -en "  ${BRed}¿Confirmas la eliminación? [s/N]: ${Color_Off}"
  read -r confirm

  if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    msg "  ↩️  Operación cancelada." "WARNING"
    return 0
  fi

  local tmp_file
  tmp_file="${TEMP_FILE_JQ}"
  jq --argjson id "$id" \
     '.projects = [.projects[] | select(.id != $id)]' \
     "$PROJECTS_JSON" > "$tmp_file" && mv "$tmp_file" "$PROJECTS_JSON"

  echo ""
  msg "✅ Proyecto ID ${id} eliminado correctamente." "SUCCESS"
  echo ""
}

# ==============================================================================
# 📝 Función: delete_all_projects
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Elimina TODOS los proyectos del JSON. Solicita doble confirmación.
# ==============================================================================
delete_all_projects() {
  echo ""
  msg "💣 ELIMINAR TODOS LOS PROYECTOS" "ERROR"
  print_separator

  local count
  count=$(get_project_count)

  if [[ "$count" -eq 0 ]]; then
    msg "  ℹ️  No hay proyectos para eliminar." "WARNING"
    return 0
  fi

  echo ""
  msg "  ⚠️  Esta acción eliminará ${count} proyecto(s) de forma permanente." "WARNING"
  echo -en "  ${BRed}Escribe 'CONFIRMAR' para continuar: ${Color_Off}"
  read -r confirm

  if [[ "$confirm" != "CONFIRMAR" ]]; then
    msg "  ↩️  Operación cancelada." "WARNING"
    return 0
  fi

  local tmp_file
  tmp_file="${TEMP_FILE_JQ}"
  jq '.projects = []' "$PROJECTS_JSON" > "$tmp_file" && mv "$tmp_file" "$PROJECTS_JSON"

  echo ""
  msg "✅ Todos los proyectos han sido eliminados." "SUCCESS"
  echo ""
}

# ==============================================================================
# 📝 Función: search_projects
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Busca proyectos por descripción o ruta (case-insensitive).
# ==============================================================================
search_projects() {
  local term="${1:-}"

  if [[ -z "$term" ]]; then
    echo -en "  ${BWhite}🔍 Término de búsqueda: ${Color_Off}"
    read -r term
  fi

  if [[ -z "$term" ]]; then
    msg "❌ Debes ingresar un término de búsqueda." "ERROR"
    return 1
  fi

  list_projects "$term"
}

# ==============================================================================
# 📝 Función: export_projects
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Exporta la lista de proyectos a un archivo de texto legible.
#
# 💡 Uso:
#   export_projects                         # Exporta a projects_export.txt
#   export_projects "/ruta/mi_export.txt"   # Exporta a ruta específica
# ==============================================================================
export_projects() {
  local output_file="${1:-${CURRENT_DIR}/projects_export.txt}"
  local count
  count=$(get_project_count)

  if [[ "$count" -eq 0 ]]; then
    msg "  ℹ️  No hay proyectos para exportar." "WARNING"
    return 0
  fi

  {
    echo "========================================================="
    echo "  LISTADO DE PROYECTOS - Exportado el ${DATE_HOUR}"
    echo "  Usuario: ${MY_INFO}"
    echo "========================================================="
    echo ""

    jq -r '.projects[] | "[\(.id)] 📁 \(.description)\n     \(.path)\n     🕒 \(.created_at // "N/A")\n"' "$PROJECTS_JSON"

    echo "========================================================="
    echo "  Total: ${count} proyecto(s)"
    echo "========================================================="
  } > "$output_file"

  msg "✅ Proyectos exportados a: ${output_file}" "SUCCESS"
}

# ==============================================================================
# 📝 Función: import_projects
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Importa proyectos desde otro archivo JSON, fusionando con el actual.
#   Evita duplicar proyectos con la misma ruta.
#
# 💡 Uso:
#   import_projects "/ruta/projects_backup.json"
# ==============================================================================
import_projects() {
  local import_file="${1:-}"

  echo ""
  msg "📥 IMPORTAR PROYECTOS" "INFO"
  print_separator

  if [[ -z "$import_file" ]]; then
    echo -en "  ${BWhite}📄 Ruta del archivo JSON a importar: ${Color_Off}"
    read -r import_file
  fi

  if [[ ! -f "$import_file" ]]; then
    msg "❌ Archivo no encontrado: ${import_file}" "ERROR"
    return 1
  fi

  # Validar que sea JSON válido con estructura correcta
  if ! jq -e '.projects' "$import_file" &>/dev/null; then
    msg "❌ El archivo no tiene el formato correcto (debe tener clave 'projects')." "ERROR"
    return 1
  fi

  local import_count
  import_count=$(jq '.projects | length' "$import_file")
  msg "  📊 Proyectos en el archivo a importar: ${import_count}" "INFO"

  local added=0
  local skipped=0

  while IFS='|' read -r desc path; do
    if project_exists_by_path "$path"; then
      skipped=$((skipped + 1))
    else
      local now
      now=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date "+%Y-%m-%d %H:%M:%S")
      add_project "$desc" "$path" > /dev/null
      added=$((added + 1))
    fi
  done < <(jq -r '.projects[] | "\(.description)|\(.path)"' "$import_file")

  echo ""
  msg "✅ Importación completada: ${added} agregado(s), ${skipped} omitido(s) (duplicados)." "SUCCESS"
  echo ""
}

# ==============================================================================
# 📝 Función: backup_json
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Crea una copia de seguridad del archivo JSON con timestamp en el nombre.
# ==============================================================================
backup_json() {
  local backup_file="${PROJECTS_JSON%.json}_backup_$(date +%Y%m%d_%H%M%S).json"
  cp "$PROJECTS_JSON" "$backup_file"
  msg "✅ Backup creado: ${backup_file}" "SUCCESS"
}

# ==============================================================================
# 📝 Función: copy_path_to_clipboard
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Copia la ruta de un proyecto al portapapeles (requiere xclip o xsel en Linux,
#   o pbcopy en macOS).
# ==============================================================================
copy_path_to_clipboard() {
  local id="${1:-}"

  if [[ -z "$id" ]]; then
    list_projects
    echo -en "  ${BWhite}🔢 ID del proyecto a copiar: ${Color_Off}"
    read -r id
  fi

  if ! [[ "$id" =~ ^[0-9]+$ ]]; then
    msg "❌ ID inválido." "ERROR"
    return 1
  fi

  if ! project_exists_by_id "$id"; then
    msg "❌ No existe ningún proyecto con ID: ${id}" "ERROR"
    return 1
  fi

  local path
  path=$(jq -r --argjson id "$id" '.projects[] | select(.id == $id) | .path' "$PROJECTS_JSON")

  # Intentar copiar al portapapeles
  if command -v xclip &>/dev/null; then
    echo -n "$path" | xclip -selection clipboard
    msg "✅ Ruta copiada al portapapeles: ${path}" "SUCCESS"
  elif command -v xsel &>/dev/null; then
    echo -n "$path" | xsel --clipboard --input
    msg "✅ Ruta copiada al portapapeles: ${path}" "SUCCESS"
  elif command -v pbcopy &>/dev/null; then
    echo -n "$path" | pbcopy
    msg "✅ Ruta copiada al portapapeles: ${path}" "SUCCESS"
  else
    msg "⚠️  No se encontró xclip/xsel/pbcopy. Ruta:" "WARNING"
    echo -e "  ${BWhite}${path}${Color_Off}"
  fi
}

# ==============================================================================
# 📝 Función: navigate_to_project
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Abre una nueva shell interactiva posicionada en el directorio del proyecto.
#   Al escribir "exit" o presionar Ctrl+D, regresa al gestor.
#
# 💡 Uso interactivo:
#   navigate_to_project        # Muestra lista y pide ID
#   navigate_to_project 3      # Navega directo al proyecto con ID 3
#
# 💡 Uso CLI con eval (para cambiar dir en la shell actual):
#   eval "$(./project_manager.sh goto 3)"
# ==============================================================================
navigate_to_project() {
  local id="${1:-}"

  echo ""
  msg "🚀 INGRESAR AL DIRECTORIO DEL PROYECTO" "INFO"
  print_separator

  if [[ -z "$id" ]]; then
    list_projects
    echo -en "  ${BWhite}🔢 ID del proyecto (o ENTER para cancelar): ${Color_Off}"
    read -r id
  fi

  # Cancelar si no ingresó nada
  if [[ -z "$id" ]]; then
    msg "  ↩️  Operación cancelada." "WARNING"
    return 0
  fi

  if ! [[ "$id" =~ ^[0-9]+$ ]]; then
    msg "❌ ID inválido. Debe ser un número entero." "ERROR"
    return 1
  fi

  if ! project_exists_by_id "$id"; then
    msg "❌ No existe ningún proyecto con ID: ${id}" "ERROR"
    return 1
  fi

  local proj_path proj_desc
  proj_path=$(jq -r --argjson id "$id" '.projects[] | select(.id == $id) | .path' "$PROJECTS_JSON")
  proj_desc=$(jq -r --argjson id "$id" '.projects[] | select(.id == $id) | .description' "$PROJECTS_JSON")

  # Verificar que el directorio exista y sea accesible
  if [[ ! -d "$proj_path" ]]; then
    msg "⚠️  El directorio no existe o no es accesible:" "WARNING"
    echo -e "   ${BRed}${proj_path}${Color_Off}"
    echo ""
    return 1
  fi

  echo ""
  msg "  📌 Proyecto : ${proj_desc}" "SUCCESS"
  msg "  📁 Ruta     : ${proj_path}" "INFO"
  echo ""
  echo -e "  ${BGray}Escribe ${BYellow}exit${BGray} o presiona ${BYellow}Ctrl+D${BGray} para volver al gestor.${Color_Off}"
  print_separator
  echo ""

  # Abre nueva shell interactiva en el directorio del proyecto.
  # exec reemplaza el proceso actual; al salir regresa al punto de llamada.
  exec bash -c "cd \"$proj_path\" && exec bash -i"
}

# ==============================================================================
# 📝 Función: show_json_raw
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Muestra el contenido raw del archivo JSON con formato colorizado (jq).
# ==============================================================================
show_json_raw() {
  echo ""
  msg "📄 Contenido del archivo: ${PROJECTS_JSON}" "INFO"
  print_separator
  jq '.' "$PROJECTS_JSON"
  print_separator
  echo ""
}

# =============================================================================
# 🎛️ SECTION: Menú Principal
# =============================================================================

# ==============================================================================
# 📝 Función: show_menu
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Muestra el menú principal del gestor de proyectos.
# ==============================================================================
show_menu() {
  echo ""
  echo -e "${BCyan}╔══════════════════════════════════════════════════════════╗${Color_Off}"
  echo -e "${BCyan}║${BWhite}                  📋  MENÚ PRINCIPAL                   ${BCyan}  ║${Color_Off}"
  echo -e "${BCyan}╠══════════════════════════════════════════════════════════╣${Color_Off}"
  echo -e "${BCyan}║${Color_Off}                                                          ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BYellow}[L]${Color_Off} ${White}📋 Listar todos los proyectos${Color_Off}                   ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BYellow}[A]${Color_Off} ${White}➕ Agregar nuevo proyecto${Color_Off}                       ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BYellow}[E]${Color_Off} ${White}✏️  Editar proyecto existente${Color_Off}                   ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BYellow}[D]${Color_Off} ${White}🗑️  Eliminar proyecto por ID${Color_Off}                    ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BYellow}[S]${Color_Off} ${White}🔍 Buscar proyectos${Color_Off}                             ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BYellow}[V]${Color_Off} ${White}🔎 Ver detalle de proyecto${Color_Off}                      ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BYellow}[C]${Color_Off} ${White}📋 Copiar ruta al portapapeles${Color_Off}                  ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BYellow}[N]${Color_Off} ${White}🚀 Ingresar al directorio del proyecto${Color_Off}          ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}                                                          ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${BGray}   ── Avanzado ──────────────────────────────────────${Color_Off}  ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}                                                          ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BPurple}[X]${Color_Off} ${White}📤 Exportar lista a .txt${Color_Off}                        ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BPurple}[I]${Color_Off} ${White}📥 Importar desde otro JSON${Color_Off}                     ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BPurple}[B]${Color_Off} ${White}💾 Backup del JSON${Color_Off}                              ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BPurple}[J]${Color_Off} ${White}📄 Ver JSON raw${Color_Off}                                 ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BRed}[Z]${Color_Off} ${White}💣 Eliminar TODOS los proyectos${Color_Off}                  ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}                                                          ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}   ${BGray}[Q]${Color_Off} ${Gray}🚪 Salir${Color_Off}                                         ${BCyan}║${Color_Off}"
  echo -e "${BCyan}║${Color_Off}                                                          ${BCyan}║${Color_Off}"
  echo -e "${BCyan}╚══════════════════════════════════════════════════════════╝${Color_Off}"
  echo ""
  echo -en "  ${BWhite}👉 Selecciona una opción: ${Color_Off}"
}

# ==============================================================================
# 📝 Función: main_menu
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Bucle principal del menú interactivo del gestor de proyectos.
# ==============================================================================
main_menu() {
  local option

  while true; do
    show_menu
    read -r option

    # Convertir a mayúsculas para aceptar minúsculas también
    option="${option^^}"

    case "$option" in
      L)
        list_projects
        echo ""
        echo -en "  ${BWhite}🚀 Ingresar a un directorio? [ID o ENTER para omitir]: ${Color_Off}"
        read -r _nav_id
        if [[ -n "$_nav_id" ]]; then
          navigate_to_project "$_nav_id"
        fi
        ;;
      A) add_project ;;
      E) edit_project ;;
      D) delete_project ;;
      S) search_projects ;;
      V)
        echo -en "  ${BWhite}🔢 ID del proyecto a ver: ${Color_Off}"
        read -r view_id
        show_project_detail "$view_id"
        ;;
      C) copy_path_to_clipboard ;;
      N) navigate_to_project ;;
      X) export_projects ;;
      I) import_projects ;;
      B) backup_json ;;
      J) show_json_raw ;;
      Z) delete_all_projects ;;
      Q)
        echo ""
        msg "👋 ¡Hasta luego! Saliendo del Gestor de Proyectos..." "SUCCESS"
        echo ""
        exit 0
        ;;
      *)
        echo ""
        msg "⚠️  Opción '${option}' no reconocida. Intenta de nuevo." "WARNING"
        echo ""
        ;;
    esac

    pause_continue
  done
}

# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================

# Verificar dependencias necesarias
check_jq

# Inicializar el archivo JSON si no existe
init_json

# Manejar argumentos de línea de comandos (modo no interactivo)
# Permite usar el script directamente sin menú:
#   ./project_manager.sh list
#   ./project_manager.sh add "Mi proyecto" "/ruta/proyecto"
#   ./project_manager.sh delete 3
#   ./project_manager.sh search "facturador"
if [[ $# -gt 0 ]]; then
  case "$1" in
    list|ls)       list_projects "${2:-}" ;;
    add)           add_project "${2:-}" "${3:-}" ;;
    edit)          edit_project "${2:-}" ;;
    delete|rm)     delete_project "${2:-}" ;;
    search)        search_projects "${2:-}" ;;
    detail|view)   show_project_detail "${2:-}" ;;
    export)        export_projects "${2:-}" ;;
    import)        import_projects "${2:-}" ;;
    backup)        backup_json ;;
    json)          show_json_raw ;;
    copy)          copy_path_to_clipboard "${2:-}" ;;
    goto|go|cd)
      # Modo eval: imprime el comando cd para ser evaluado por la shell padre.
      # Uso: eval "$(./project_manager.sh goto 3)"
      _goto_id="${2:-}"
      if [[ -z "$_goto_id" ]]; then
        msg "❌ Debes indicar el ID del proyecto. Ej: ./$(basename "$0") goto 3" "ERROR"
        exit 1
      fi
      if ! project_exists_by_id "$_goto_id"; then
        msg "❌ No existe ningún proyecto con ID: ${_goto_id}" "ERROR"
        exit 1
      fi
      _goto_path=$(jq -r --argjson id "$_goto_id" '.projects[] | select(.id == $id) | .path' "$PROJECTS_JSON")
      if [[ ! -d "$_goto_path" ]]; then
        msg "⚠️  El directorio no existe: ${_goto_path}" "WARNING"
        exit 1
      fi
      # Imprime el comando cd (para uso con eval en la shell padre)
      echo "cd \"$_goto_path\""
      ;;
    help|-h|--help)
      print_header
      echo -e "  ${BWhite}Uso:${Color_Off} ${BGray}./$(basename "$0") [comando] [argumentos]${Color_Off}"
      echo ""
      echo -e "  ${BYellow}Comandos disponibles:${Color_Off}"
      echo -e "  ${BGray}  list [filtro]         ${Color_Off}→ Listar proyectos (opcional: filtro de búsqueda)"
      echo -e "  ${BGray}  add [desc] [ruta]     ${Color_Off}→ Agregar proyecto"
      echo -e "  ${BGray}  edit [id]             ${Color_Off}→ Editar proyecto por ID"
      echo -e "  ${BGray}  delete [id]           ${Color_Off}→ Eliminar proyecto por ID"
      echo -e "  ${BGray}  search [término]      ${Color_Off}→ Buscar proyectos"
      echo -e "  ${BGray}  detail [id]           ${Color_Off}→ Ver detalle de proyecto"
      echo -e "  ${BGray}  export [archivo]      ${Color_Off}→ Exportar lista a txt"
      echo -e "  ${BGray}  import [archivo]      ${Color_Off}→ Importar desde JSON"
      echo -e "  ${BGray}  backup                ${Color_Off}→ Crear backup del JSON"
      echo -e "  ${BGray}  json                  ${Color_Off}→ Ver contenido JSON raw"
      echo -e "  ${BGray}  copy [id]             ${Color_Off}→ Copiar ruta al portapapeles"
      echo -e "  ${BGray}  goto [id]             ${Color_Off}→ Imprimir cd para navegar al proyecto (usar con eval)"
      echo ""
      echo -e "  ${BYellow}💡 Tip — navegar cambiando el directorio de tu shell actual:${Color_Off}"
      echo -e "  ${BGray}  Agrega esto a tu ${BWhite}~/.bashrc${BGray}:${Color_Off}"
      echo -e "  ${BCyan}    function pm-goto() { eval \"\$($(realpath "$PATH_SCRIPT") goto \$1)\"; }${Color_Off}"
      echo -e "  ${BGray}  Luego usa: ${BYellow}pm-goto 3${Color_Off}"
      echo ""
      echo -e "  ${BYellow}Sin argumentos:${Color_Off} abre el menú interactivo"
      echo ""
      ;;
    *)
      msg "❌ Comando desconocido: ${1}. Usa './$(basename "$0") help' para ver los comandos." "ERROR"
      exit 1
      ;;
  esac
else
  # Sin argumentos: lanzar el menú interactivo
  main_menu
fi

PROJECT_EOF

msg "Archivo instalado correctamente." "SUCCESS"

msg "PASO 2/2 — Asignando permisos de ejecución" "STEP"

chmod +x "${PROJECT_MANAGER_FILE}"

msg "Permisos asignados correctamente." "SUCCESS"

# =============================================================================
# ✅ Resumen final
# =============================================================================

echo ""
echo -e "${BGreen}╔══════════════════════════════════════════════════╗${Color_Off}"
echo -e "${BGreen}║     ✔  Instalación completada con éxito          ║${Color_Off}"
echo -e "${BGreen}╚══════════════════════════════════════════════════╝${Color_Off}"
echo ""
msg "Ubicado en : ${PROJECT_MANAGER_FILE}" "SUCCESS"
echo ""
msg "Modo de uso:" "SUCCESS"
msg "  pm          → abre el menú interactivo" "SUCCESS"
msg "  pm list     → lista todos los proyectos" "SUCCESS"
msg "  pm help     → muestra la ayuda y comandos" "SUCCESS"
echo ""

exit 0