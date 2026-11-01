#!/bin/bash
VERSION_SCRIPT="1.0.0"
# ==============================================================================
# 📦 Script: setup_bat.sh
# 📝 Descripción: Instala y configura 'bat' (batcat) en Debian/Ubuntu/Kali,
#                 RHEL/Fedora/Rocky/Alma/CentOS y Arch/Manjaro.
#                 Deja el comando 'bat' disponible y ejecutable para TODOS los
#                 usuarios del sistema. Ejecución desatendida.
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

# Ubicación global del comando 'bat' (accesible para todos los usuarios)
BAT_LINK="/usr/local/bin/bat"

# Configuración de bat del usuario actual
BAT_CONFIG_DIR="${HOME}/.config/bat"
BAT_CONFIG_FILE="${BAT_CONFIG_DIR}/config"

# Binario precompilado (fallback si el gestor de paquetes no ofrece 'bat')
BAT_VERSION="0.24.0"
BAT_TMP_DIR="/tmp/bat_install_$$"

# Variables que se rellenan durante la ejecución
DISTRO_ID="desconocida"
DISTRO_LIKE=""
PKG_MANAGER=""
SUDO_REFRESH_PID=""

# =============================================================================
# 📝 SECTION: Funciones de utilidad
# =============================================================================

# ------------------------------------------------------------------------------
# msg: Imprime mensajes con colores según el nivel
# Uso: msg "texto" "INFO|WARNING|ERROR|SUCCESS|DEBUG|STEP"
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
# Uso: run_cmd sudo apt-get install -y bat
# ------------------------------------------------------------------------------
run_cmd() {
  echo -e "  ${BGray}›${Color_Off} ${BYellow}$*${Color_Off}"
  "$@"
  local exit_code=$?
  return $exit_code
}

# ------------------------------------------------------------------------------
# run_cmd_silent: Ejecuta el comando suprimiendo stdout (stderr visible).
# Uso: run_cmd_silent sudo apt-get update
# ------------------------------------------------------------------------------
run_cmd_silent() {
  echo -e "  ${BGray}›${Color_Off} ${BYellow}$*${Color_Off} ${BGray}(silencioso)${Color_Off}"
  "$@" > /dev/null
  local exit_code=$?
  return $exit_code
}

# ------------------------------------------------------------------------------
# check_cmd: Verifica si un comando existe en el PATH
# Uso: check_cmd bat || exit 1
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

# ------------------------------------------------------------------------------
# detect_distro: Detecta distribución y gestor de paquetes disponible
# Rellena: DISTRO_ID, DISTRO_LIKE, PKG_MANAGER
# ------------------------------------------------------------------------------
detect_distro() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    DISTRO_ID=$(. /etc/os-release && echo "${ID:-desconocida}")
    DISTRO_LIKE=$(. /etc/os-release && echo "${ID_LIKE:-}")
  fi

  if   command -v apt-get &>/dev/null; then PKG_MANAGER="apt"
  elif command -v dnf     &>/dev/null; then PKG_MANAGER="dnf"
  elif command -v yum     &>/dev/null; then PKG_MANAGER="yum"
  elif command -v pacman  &>/dev/null; then PKG_MANAGER="pacman"
  else PKG_MANAGER=""
  fi
}

# ------------------------------------------------------------------------------
# install_bat_from_github: Fallback — descarga el binario precompilado (musl,
# estático) y lo instala en /usr/local/bin/bat. Sirve para cualquier distro.
# ------------------------------------------------------------------------------
install_bat_from_github() {
  local arch target url
  arch=$(uname -m)

  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-musl" ;;
    aarch64) target="aarch64-unknown-linux-gnu" ;;
    *)
      msg "Arquitectura no soportada para binario precompilado: ${arch}" "ERROR"
      return 1
      ;;
  esac

  url="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-${target}.tar.gz"
  msg "Descargando bat v${BAT_VERSION} (${target})..." "INFO"

  mkdir -p "${BAT_TMP_DIR}"

  if check_cmd curl; then
    run_cmd curl -fsSL "${url}" -o "${BAT_TMP_DIR}/bat.tar.gz" || return 1
  elif check_cmd wget; then
    run_cmd wget -q "${url}" -O "${BAT_TMP_DIR}/bat.tar.gz" || return 1
  else
    msg "Se necesita 'curl' o 'wget' para descargar el binario." "ERROR"
    return 1
  fi

  run_cmd tar -xzf "${BAT_TMP_DIR}/bat.tar.gz" -C "${BAT_TMP_DIR}" --strip-components=1 || return 1
  run_cmd sudo install -m 0755 "${BAT_TMP_DIR}/bat" "${BAT_LINK}" || return 1

  msg "Binario instalado en ${BAT_LINK}" "SUCCESS"
  return 0
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

