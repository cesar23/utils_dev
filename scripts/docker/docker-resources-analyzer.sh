#!/bin/bash

# =============================================================================
# 🐋 SCRIPT: Docker Resources Analyzer
# =============================================================================
# Descripción: Análisis completo de recursos de Docker
# Autor: Script generado para análisis de Docker
# Fecha: 2025-12-15
# =============================================================================

# =============================================================================
# 🏆 SECTION: Configuración Inicial
# =============================================================================

DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d_%H:%M:%S" 2>/dev/null || TZ="America/Lima" date "+%Y-%m-%d_%H:%M:%S" 2>/dev/null || echo "$DATE_HOUR")
CURRENT_USER=$(id -un)
CURRENT_USER_HOME="${HOME:-$USERPROFILE}"
CURRENT_PC_NAME=$(hostname)
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"
PATH_SCRIPT=$(readlink -f "${BASH_SOURCE:-$0}")
SCRIPT_NAME=$(basename "$PATH_SCRIPT")
CURRENT_DIR=$(dirname "$PATH_SCRIPT")
NAME_DIR=$(basename "$CURRENT_DIR")
TEMP_PATH_SCRIPT=$(echo "$PATH_SCRIPT" | sed 's/.sh/.tmp/g')
TEMP_PATH_SCRIPT_SYSTEM=$(echo "${TMP}/${SCRIPT_NAME}" | sed 's/.sh/.tmp/g')
ROOT_PATH=$(realpath -m "${CURRENT_DIR}/..")

# =============================================================================
# 🎨 SECTION: Colores para su uso
# =============================================================================

Color_Off='\033[0m'
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
White='\033[0;37m'
Gray='\033[0;90m'

BBlack='\033[1;30m'
BRed='\033[1;31m'
BGreen='\033[1;32m'
BYellow='\033[1;33m'
BBlue='\033[1;34m'
BPurple='\033[1;35m'
BCyan='\033[1;36m'
BWhite='\033[1;37m'
BGray='\033[1;90m'

# =============================================================================
# ⚙️ SECTION: Core Functions
# =============================================================================

msg() {
  local message="$1"
  local level="${2:-OTHER}"

  case "$level" in
    INFO)
      echo -e "${BBlue}${message}${Color_Off}"
      ;;
    WARNING)
      echo -e "${BYellow}${message}${Color_Off}"
      ;;
    DEBUG)
      echo -e "${BPurple}${message}${Color_Off}"
      ;;
    ERROR)
      echo -e "${BRed}${message}${Color_Off}"
      ;;
    SUCCESS)
      echo -e "${BGreen}${message}${Color_Off}"
      ;;
    *)
      echo -e "${BGray}${message}${Color_Off}"
      ;;
  esac
}

my_banner(){
  echo ""
  echo -e "  ${BRed}╔══════════════════════════════════════════════════╗${Color_Off}"
  echo -e "  ${BRed}║${Color_Off}  ${BWhite} ██████╗ █████╗ ${Color_Off}      ${BRed}██████╗ ███████╗██╗   ██╗${Color_Off} ${BRed}║${Color_Off}"
  echo -e "  ${BRed}║${Color_Off}  ${BWhite}██╔════╝██╔══██╗${Color_Off}      ${BRed}██╔══██╗██╔════╝██║   ██║${Color_Off} ${BRed}║${Color_Off}"
  echo -e "  ${BRed}║${Color_Off}  ${BWhite}██║     ███████║${Color_Off}█████╗${BRed}██║  ██║█████╗  ██║   ██║${Color_Off} ${BRed}║${Color_Off}"
  echo -e "  ${BRed}║${Color_Off}  ${BWhite}██║     ██╔══██║${Color_Off}╚════╝${BRed}██║  ██║██╔══╝  ╚██╗ ██╔╝${Color_Off} ${BRed}║${Color_Off}"
  echo -e "  ${BRed}║${Color_Off}  ${BWhite}╚██████╗██║  ██║${Color_Off}      ${BRed}██████╔╝███████╗ ╚████╔╝ ${Color_Off} ${BRed}║${Color_Off}"
  echo -e "  ${BRed}║${Color_Off}  ${BWhite} ╚═════╝╚═╝  ╚═╝${Color_Off}      ${BRed}╚═════╝ ╚══════╝  ╚═══╝  ${Color_Off} ${BRed}║${Color_Off}"
  echo -e "  ${BRed}║${Purple}          Cesar Auris - perucaos@gmail.com        ${BRed}║${Color_Off}"
  echo -e "  ${BRed}╚══════════════════════════════════════════════════╝${Color_Off}"
  echo -e "  ${Gray}┌──────────────────────────────────────────────────┐${Color_Off}"
  echo -e "  ${Gray}│${Color_Off} ${BRed}[${Color_Off}${BWhite}*${Color_Off}${BRed}]${Color_Off} Config: ${BYellow}${SSH_CONFIG}${Color_Off}${Gray}         │${Color_Off}"
  echo -e "  ${Gray}└──────────────────────────────────────────────────┘${Color_Off}"
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

cleanup_on_exit() {
  local exit_code=$?

  if [[ -n "${TEMP_FILE_OK:-}" ]] && [[ -f "${TEMP_FILE_OK}" ]]; then
    rm -f "${TEMP_FILE_OK}" 2>/dev/null || true
  fi

  if [[ -n "${TEMP_FILE_ERR:-}" ]] && [[ -f "${TEMP_FILE_ERR}" ]]; then
    rm -f "${TEMP_FILE_ERR}" 2>/dev/null || true
  fi
}

trap 'handle_error $? $LINENO' ERR
trap 'cleanup_on_exit' EXIT

# =============================================================================
# 📊 SECTION: Docker Analysis Functions
# =============================================================================

print_header() {
  local title="$1"
  echo ""
  msg "═══════════════════════════════════════════════════════════════" "INFO"
  msg "  ${title}" "SUCCESS"
  msg "═══════════════════════════════════════════════════════════════" "INFO"
  echo ""
}

print_subheader() {
  local title="$1"
  echo ""
  msg "───────────────────────────────────────────────────────────────" "DEBUG"
  msg "  ${title}" "WARNING"
  msg "───────────────────────────────────────────────────────────────" "DEBUG"
}

check_docker() {
  if ! command -v docker &> /dev/null; then
    msg "Docker no está instalado o no está en el PATH" "ERROR"
    exit 1
  fi

  if ! docker info &> /dev/null; then
    msg "No se puede conectar al daemon de Docker" "ERROR"
    msg "Verifica que Docker esté corriendo y tengas permisos" "WARNING"
    exit 1
  fi
}

analyze_system_df() {
  print_subheader "📦 Uso de Espacio en Disco (docker system df)"

  docker system df

  echo ""
  msg "💡 Tip: Los recursos 'RECLAIMABLE' pueden ser liberados con docker system prune" "WARNING"
}

analyze_containers_stats() {
  print_subheader "📈 Estadísticas de Contenedores en Tiempo Real (docker ps -q | wc -l)"

  local running_containers=$(docker ps -q | wc -l)

  if [[ $running_containers -eq 0 ]]; then
    msg "No hay contenedores en ejecución" "WARNING"
    return
  fi

  msg "Contenedores activos: ${running_containers}" "INFO"
  echo ""

  docker stats --no-stream --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}"
}