# Un único trap EXIT: limpia temporales y detiene el refresco de sudo.
# (Dos 'trap ... EXIT' se pisan entre sí; por eso se unifican aquí.)
cleanup_on_exit() {
  local exit_code=$?
  [[ -d "${BAT_TMP_DIR}" ]] && rm -rf "${BAT_TMP_DIR}" 2>/dev/null || true
  [[ -n "${SUDO_REFRESH_PID}" ]] && kill "${SUDO_REFRESH_PID}" 2>/dev/null || true
  if [[ $exit_code -ne 0 ]]; then
    msg "Script finalizado con errores (código: ${exit_code})." "ERROR"
  fi
}

trap 'handle_error $? $LINENO' ERR
trap 'cleanup_on_exit'          EXIT

# =============================================================================
# 🚦 SECTION: Validaciones previas
# =============================================================================

msg "Iniciando instalación de bat — Usuario: ${CURRENT_USER}@${CURRENT_PC_NAME}" "STEP"

# No ejecutar como root directamente
if [[ $EUID -eq 0 ]]; then
  msg "Este script NO debe ejecutarse como root. Usa un usuario normal con sudo." "ERROR"
  exit 1
fi

# Verificar sudo disponible
if ! command -v sudo &>/dev/null; then
  msg "'sudo' no está instalado. Instálalo como root y vuelve a ejecutar." "ERROR"
  exit 1
fi

if ! sudo -n true 2>/dev/null; then
  msg "Verificando privilegios sudo (se pedirá contraseña una sola vez)..." "INFO"
  sudo -v
fi

# Mantener sudo activo mientras corre el script
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_REFRESH_PID=$!

# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================

msg "=======================================================" "INFO"
msg "Ejecutando script para la instalación de bat..." "INFO"
msg "    Version: ${VERSION_SCRIPT}" "INFO"
msg "=======================================================" "INFO"
sleep 2

# =============================================================================
# 🔎 PASO 1: Detectar distribución y gestor de paquetes
# =============================================================================

msg "PASO 1/5 — Detectando distribución" "STEP"

detect_distro
msg "Distribución : ${DISTRO_ID} ${DISTRO_LIKE:+(familia: ${DISTRO_LIKE})}" "INFO"
msg "Arquitectura : $(uname -m)" "INFO"

if [[ -z "${PKG_MANAGER}" ]]; then
  msg "No se encontró apt, dnf, yum ni pacman. Se usará el binario de GitHub." "WARNING"
else
  msg "Gestor de paquetes: ${PKG_MANAGER}" "SUCCESS"
fi

# =============================================================================
# 📦 PASO 2: Instalar bat
# =============================================================================

msg "PASO 2/5 — Instalando bat" "STEP"

BAT_INSTALLED=false

# Si ya existe 'bat' o 'batcat', no reinstalar
if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
  msg "bat ya está instalado en el sistema. Se omite la instalación." "INFO"
  BAT_INSTALLED=true
fi

if [[ "${BAT_INSTALLED}" == false ]]; then
  case "${PKG_MANAGER}" in

    apt)
      # Debian / Ubuntu / Kali → el ejecutable se llama 'batcat'
      export DEBIAN_FRONTEND=noninteractive
      run_cmd sudo apt-get update -qq
      if run_cmd sudo apt-get install -y -qq bat; then
        BAT_INSTALLED=true
      else
        msg "El paquete 'bat' no está disponible en este repositorio." "WARNING"
      fi
      ;;

    dnf|yum)
      # Fedora trae 'bat' en sus repos; RHEL/Rocky/Alma/CentOS lo traen vía EPEL
      if [[ "${DISTRO_ID}" != "fedora" ]]; then
        msg "Habilitando EPEL (necesario en la familia RHEL)..." "INFO"
        if ! run_cmd sudo "${PKG_MANAGER}" install -y epel-release; then
          msg "No se pudo habilitar EPEL automáticamente (normal en RHEL puro)." "WARNING"
        fi
      fi
      if run_cmd sudo "${PKG_MANAGER}" install -y bat; then
        BAT_INSTALLED=true
      else
        msg "El paquete 'bat' no está disponible en los repositorios." "WARNING"
      fi
      ;;

    pacman)
      # Arch / Manjaro / EndeavourOS
      if run_cmd sudo pacman -S --noconfirm --needed bat; then
        BAT_INSTALLED=true
      else
        msg "Fallo al instalar 'bat' con pacman." "WARNING"
      fi
      ;;

    *)
      msg "Sin gestor de paquetes compatible." "WARNING"
      ;;
  esac
fi

# Fallback: binario precompilado desde GitHub
if [[ "${BAT_INSTALLED}" == false ]]; then
  msg "Intentando instalación alternativa con binario de GitHub..." "INFO"
  if install_bat_from_github; then
    BAT_INSTALLED=true
  else
    msg "No se pudo instalar bat por ningún método." "ERROR"
    exit 1
  fi