analyze_container_logs() {
  print_subheader "📝 Análisis de Logs de Contenedores - /var/lib/docker/containers/*/*.log"

  msg "Top 10 archivos de log más grandes:" "INFO"
  echo ""

  # Obtener lista de logs con tamaños
  local logs_output=""
  if [[ $EUID -eq 0 ]]; then
    logs_output=$(du -sh /var/lib/docker/containers/*/*.log 2>/dev/null | sort -hr | head -n 10)
  else
    logs_output=$(sudo sh -c 'du -sh /var/lib/docker/containers/*/*.log 2>/dev/null | sort -hr | head -n 10' 2>/dev/null)
  fi

  if [[ -n "$logs_output" ]]; then
    # Crear un mapa de container_id -> container_name
    declare -A container_names
    while IFS= read -r line; do
      local container_id=$(echo "$line" | awk '{print $1}')
      local container_name=$(echo "$line" | awk '{print $2}')
      container_names["$container_id"]="$container_name"
    done < <(docker ps -a --format "{{.ID}} {{.Names}}")

    # Mostrar logs con nombres de contenedores
    printf "${BCyan}%-8s  %-25s  %s${Color_Off}\n" "TAMAÑO" "CONTENEDOR" "RUTA"
    printf "${Gray}%-8s  %-25s  %s${Color_Off}\n" "--------" "-------------------------" "------------------------------------------------------------"

    while IFS= read -r line; do
      local size=$(echo "$line" | awk '{print $1}')
      local log_path=$(echo "$line" | awk '{print $2}')

      # Extraer el container ID del path (los primeros 12 caracteres después de /containers/)
      local container_id=$(echo "$log_path" | grep -oP '/containers/\K[a-f0-9]{12}' | head -1)

      if [[ -z "$container_id" ]]; then
        # Si no encontramos con 12 caracteres, intentar con el ID completo
        container_id=$(echo "$log_path" | grep -oP '/containers/\K[a-f0-9]+' | head -1)
        container_id="${container_id:0:12}"
      fi

      local container_name="N/A"
      if [[ -n "$container_id" ]]; then
        # Buscar el nombre completo del contenedor
        for full_id in "${!container_names[@]}"; do
          if [[ "$full_id" == "$container_id"* ]]; then
            container_name="${container_names[$full_id]}"
            break
          fi
        done

        # Si no encontramos en el mapa, intentar directamente con docker
        if [[ "$container_name" == "N/A" ]]; then
          container_name=$(docker ps -a --filter "id=$container_id" --format "{{.Names}}" 2>/dev/null)
          [[ -z "$container_name" ]] && container_name="[$container_id]"
        fi
      fi

      # Colorear según el tamaño
      local color="$Green"
      if [[ "$size" =~ M ]]; then
        color="$Yellow"
      elif [[ "$size" =~ G ]]; then
        color="$Red"
      fi

      printf "${color}%-8s${Color_Off}  ${BWhite}%-25s${Color_Off}  ${Gray}%s${Color_Off}\n" \
        "$size" "$container_name" "$log_path"
    done <<< "$logs_output"

    # Calcular tamaño total de logs
    echo ""
    local total_log_size=""
    if [[ $EUID -eq 0 ]]; then
      total_log_size=$(du -ch /var/lib/docker/containers/*/*.log 2>/dev/null | tail -1 | awk '{print $1}')
    else
      total_log_size=$(sudo sh -c 'du -ch /var/lib/docker/containers/*/*.log 2>/dev/null | tail -1' 2>/dev/null | awk '{print $1}')
    fi

    if [[ -n "$total_log_size" ]]; then
      msg "📊 Tamaño total de logs: ${total_log_size}" "INFO"
    fi

    echo ""
    msg "💡 Tip: Puedes limpiar logs con: sudo truncate -s 0 /var/lib/docker/containers/*/*-json.log" "WARNING"
    msg "💡 O configurar rotación de logs en /etc/docker/daemon.json" "WARNING"
  else
    msg "No se pudo acceder a los logs de contenedores" "WARNING"
    msg "Posibles razones:" "DEBUG"
    msg "  • No hay contenedores con logs" "DEBUG"
    msg "  • Docker está configurado en otra ubicación" "DEBUG"
    msg "  • Necesitas permisos de sudo" "DEBUG"
    echo ""
    msg "Intenta ejecutar manualmente:" "INFO"
    msg "  sudo sh -c 'du -sh /var/lib/docker/containers/*/*.log | sort -hr | head -n 10'" "DEBUG"
  fi
}

analyze_images() {
  print_subheader "🖼️  Análisis de Imágenes Docker (docker images -q | wc -l)"

  local total_images=$(docker images -q | wc -l)
  local dangling_images=$(docker images -f "dangling=true" -q | wc -l)

  msg "Total de imágenes: ${total_images}" "INFO"
  msg "Imágenes huérfanas (dangling): ${dangling_images}" "WARNING"
  echo ""

  msg "Top 10 imágenes más grandes:" "INFO"
  echo ""
  docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.ID}}" | head -n 11

  if [[ $dangling_images -gt 0 ]]; then
    echo ""
    msg "⚠️  Hay ${dangling_images} imágenes huérfanas que pueden ser eliminadas" "WARNING"
    msg "Comando: docker image prune" "DEBUG"
  fi
}