fi

msg "Instalación de bat completada." "SUCCESS"

# =============================================================================
# 🔗 PASO 3: Comando global 'bat' y permisos para todos los usuarios
# =============================================================================
# En Debian/Ubuntu/Kali el ejecutable es 'batcat'. Se crea /usr/local/bin/bat
# para que TODOS los usuarios puedan usar 'bat', y se asignan permisos de
# lectura y ejecución a todos (a+rx).

msg "PASO 3/5 — Configurando comando global 'bat'" "STEP"

if command -v batcat &>/dev/null && [[ ! -e "${BAT_LINK}" ]]; then
  BATCAT_PATH=$(command -v batcat)
  msg "Se detectó 'batcat' (${BATCAT_PATH}); creando enlace ${BAT_LINK}" "INFO"
  run_cmd sudo ln -sf "${BATCAT_PATH}" "${BAT_LINK}"
fi

if [[ -e "${BAT_LINK}" ]]; then
  # Permisos de lectura y ejecución para todos (usuario, grupo y otros)
  run_cmd sudo chmod a+rx "${BAT_LINK}"
  msg "Permisos a+rx aplicados sobre ${BAT_LINK}" "SUCCESS"
elif BAT_REAL=$(command -v bat); then
  # Instalado directamente como 'bat' (Arch, Fedora...): asegurar permisos
  run_cmd sudo chmod a+rx "${BAT_REAL}"
  msg "'bat' ya está en ${BAT_REAL}; permisos a+rx aplicados." "SUCCESS"
else
  msg "No se encontró el ejecutable 'bat' tras la instalación." "ERROR"
  exit 1
fi

# Verificar que el comando quedó disponible
if ! check_cmd bat; then
  msg "'bat' no está en el PATH. Revisa que /usr/local/bin esté incluido." "ERROR"
  exit 1
fi
msg "bat versión: $(bat --version | head -1)" "SUCCESS"
msg "Permisos    : $(ls -lL "$(command -v bat)" | awk '{print $1, $3, $4}')" "DEBUG"

# =============================================================================
# 🎨 PASO 4: Configuración del usuario (tema y estilo)
# =============================================================================

msg "PASO 4/5 — Creando configuración de bat" "STEP"

run_cmd mkdir -p "${BAT_CONFIG_DIR}"

if [[ -f "${BAT_CONFIG_FILE}" ]]; then
  msg "Ya existe ${BAT_CONFIG_FILE}; no se sobrescribe." "INFO"
else
  cat > "${BAT_CONFIG_FILE}" << 'BATEOF'
# Configuración de bat — generada por setup_bat.sh

# Tema de colores (ver opciones con: bat --list-themes)
--theme="OneHalfDark"

# Componentes visibles: números de línea, cambios de git y cabecera
--style="numbers,changes,header"

# Texto en cursiva cuando el tema lo permita
--italic-text=always

# Asociar extensiones de configuración con una sintaxis conocida
--map-syntax "*.conf:INI"
--map-syntax "*.cnf:INI"
--map-syntax "*.local:INI"
BATEOF
  msg "Configuración escrita en ${BAT_CONFIG_FILE}" "SUCCESS"
fi

# =============================================================================
# 🧪 PASO 5: Prueba de funcionamiento
# =============================================================================

msg "PASO 5/5 — Verificando funcionamiento" "STEP"

BAT_TEST_FILE=$(mktemp)
printf '#!/bin/bash\necho "bat funciona correctamente"\n' > "${BAT_TEST_FILE}"

if run_cmd_silent bat --paging=never --color=never "${BAT_TEST_FILE}"; then
  msg "Prueba de lectura superada." "SUCCESS"
else
  msg "bat se instaló pero la prueba de lectura falló." "WARNING"
fi
rm -f "${BAT_TEST_FILE}"

# =============================================================================
# ✅ Resumen final
# =============================================================================

echo ""
echo -e "${BGreen}╔══════════════════════════════════════════════════╗${Color_Off}"
echo -e "${BGreen}║       ✔  Instalación completada con éxito       ║${Color_Off}"
echo -e "${BGreen}╚══════════════════════════════════════════════════╝${Color_Off}"
echo ""
msg "bat          : $(bat --version | head -1)" "SUCCESS"
msg "Ejecutable   : $(command -v bat)" "SUCCESS"
msg "Config       : ${BAT_CONFIG_FILE}" "SUCCESS"
msg "Uso          : bat archivo.txt   |   bat -p archivo.txt (sin decoración)" "SUCCESS"
echo ""
msg "Ver temas disponibles: bat --list-themes" "INFO"
msg "Alias opcional       : echo \"alias cat='bat -pp'\" >> ~/.bashrc" "INFO"
echo ""

exit 0