analyze_volumes() {
  print_subheader "💾 Análisis de Volúmenes Docker (docker volume ls -q | wc -l)"

  local total_volumes=$(docker volume ls -q | wc -l)
  local dangling_volumes=$(docker volume ls -f "dangling=true" -q | wc -l)

  msg "Total de volúmenes: ${total_volumes}" "INFO"
  msg "Volúmenes no utilizados: ${dangling_volumes}" "WARNING"
  echo ""

  docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"

  if [[ $dangling_volumes -gt 0 ]]; then
    echo ""
    msg "⚠️  Hay ${dangling_volumes} volúmenes no utilizados que pueden ser eliminados" "WARNING"
    msg "Comando: docker volume prune" "DEBUG"
  fi
}

analyze_networks() {
  print_subheader "🌐 Análisis de Redes Docker (docker network ls -q | wc -l)"

  local total_networks=$(docker network ls -q | wc -l)

  msg "Total de redes: ${total_networks}" "INFO"
  echo ""

  docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}\t{{.ID}}"
}

analyze_build_cache() {
  print_subheader "🔨 Análisis de Caché de Build (docker builder du)"

  docker builder du 2>/dev/null || {
    msg "No se pudo obtener información del build cache" "WARNING"
    msg "Esta funcionalidad requiere Docker BuildKit" "DEBUG"
    return
  }

  echo ""
  msg "💡 Tip: Limpia el build cache con: docker builder prune" "WARNING"
}

get_system_info() {
  print_subheader "💻 Información del Sistema"

  msg "Fecha y hora: ${DATE_HOUR_PE} (Perú)" "INFO"
  msg "Usuario: ${MY_INFO}" "INFO"
  msg "Versión Docker: $(docker --version)" "INFO"

  local docker_root=$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || echo "/var/lib/docker")
  msg "Docker Root Dir: ${docker_root}" "INFO"

  echo ""
  msg "Uso de disco del directorio de Docker:  df -h "${docker_root}"" "INFO"
  df -h "${docker_root}" 2>/dev/null || msg "No se pudo obtener información del disco" "WARNING"
}

generate_recommendations() {
  print_subheader "💡 Recomendaciones de Limpieza"

  msg "Comandos útiles para liberar espacio:" "INFO"
  echo ""
  msg "1. Limpiar todo (imágenes, contenedores, volúmenes, redes no usados):" "SUCCESS"
  msg "   docker system prune -a --volumes" "DEBUG"
  echo ""
  msg "2. Limpiar solo contenedores detenidos:" "SUCCESS"
  msg "   docker container prune" "DEBUG"
  echo ""
  msg "3. Limpiar solo imágenes sin usar:" "SUCCESS"
  msg "   docker image prune -a" "DEBUG"
  echo ""
  msg "4. Limpiar solo volúmenes sin usar:" "SUCCESS"
  msg "   docker volume prune" "DEBUG"
  echo ""
  msg "5. Limpiar build cache:" "SUCCESS"
  msg "   docker builder prune" "DEBUG"
  echo ""
  msg "6. Limpiar logs de contenedores (requiere root):" "SUCCESS"
  msg "   sudo truncate -s 0 /var/lib/docker/containers/*/*-json.log" "DEBUG"
  echo ""
  msg "⚠️  PRECAUCIÓN: Los comandos de limpieza eliminarán datos permanentemente" "WARNING"
  msg "Asegúrate de respaldar lo necesario antes de ejecutarlos" "WARNING"
}

create_summary_report() {
  print_subheader "📋 Resumen Ejecutivo"

  local total_images=$(docker images -q | wc -l)
  local dangling_images=$(docker images -f "dangling=true" -q | wc -l)
  local total_containers=$(docker ps -a -q | wc -l)
  local running_containers=$(docker ps -q | wc -l)
  local stopped_containers=$((total_containers - running_containers))
  local total_volumes=$(docker volume ls -q | wc -l)
  local dangling_volumes=$(docker volume ls -f "dangling=true" -q | wc -l)

  msg "📊 Estado General:" "INFO"
  echo ""
  msg "  Imágenes:      ${total_images} total | ${dangling_images} sin usar" "SUCCESS"
  msg "  Contenedores:  ${running_containers} activos | ${stopped_containers} detenidos | ${total_containers} total" "SUCCESS"
  msg "  Volúmenes:     ${total_volumes} total | ${dangling_volumes} sin usar" "SUCCESS"
  echo ""

  # Calcular espacio recuperable aproximado
  local reclaimable_space=$(docker system df --format "{{.Reclaimable}}" | grep -oP '\d+\.?\d*GB' | head -1 || echo "N/A")

  if [[ "$reclaimable_space" != "N/A" ]]; then
    msg "💾 Espacio recuperable estimado: ${reclaimable_space}" "WARNING"
  fi

  # Alertas
  if [[ $dangling_images -gt 0 ]] || [[ $dangling_volumes -gt 0 ]] || [[ $stopped_containers -gt 0 ]]; then
    echo ""
    msg "⚠️  ALERTAS:" "WARNING"
    [[ $dangling_images -gt 0 ]] && msg "  • ${dangling_images} imágenes huérfanas detectadas" "WARNING"
    [[ $dangling_volumes -gt 0 ]] && msg "  • ${dangling_volumes} volúmenes sin usar detectados" "WARNING"
    [[ $stopped_containers -gt 0 ]] && msg "  • ${stopped_containers} contenedores detenidos detectados" "WARNING"
  else
    echo ""
    msg "✅ Sistema Docker limpio - No hay recursos sin usar" "SUCCESS"
  fi
}

# =============================================================================
# 🚀 SECTION: Main Execution
# =============================================================================

main() {
  my_banner
  print_header "🐋 ANÁLISIS COMPLETO DE RECURSOS DOCKER"

  msg "Iniciando análisis de Docker..." "INFO"
  msg "Sistema: ${MY_INFO}" "DEBUG"
  msg "Fecha: ${DATE_HOUR_PE}" "DEBUG"

  # Verificar Docker
  check_docker

  # Información del sistema
  get_system_info

  # Análisis de recursos
  analyze_system_df
  analyze_containers_stats
  analyze_images
  analyze_volumes
  analyze_networks
  analyze_build_cache
  analyze_container_logs

  # Resumen y recomendaciones
  create_summary_report
  generate_recommendations

  # Footer
  echo ""
  print_header "✅ ANÁLISIS COMPLETADO"
  msg "Reporte generado: ${DATE_HOUR_PE}" "SUCCESS"
  msg "Para más información: docker system df -v" "DEBUG"
  echo ""
}

# Ejecutar script
main "$@"