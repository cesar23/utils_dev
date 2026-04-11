#!/bin/bash

################################################################################
# Script Avanzado de Conversión y Compresión de Videos
#
# Versión: 3.0
# Autor: César Auris
# Website: www.solucionessystem.com
# Fecha: Abril 2026
#
# Descripción:
#   Script profesional para convertir y comprimir videos (MKV, AVI, MOV, etc.)
#   optimizado para subir a Facebook y otras redes sociales.
#   Menú interactivo completo con selección de carpetas, formatos y calidad.
#
# Características:
#   - Conversión MKV → MP4/MOV (compatible con Facebook)
#   - Menú interactivo para carpeta origen, salida, formato y calidad
#   - Perfiles preconfigurados para Facebook, YouTube, WhatsApp, general
#   - Historial persistente (evita reprocesar archivos ya convertidos)
#   - Validación de tamaño y reducción
#   - Estadísticas detalladas de ahorro de espacio
#   - Soporte de múltiples extensiones de entrada
#   - Búsqueda recursiva en subcarpetas
#   - Logs detallados de todas las operaciones
#   - Procesamiento por lotes (batch) configurable
#
# Uso:
#   ./comprimir_y_util_videos.sh [OPCIONES] [DIRECTORIO]
#   ./comprimir_y_util_videos.sh --help
################################################################################

################################################################################
# CONFIGURACIÓN DE COLORES
################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

################################################################################
# CONFIGURACIÓN GENERAL
################################################################################

DIRECTORIO_ORIGEN=""
DIRECTORIO_SALIDA=""
ARCHIVO_HISTORIAL=".historial_conversion_videos.txt"
ARCHIVO_LOG="conversion_videos.log"
ARCHIVO_CONFIG="$HOME/.config/video_converter.conf"

################################################################################
# PARÁMETROS DE COMPRESIÓN (valores por defecto)
################################################################################

CRF=20
PRESET="medium"
CODEC_VIDEO="libx264"
CODEC_AUDIO="aac"
BITRATE_AUDIO="192k"
FORMATO_SALIDA="mp4"
RESOLUCION=""            # vacío = mantener original, "1920:1080" = forzar 1080p
TAMANIO_MINIMO=10        # MB mínimos para procesar
REDUCCION_MINIMA=0       # 0 = sin mínimo
ACCION_SI_MAS_GRANDE="copy"
BORRAR_ORIGINALES=false
CREAR_BACKUP=false
SOBRESCRIBIR_ORIGINAL=false
BATCH_SIZE=0
SKIP_MENU=false
MODO_INTERACTIVO=false

# Extensiones de entrada soportadas
EXTENSIONES_ENTRADA="mkv MKV mp4 MP4 avi AVI mov MOV wmv WMV flv FLV webm WEBM m4v M4V ts TS"

################################################################################
# PERFILES PRECONFIGURADOS
################################################################################

# Aplica el perfil seleccionado
aplicar_perfil() {
    local perfil="$1"
    case "$perfil" in
        facebook)
            CODEC_VIDEO="libx264"
            CODEC_AUDIO="aac"
            BITRATE_AUDIO="192k"
            FORMATO_SALIDA="mp4"
            CRF=20
            PRESET="medium"
            RESOLUCION="1920:1080"
            echo -e "  ${GREEN}✓ Perfil Facebook aplicado${NC} ${CYAN}(H.264/AAC/1080p, CRF 20)${NC}"
            ;;
        facebook_ligero)
            CODEC_VIDEO="libx264"
            CODEC_AUDIO="aac"
            BITRATE_AUDIO="128k"
            FORMATO_SALIDA="mp4"
            CRF=24
            PRESET="fast"
            RESOLUCION="1280:720"
            echo -e "  ${GREEN}✓ Perfil Facebook Ligero aplicado${NC} ${CYAN}(H.264/AAC/720p, CRF 24)${NC}"
            ;;
        youtube)
            CODEC_VIDEO="libx264"
            CODEC_AUDIO="aac"
            BITRATE_AUDIO="256k"
            FORMATO_SALIDA="mp4"
            CRF=18
            PRESET="slow"
            RESOLUCION="1920:1080"
            echo -e "  ${GREEN}✓ Perfil YouTube aplicado${NC} ${CYAN}(H.264/AAC/1080p, CRF 18)${NC}"
            ;;
        whatsapp)
            CODEC_VIDEO="libx264"
            CODEC_AUDIO="aac"
            BITRATE_AUDIO="128k"
            FORMATO_SALIDA="mp4"
            CRF=28
            PRESET="fast"
            RESOLUCION="1280:720"
            echo -e "  ${GREEN}✓ Perfil WhatsApp aplicado${NC} ${CYAN}(H.264/AAC/720p, CRF 28)${NC}"
            ;;
        general)
            CODEC_VIDEO="libx264"
            CODEC_AUDIO="aac"
            BITRATE_AUDIO="192k"
            FORMATO_SALIDA="mp4"
            CRF=23
            PRESET="medium"
            RESOLUCION=""
            echo -e "  ${GREEN}✓ Perfil General aplicado${NC} ${CYAN}(H.264/AAC/original, CRF 23)${NC}"
            ;;
        solo_convertir)
            CODEC_VIDEO="copy"
            CODEC_AUDIO="copy"
            FORMATO_SALIDA="mp4"
            CRF=23
            PRESET="medium"
            RESOLUCION=""
            echo -e "  ${GREEN}✓ Perfil Conversión rápida aplicado${NC} ${CYAN}(copia streams, sin recodificar)${NC}"
            ;;
    esac
}

################################################################################
# FUNCIONES AUXILIARES
################################################################################

log_mensaje() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ARCHIVO_LOG"
}

guardar_configuracion() {
    mkdir -p "$(dirname "$ARCHIVO_CONFIG")"
    cat > "$ARCHIVO_CONFIG" << EOF
# Configuración del Convertidor de Videos - generado automáticamente
DIRECTORIO_ORIGEN_DEFAULT=$DIRECTORIO_ORIGEN
DIRECTORIO_SALIDA_DEFAULT=$DIRECTORIO_SALIDA
CRF=$CRF
PRESET=$PRESET
FORMATO_SALIDA=$FORMATO_SALIDA
BITRATE_AUDIO=$BITRATE_AUDIO
RESOLUCION=$RESOLUCION
TAMANIO_MINIMO=$TAMANIO_MINIMO
BATCH_SIZE=$BATCH_SIZE
CREAR_BACKUP=$CREAR_BACKUP
EOF
    echo -e "  ${GREEN}✓ Configuración guardada en: $ARCHIVO_CONFIG${NC}"
}

cargar_configuracion() {
    if [ -f "$ARCHIVO_CONFIG" ]; then
        source "$ARCHIVO_CONFIG"
    fi
}

obtener_tamanio_mb() {
    local bytes
    bytes=$(stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null)
    echo $(( bytes / 1024 / 1024 ))
}

formatear_tamanio() {
    local mb=$1
    if [ "$mb" -ge 1024 ]; then
        awk "BEGIN {printf \"%.2fGB\", $mb/1024}"
    else
        echo "${mb}MB"
    fi
}

obtener_checksum() {
    md5sum "$1" 2>/dev/null | awk '{print $1}'
}

esta_en_historial() {
    [ -f "$ARCHIVO_HISTORIAL" ] && grep -q "|$(realpath "$1")|" "$ARCHIVO_HISTORIAL" 2>/dev/null
}

agregar_a_historial() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')|$(realpath "$1")|$2|$3|$4|${5:-0}" >> "$ARCHIVO_HISTORIAL"
}

verificar_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${RED}✗ Error: FFmpeg no está instalado${NC}"
        echo -e "  Instala con: ${CYAN}sudo apt install ffmpeg -y${NC}"
        exit 1
    fi
}

run_cmd() {
  echo -e "  ${BGray}›${Color_Off} ${BYellow}$*${Color_Off}"
  "$@"
}



# ==============================================================================
# 📝 Función: handle_error
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Captura cualquier error no manejado y muestra información detallada
#
# 🔧 Parámetros:
#   $1 - Código de salida del comando que falló
#   $2 - Número de línea donde ocurrió el error
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

  # Información adicional si está disponible
  if [[ -n "${DIR_TO_COMPRESS:-}" ]]; then
    msg "Directorio a comprimir: ${DIR_TO_COMPRESS}" "ERROR"
  fi
  if [[ -n "${FILE_PATH_COMPRESS:-}" ]]; then
    msg "Archivo de salida: ${FILE_PATH_COMPRESS}" "ERROR"
  fi

  msg "=================================================" "ERROR"

  # Limpiar archivo parcial si existe
  if [[ -n "${FILE_PATH_COMPRESS:-}" ]] && [[ -f "${FILE_PATH_COMPRESS}" ]]; then
    msg "Limpiando archivo parcial: ${FILE_PATH_COMPRESS}" "WARNING"
    rm -f "${FILE_PATH_COMPRESS}" 2>/dev/null || true
  fi

  exit "${exit_code}"
}

# ==============================================================================
# 📝 Función: cleanup_on_exit
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Limpia archivos temporales al salir del script
# ==============================================================================
cleanup_on_exit() {
  local exit_code=$?

  # Limpiar archivos temporales si existen
  if [[ -n "${TEMP_FILE_OK:-}" ]] && [[ -f "${TEMP_FILE_OK}" ]]; then
    rm -f "${TEMP_FILE_OK}" 2>/dev/null || true
  fi

  if [[ -n "${TEMP_FILE_ERR:-}" ]] && [[ -f "${TEMP_FILE_ERR}" ]]; then
    rm -f "${TEMP_FILE_ERR}" 2>/dev/null || true
  fi

  # Si hay un archivo parcial y el script falló, limpiarlo
  if [[ $exit_code -ne 0 ]] && [[ -n "${FILE_PATH_COMPRESS:-}" ]] && [[ -f "${FILE_PATH_COMPRESS}" ]]; then
    msg "Limpiando archivo parcial debido a error: ${FILE_PATH_COMPRESS}" "WARNING"
    rm -f "${FILE_PATH_COMPRESS}" 2>/dev/null || true
  fi
}

# Configurar traps para manejo de errores
# Captura cualquier error no manejado y lo procesa
trap 'handle_error $? $LINENO' ERR

# Capturar EXIT para limpiar archivos temporales
trap 'cleanup_on_exit' EXIT


contar_videos_dir() {
    local dir="$1"
    local total=0
    local total_mb=0
    local patron=""
    for ext in $EXTENSIONES_ENTRADA; do
        patron="$patron -o -iname *.${ext}"
    done
    patron="${patron# -o }"
    while IFS= read -r -d '' archivo; do
        local tam
        tam=$(obtener_tamanio_mb "$archivo")
        if [ "$tam" -ge "$TAMANIO_MINIMO" ]; then
            total=$((total + 1))
            total_mb=$((total_mb + tam))
        fi
    done < <(eval "find \"$dir\" -type f \( $patron \) -not -path \"*/comprimidos_videos/*\" -not -path \"*/videos_convertidos/*\" -print0" 2>/dev/null)
    echo "$total|$total_mb"
}

################################################################################
# SELECCIÓN INTERACTIVA DE DIRECTORIOS
################################################################################

seleccionar_directorio_origen() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}PASO 1/2 — CARPETA DE VIDEOS ORIGEN${NC}                            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Mostrar carpeta guardada si existe
    if [ -n "$DIRECTORIO_ORIGEN_DEFAULT" ] && [ -d "$DIRECTORIO_ORIGEN_DEFAULT" ]; then
        echo -e "${YELLOW}📁 Última carpeta usada:${NC}"
        echo -e "   ${CYAN}$DIRECTORIO_ORIGEN_DEFAULT${NC}"
        local info_videos
        info_videos=$(contar_videos_dir "$DIRECTORIO_ORIGEN_DEFAULT")
        local num_v
        num_v=$(echo "$info_videos" | cut -d'|' -f1)
        local tam_v
        tam_v=$(echo "$info_videos" | cut -d'|' -f2)
        echo -e "   ${GREEN}$num_v video(s)${NC} — Tamaño total: ${GREEN}$(formatear_tamanio "$tam_v")${NC}"
        echo ""
        echo -e "  ${GREEN}[1]${NC} Usar esta carpeta"
        echo -e "  ${BLUE}[2]${NC} Ingresar otra carpeta"
        echo -e "  ${RED}[0]${NC} Volver al menú principal"
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -n -e "${YELLOW}Selecciona [1]: ${NC}"
        read -r opcion_origen
        opcion_origen=${opcion_origen:-1}

        case $opcion_origen in
            1)
                DIRECTORIO_ORIGEN="$DIRECTORIO_ORIGEN_DEFAULT"
                echo -e "${GREEN}✓ Usando: $DIRECTORIO_ORIGEN${NC}"
                sleep 1
                return 0
                ;;
            0)
                return 1
                ;;
        esac
    fi

    # Ingresar ruta manualmente
    echo -e "${YELLOW}📂 Directorios disponibles en la ubicación actual ($(pwd)):${NC}"
    echo ""
    local i=1
    local dirs=()
    while IFS= read -r -d '' d; do
        dirs+=("$d")
        local info
        info=$(contar_videos_dir "$d")
        local nv
        nv=$(echo "$info" | cut -d'|' -f1)
        echo -e "  ${GREEN}[$i]${NC} $(basename "$d")/ ${CYAN}($nv video(s))${NC}"
        i=$((i + 1))
    done < <(find "$(pwd)" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)

    echo ""
    echo -e "  ${MAGENTA}[m]${NC} Ingresar ruta manualmente"
    echo -e "  ${RED}[0]${NC} Volver"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -n -e "${YELLOW}Selecciona opción: ${NC}"
    read -r opcion_dir

    if [[ "$opcion_dir" =~ ^[0-9]+$ ]] && [ "$opcion_dir" -ge 1 ] && [ "$opcion_dir" -le "${#dirs[@]}" ]; then
        DIRECTORIO_ORIGEN="${dirs[$((opcion_dir - 1))]}"
    elif [[ "$opcion_dir" == "m" || "$opcion_dir" == "M" ]]; then
        echo ""
        echo -n -e "${YELLOW}Ingresa la ruta completa de la carpeta origen: ${NC}"
        read -r ruta_manual
        ruta_manual="${ruta_manual%/}"
        if [ -d "$ruta_manual" ]; then
            DIRECTORIO_ORIGEN="$ruta_manual"
        else
            echo -e "${RED}✗ La carpeta no existe: $ruta_manual${NC}"
            sleep 2
            return 1
        fi
    elif [[ "$opcion_dir" == "0" ]]; then
        return 1
    else
        echo -e "${RED}✗ Opción inválida${NC}"
        sleep 2
        return 1
    fi

    if [ -z "$DIRECTORIO_ORIGEN" ]; then
        echo -e "${RED}✗ No se seleccionó ninguna carpeta${NC}"
        sleep 2
        return 1
    fi

    local info_final
    info_final=$(contar_videos_dir "$DIRECTORIO_ORIGEN")
    local nf
    nf=$(echo "$info_final" | cut -d'|' -f1)
    local tf
    tf=$(echo "$info_final" | cut -d'|' -f2)
    echo ""
    echo -e "${GREEN}✓ Carpeta seleccionada: $DIRECTORIO_ORIGEN${NC}"
    echo -e "  ${CYAN}$nf video(s) encontrados — $(formatear_tamanio "$tf") total${NC}"
    sleep 2
    return 0
}

seleccionar_directorio_salida() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}PASO 2/2 — CARPETA DE SALIDA${NC}                                   ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Carpeta origen: ${CYAN}$DIRECTORIO_ORIGEN${NC}"
    echo ""

    local SALIDA_AUTO="${DIRECTORIO_ORIGEN}/videos_convertidos"

    echo -e "  ${GREEN}[1]${NC} Carpeta automática (recomendado)"
    echo -e "      ${CYAN}→ $SALIDA_AUTO${NC}"
    echo ""

    if [ -n "$DIRECTORIO_SALIDA_DEFAULT" ] && [ "$DIRECTORIO_SALIDA_DEFAULT" != "$SALIDA_AUTO" ]; then
        echo -e "  ${BLUE}[2]${NC} Última carpeta usada"
        echo -e "      ${CYAN}→ $DIRECTORIO_SALIDA_DEFAULT${NC}"
        echo ""
        echo -e "  ${MAGENTA}[3]${NC} Ingresar ruta personalizada"
        echo ""
    else
        echo -e "  ${MAGENTA}[2]${NC} Ingresar ruta personalizada"
        echo ""
    fi

    echo -e "  ${YELLOW}[s]${NC} Sobrescribir originales"
    echo -e "      ${RED}⚠ Los archivos MKV serán reemplazados por MP4${NC}"
    echo ""
    echo -e "  ${RED}[0]${NC} Volver"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -n -e "${YELLOW}Selecciona [1]: ${NC}"
    read -r opcion_salida
    opcion_salida=${opcion_salida:-1}

    case $opcion_salida in
        1)
            DIRECTORIO_SALIDA="$SALIDA_AUTO"
            SOBRESCRIBIR_ORIGINAL=false
            ;;
        2)
            if [ -n "$DIRECTORIO_SALIDA_DEFAULT" ] && [ "$DIRECTORIO_SALIDA_DEFAULT" != "$SALIDA_AUTO" ]; then
                DIRECTORIO_SALIDA="$DIRECTORIO_SALIDA_DEFAULT"
                SOBRESCRIBIR_ORIGINAL=false
            else
                echo ""
                echo -n -e "${YELLOW}Ingresa la ruta de salida: ${NC}"
                read -r ruta_salida
                DIRECTORIO_SALIDA="${ruta_salida%/}"
                SOBRESCRIBIR_ORIGINAL=false
            fi
            ;;
        3)
            echo ""
            echo -n -e "${YELLOW}Ingresa la ruta de salida: ${NC}"
            read -r ruta_salida
            DIRECTORIO_SALIDA="${ruta_salida%/}"
            SOBRESCRIBIR_ORIGINAL=false
            ;;
        s|S)
            SOBRESCRIBIR_ORIGINAL=true
            DIRECTORIO_SALIDA="$DIRECTORIO_ORIGEN"
            echo -e "\n${YELLOW}Modo sobrescribir activado.${NC}"
            echo -n -e "${YELLOW}¿Crear backup antes de sobrescribir? (s/N): ${NC}"
            read -r resp_backup
            [[ "$resp_backup" =~ ^[Ss]$ ]] && CREAR_BACKUP=true || CREAR_BACKUP=false
            ;;
        0)
            return 1
            ;;
        *)
            echo -e "${RED}✗ Opción inválida${NC}"
            sleep 2
            return 1
            ;;
    esac

    echo -e "${GREEN}✓ Carpeta de salida: $DIRECTORIO_SALIDA${NC}"
    sleep 1
    return 0
}

################################################################################
# MENÚ DE PERFILES
################################################################################

seleccionar_perfil() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}PERFILES DE CONVERSIÓN${NC}                                         ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} 📘 ${WHITE}Facebook (Recomendado para ti)${NC}"
    echo -e "      ${CYAN}→ H.264 + AAC | 1080p | CRF 20 | MP4${NC}"
    echo -e "      ${CYAN}→ Ideal para videos de 45 min — balance calidad/peso óptimo${NC}"
    echo ""
    echo -e "  ${GREEN}[2]${NC} 📘 Facebook Ligero"
    echo -e "      ${CYAN}→ H.264 + AAC | 720p | CRF 24 | MP4${NC}"
    echo -e "      ${CYAN}→ Si tu internet es lento — archivos más pequeños${NC}"
    echo ""
    echo -e "  ${GREEN}[3]${NC} 📺 YouTube (Alta calidad)"
    echo -e "      ${CYAN}→ H.264 + AAC | 1080p | CRF 18 | MP4${NC}"
    echo -e "      ${CYAN}→ Máxima calidad — archivos grandes${NC}"
    echo ""
    echo -e "  ${GREEN}[4]${NC} 📱 WhatsApp"
    echo -e "      ${CYAN}→ H.264 + AAC | 720p | CRF 28 | MP4${NC}"
    echo -e "      ${CYAN}→ Tamaño reducido — compatible con móviles${NC}"
    echo ""
    echo -e "  ${GREEN}[5]${NC} 🎬 General (Conversión estándar)"
    echo -e "      ${CYAN}→ H.264 + AAC | resolución original | CRF 23 | MP4${NC}"
    echo ""
    echo -e "  ${GREEN}[6]${NC} ⚡ Solo convertir contenedor (sin recodificar)"
    echo -e "      ${CYAN}→ Copia streams sin cambios — MKV → MP4 muy rápido${NC}"
    echo -e "      ${CYAN}→ Útil cuando el video ya está en H.264 dentro del MKV${NC}"
    echo ""
    echo -e "  ${MAGENTA}[7]${NC} 🔧 Configuración personalizada"
    echo -e "      ${CYAN}→ Define manualmente CRF, preset, resolución, bitrate${NC}"
    echo ""
    echo -e "  ${RED}[0]${NC} Volver"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -n -e "${YELLOW}Selecciona perfil [1]: ${NC}"
    read -r opcion_perfil
    opcion_perfil=${opcion_perfil:-1}

    case $opcion_perfil in
        1) aplicar_perfil "facebook" ;;
        2) aplicar_perfil "facebook_ligero" ;;
        3) aplicar_perfil "youtube" ;;
        4) aplicar_perfil "whatsapp" ;;
        5) aplicar_perfil "general" ;;
        6) aplicar_perfil "solo_convertir" ;;
        7) configurar_personalizado ;;
        0) return 1 ;;
        *)
            echo -e "${RED}✗ Opción inválida. Usando Facebook por defecto.${NC}"
            aplicar_perfil "facebook"
            ;;
    esac
    sleep 1
    return 0
}

################################################################################
# CONFIGURACIÓN PERSONALIZADA
################################################################################

configurar_personalizado() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}CONFIGURACIÓN PERSONALIZADA${NC}                                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # CRF
    echo -e "${YELLOW}Calidad de video (CRF):${NC}"
    echo -e "  ${CYAN}18${NC} = Excelente (archivos grandes) | ${CYAN}20${NC} = Muy buena | ${CYAN}23${NC} = Buena (balance) | ${CYAN}28${NC} = Máximo ahorro"
    echo -n -e "${YELLOW}CRF [$CRF]: ${NC}"
    read -r nuevo_crf
    if [[ "$nuevo_crf" =~ ^[0-9]+$ ]] && [ "$nuevo_crf" -ge 0 ] && [ "$nuevo_crf" -le 51 ]; then
        CRF=$nuevo_crf
    fi

    # Preset
    echo ""
    echo -e "${YELLOW}Velocidad de codificación (Preset):${NC}"
    echo -e "  ${CYAN}ultrafast${NC} | ${CYAN}fast${NC} | ${CYAN}medium${NC} | ${CYAN}slow${NC} | ${CYAN}veryslow${NC}"
    echo -n -e "${YELLOW}Preset [$PRESET]: ${NC}"
    read -r nuevo_preset
    if [[ "$nuevo_preset" =~ ^(ultrafast|superfast|veryfast|faster|fast|medium|slow|slower|veryslow)$ ]]; then
        PRESET=$nuevo_preset
    fi

    # Formato de salida
    echo ""
    echo -e "${YELLOW}Formato de salida:${NC}"
    echo -e "  ${CYAN}[1]${NC} MP4 (recomendado — compatible con Facebook)"
    echo -e "  ${CYAN}[2]${NC} MKV"
    echo -e "  ${CYAN}[3]${NC} MOV"
    echo -n -e "${YELLOW}Formato [1]: ${NC}"
    read -r opc_fmt
    case ${opc_fmt:-1} in
        1) FORMATO_SALIDA="mp4" ;;
        2) FORMATO_SALIDA="mkv" ;;
        3) FORMATO_SALIDA="mov" ;;
    esac

    # Resolución
    echo ""
    echo -e "${YELLOW}Resolución de salida:${NC}"
    echo -e "  ${CYAN}[1]${NC} Mantener original"
    echo -e "  ${CYAN}[2]${NC} 1080p (1920x1080)"
    echo -e "  ${CYAN}[3]${NC} 720p (1280x720)"
    echo -e "  ${CYAN}[4]${NC} 480p (854x480)"
    echo -n -e "${YELLOW}Resolución [1]: ${NC}"
    read -r opc_res
    case ${opc_res:-1} in
        1) RESOLUCION="" ;;
        2) RESOLUCION="1920:1080" ;;
        3) RESOLUCION="1280:720" ;;
        4) RESOLUCION="854:480" ;;
    esac

    # Bitrate de audio
    echo ""
    echo -e "${YELLOW}Bitrate de audio:${NC}"
    echo -e "  ${CYAN}[1]${NC} 128k (estándar) | ${CYAN}[2]${NC} 192k (buena) | ${CYAN}[3]${NC} 256k (alta)"
    echo -n -e "${YELLOW}Audio [$BITRATE_AUDIO]: ${NC}"
    read -r opc_audio
    case ${opc_audio:-2} in
        1) BITRATE_AUDIO="128k" ;;
        2) BITRATE_AUDIO="192k" ;;
        3) BITRATE_AUDIO="256k" ;;
    esac

    echo ""
    echo -e "${GREEN}✓ Configuración personalizada aplicada${NC}"
    echo -e "  CRF: $CRF | Preset: $PRESET | Formato: $FORMATO_SALIDA | Audio: $BITRATE_AUDIO"
}

################################################################################
# OPCIONES AVANZADAS
################################################################################

menu_opciones_avanzadas() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}OPCIONES AVANZADAS${NC}                                              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Configuración actual:${NC}"
    echo -e "  • Tamaño mínimo a procesar: ${GREEN}${TAMANIO_MINIMO}MB${NC}"
    echo -e "  • Reducción mínima requerida: ${GREEN}${REDUCCION_MINIMA}%${NC}"
    echo -e "  • Procesamiento por lotes: ${GREEN}$([ $BATCH_SIZE -eq 0 ] && echo 'Desactivado' || echo "${BATCH_SIZE} videos")${NC}"
    echo -e "  • Modo interactivo: ${GREEN}$([ "$MODO_INTERACTIVO" = true ] && echo 'Activado' || echo 'Desactivado')${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} Cambiar tamaño mínimo (actual: ${TAMANIO_MINIMO}MB)"
    echo -e "  ${GREEN}[2]${NC} Cambiar reducción mínima (actual: ${REDUCCION_MINIMA}%)"
    echo -e "  ${GREEN}[3]${NC} Configurar lotes (Batch)"
    echo -e "  ${GREEN}[4]${NC} Activar/desactivar modo interactivo"
    echo -e "  ${GREEN}[5]${NC} Guardar configuración actual como predeterminada"
    echo -e "  ${GREEN}[6]${NC} Volver"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -n -e "${YELLOW}Selecciona: ${NC}"
    read -r opc_adv

    case $opc_adv in
        1)
            echo -n -e "${YELLOW}Tamaño mínimo en MB [1-500]: ${NC}"
            read -r nuevo_min
            [[ "$nuevo_min" =~ ^[0-9]+$ ]] && [ "$nuevo_min" -ge 1 ] && TAMANIO_MINIMO=$nuevo_min
            echo -e "${GREEN}✓ Tamaño mínimo: ${TAMANIO_MINIMO}MB${NC}"
            sleep 1
            ;;
        2)
            echo -n -e "${YELLOW}Reducción mínima en % [0-50]: ${NC}"
            read -r nuevo_red
            [[ "$nuevo_red" =~ ^[0-9]+$ ]] && [ "$nuevo_red" -ge 0 ] && [ "$nuevo_red" -le 50 ] && REDUCCION_MINIMA=$nuevo_red
            echo -e "${GREEN}✓ Reducción mínima: ${REDUCCION_MINIMA}%${NC}"
            sleep 1
            ;;
        3)
            echo -e "  ${CYAN}0${NC} = Sin pausas | ${CYAN}10${NC} = Pausar c/10 videos | ${CYAN}15${NC} = c/15"
            echo -n -e "${YELLOW}Tamaño de lote [0-100]: ${NC}"
            read -r nuevo_batch
            [[ "$nuevo_batch" =~ ^[0-9]+$ ]] && BATCH_SIZE=$nuevo_batch
            echo -e "${GREEN}✓ Batch: $([ $BATCH_SIZE -eq 0 ] && echo 'Desactivado' || echo "$BATCH_SIZE videos")${NC}"
            sleep 1
            ;;
        4)
            [ "$MODO_INTERACTIVO" = true ] && MODO_INTERACTIVO=false || MODO_INTERACTIVO=true
            echo -e "${GREEN}✓ Modo interactivo: $([ "$MODO_INTERACTIVO" = true ] && echo 'Activado' || echo 'Desactivado')${NC}"
            sleep 1
            ;;
        5)
            guardar_configuracion
            sleep 2
            ;;
    esac
}

################################################################################
# MENÚ DE UTILIDADES
################################################################################

menu_utilidades() {
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}  ${CYAN}UTILIDADES${NC}                                                      ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${GREEN}[1]${NC} Eliminar duplicados (por MD5)"
        echo -e "  ${GREEN}[2]${NC} Eliminar archivos por extensión"
        echo -e "  ${GREEN}[3]${NC} Ver estadísticas del historial"
        echo -e "  ${GREEN}[4]${NC} Ver lista de videos procesados"
        echo -e "  ${GREEN}[5]${NC} Resetear historial"
        echo -e "  ${RED}[0]${NC} Volver"
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -n -e "${YELLOW}Selecciona: ${NC}"
        read -r opc_util

        case $opc_util in
            1) eliminar_duplicados ;;
            2) eliminar_por_extension ;;
            3) mostrar_estadisticas_historial ;;
            4) listar_procesados ;;
            5) resetear_historial ;;
            0) return ;;
            *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
        esac
    done
}

################################################################################
# FUNCIÓN PRINCIPAL DE CONVERSIÓN
################################################################################

convertir_video() {
    local archivo_entrada="$1"
    local nombre_base
    nombre_base=$(basename "$archivo_entrada")
    local nombre_sin_ext="${nombre_base%.*}"

    local directorio_relativo
    directorio_relativo=$(dirname "$(realpath "$archivo_entrada")" | sed "s|^$(realpath "$DIRECTORIO_ORIGEN")||" | sed 's|^/||')
    local directorio_destino
    if [ -n "$directorio_relativo" ]; then
        directorio_destino="${DIRECTORIO_SALIDA}/${directorio_relativo}"
    else
        directorio_destino="$DIRECTORIO_SALIDA"
    fi

    local archivo_salida="${directorio_destino}/${nombre_sin_ext}.${FORMATO_SALIDA}"

    if [ "$SOBRESCRIBIR_ORIGINAL" = true ]; then
        archivo_salida="${archivo_entrada%.*}.${FORMATO_SALIDA}.tmp"
    fi

    mkdir -p "$directorio_destino"

    local tam_original
    tam_original=$(obtener_tamanio_mb "$archivo_entrada")

    # Verificar si ya fue procesado
    if esta_en_historial "$archivo_entrada"; then
        echo -e "${YELLOW}⊘ Ya procesado:${NC} $nombre_base"
        return 2
    fi

    # Verificar tamaño mínimo
    if [ "$tam_original" -lt "$TAMANIO_MINIMO" ]; then
        echo -e "${CYAN}→ Omitido (${tam_original}MB < ${TAMANIO_MINIMO}MB):${NC} $nombre_base"
        log_mensaje "OMITIDO (tamaño): $archivo_entrada"
        return 2
    fi

    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}$(echo "$nombre_base" | cut -c1-55)${NC}"
    echo -e "${BLUE}║${NC} Tamaño: $(formatear_tamanio "$tam_original") | CRF: $CRF | Preset: $PRESET | → .${FORMATO_SALIDA}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

    if [ "$MODO_INTERACTIVO" = true ]; then
        echo -n -e "${YELLOW}¿Convertir este video? (S/n): ${NC}"
        read -r resp_interactivo
        if [[ "$resp_interactivo" =~ ^[Nn]$ ]]; then
            echo -e "${YELLOW}⊘ Omitido por el usuario${NC}"
            return 2
        fi
    fi

    echo -e "${CYAN}⟳ Convirtiendo...${NC}"

    # Construir el comando FFmpeg como array (evita problemas con eval y caracteres especiales)
    local ffmpeg_cmd=()
    if [ "$CODEC_VIDEO" = "copy" ]; then
        ffmpeg_cmd=(
            ffmpeg -i "$archivo_entrada"
            -c:v copy -c:a copy
            -movflags +faststart
            "$archivo_salida"
            -y -hide_banner -loglevel error -stats
        )
    else
        if [ -n "$RESOLUCION" ]; then
            ffmpeg_cmd=(
                ffmpeg -i "$archivo_entrada"
                -c:v "$CODEC_VIDEO" -crf "$CRF" -preset "$PRESET"
                -vf "scale=${RESOLUCION}:force_original_aspect_ratio=decrease,pad=${RESOLUCION}:(ow-iw)/2:(oh-ih)/2"
                -c:a "$CODEC_AUDIO" -b:a "$BITRATE_AUDIO"
                -movflags +faststart
                "$archivo_salida"
                -y -hide_banner -loglevel error -stats
            )
        else
            ffmpeg_cmd=(
                ffmpeg -i "$archivo_entrada"
                -c:v "$CODEC_VIDEO" -crf "$CRF" -preset "$PRESET"
                -c:a "$CODEC_AUDIO" -b:a "$BITRATE_AUDIO"
                -movflags +faststart
                "$archivo_salida"
                -y -hide_banner -loglevel error -stats
            )
        fi
    fi

    if "${ffmpeg_cmd[@]}" < /dev/null 2>&1; then

        local tam_resultado
        tam_resultado=$(obtener_tamanio_mb "$archivo_salida")
        local reduccion
        reduccion=$(awk "BEGIN {printf \"%.1f\", (1 - $tam_resultado/$tam_original) * 100}")

        if [ "$tam_resultado" -ge "$tam_original" ] && [ "$CODEC_VIDEO" != "copy" ]; then
            echo -e "  ${YELLOW}⚠ Resultado es más grande ($(formatear_tamanio "$tam_resultado") vs $(formatear_tamanio "$tam_original"))${NC}"
            rm -f "$archivo_salida"
            if [ "$ACCION_SI_MAS_GRANDE" = "copy" ]; then
                cp "$archivo_entrada" "${directorio_destino}/${nombre_sin_ext}.${FORMATO_SALIDA}"
                echo -e "  ${CYAN}→ Copiado el original sin recodificar${NC}"
            else
                echo -e "  ${CYAN}→ Archivo omitido (sin cambios)${NC}"
            fi
            log_mensaje "MÁS GRANDE: $archivo_entrada"
        else
            echo -e "  ${GREEN}✓ Convertido exitosamente${NC}"
            echo -e "  Tamaño final: ${GREEN}$(formatear_tamanio "$tam_resultado")${NC}"
            if [ "$CODEC_VIDEO" != "copy" ]; then
                echo -e "  Ahorro: ${GREEN}${reduccion}%${NC} ($(formatear_tamanio $((tam_original - tam_resultado))))"
            fi

            if [ "$SOBRESCRIBIR_ORIGINAL" = true ]; then
                [ "$CREAR_BACKUP" = true ] && cp "$archivo_entrada" "${archivo_entrada}.backup" && echo -e "  ${CYAN}↻ Backup creado${NC}"
                local dest_final="${archivo_entrada%.*}.${FORMATO_SALIDA}"
                mv "$archivo_salida" "$dest_final"
                # Eliminar el original MKV si la extensión cambió
                if [ "$dest_final" != "$archivo_entrada" ]; then
                    rm -f "$archivo_entrada"
                fi
                echo -e "  ${GREEN}✓ Original reemplazado${NC}"
                archivo_salida="$dest_final"
            fi

            log_mensaje "CONVERTIDO: $archivo_entrada → $archivo_salida (${reduccion}%)"
        fi

        agregar_a_historial "$archivo_entrada" "$archivo_salida" "$tam_original" "$tam_resultado" "$reduccion"
        echo ""
        return 0
    else
        echo -e "  ${RED}✗ Error al convertir: $archivo_entrada${NC}\n"
        log_mensaje "ERROR: $archivo_entrada"
        rm -f "$archivo_salida"
        return 1
    fi
}

################################################################################
# ESTADÍSTICAS E HISTORIAL
################################################################################

mostrar_estadisticas_historial() {
    if [ ! -f "$ARCHIVO_HISTORIAL" ]; then
        echo -e "${RED}No hay historial disponible${NC}"
        echo -n -e "${YELLOW}Presiona Enter...${NC}"; read -r
        return
    fi

    local total_procesados
    total_procesados=$(wc -l < "$ARCHIVO_HISTORIAL")
    local tam_orig_total=0
    local tam_comp_total=0

    while IFS='|' read -r fecha orig comp tam_orig tam_comp reduccion; do
        tam_orig_total=$((tam_orig_total + tam_orig))
        tam_comp_total=$((tam_comp_total + tam_comp))
    done < "$ARCHIVO_HISTORIAL"

    local ahorro=$((tam_orig_total - tam_comp_total))
    local pct=0
    [ "$tam_orig_total" -gt 0 ] && pct=$(awk "BEGIN {printf \"%.1f\", (1 - $tam_comp_total/$tam_orig_total) * 100}")

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Estadísticas del Historial${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Videos procesados: ${GREEN}$total_procesados${NC}"
    echo -e "  Tamaño original total:   ${YELLOW}$(formatear_tamanio "$tam_orig_total")${NC}"
    echo -e "  Tamaño convertido total: ${GREEN}$(formatear_tamanio "$tam_comp_total")${NC}"
    echo -e "  ${GREEN}Ahorro total: $(formatear_tamanio "$ahorro") (${pct}%)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -n -e "${YELLOW}Presiona Enter para continuar...${NC}"; read -r
}

listar_procesados() {
    if [ ! -f "$ARCHIVO_HISTORIAL" ]; then
        echo -e "${RED}No hay historial disponible${NC}"
        echo -n -e "${YELLOW}Presiona Enter...${NC}"; read -r
        return
    fi
    echo ""
    echo -e "${BLUE}Últimos 20 videos procesados:${NC}"
    echo ""
    printf "${CYAN}%-19s %-40s %8s %8s %6s${NC}\n" "Fecha" "Archivo" "Original" "Salida" "Ahorro"
    echo "────────────────────────────────────────────────────────────────────────────────"
    while IFS='|' read -r fecha orig comp tam_orig tam_comp reduccion; do
        local nombre
        nombre=$(basename "$orig")
        printf "%-19s %-40s %8s %8s %5s%%\n" \
            "$fecha" \
            "${nombre:0:38}" \
            "$(formatear_tamanio "$tam_orig")" \
            "$(formatear_tamanio "$tam_comp")" \
            "$reduccion"
    done < "$ARCHIVO_HISTORIAL" | tail -n 20
    echo ""
    echo -n -e "${YELLOW}Presiona Enter para continuar...${NC}"; read -r
}

resetear_historial() {
    echo -n -e "${RED}¿Resetear historial? Perderás el registro de videos procesados (s/N): ${NC}"
    read -r confirmacion
    if [[ "$confirmacion" =~ ^[Ss]$ ]]; then
        rm -f "$ARCHIVO_HISTORIAL"
        echo -e "${GREEN}✓ Historial reseteado${NC}"
        log_mensaje "HISTORIAL RESETEADO"
    else
        echo -e "${YELLOW}Cancelado${NC}"
    fi
    sleep 2
}

eliminar_duplicados() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${YELLOW}ELIMINAR DUPLICADOS${NC}                                            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ -z "$DIRECTORIO_ORIGEN" ] || [ ! -d "$DIRECTORIO_ORIGEN" ]; then
        echo -e "${RED}✗ Primero debes seleccionar una carpeta de origen (opción 1 del menú principal)${NC}"
        echo -n -e "${YELLOW}Presiona Enter...${NC}"; read -r
        return
    fi

    echo -e "${CYAN}Buscando duplicados en: $DIRECTORIO_ORIGEN${NC}"
    echo ""

    declare -A checksums
    local duplicados_encontrados=0
    local archivos_duplicados=()

    while IFS= read -r -d '' archivo; do
        local checksum
        checksum=$(obtener_checksum "$archivo")
        if [ -n "${checksums[$checksum]}" ]; then
            echo -e "${YELLOW}Duplicado:${NC} $(basename "$archivo")"
            echo -e "  ${CYAN}Original:${NC} ${checksums[$checksum]}"
            archivos_duplicados+=("$archivo")
            duplicados_encontrados=$((duplicados_encontrados + 1))
        else
            checksums[$checksum]="$archivo"
        fi
    done < <(find "$DIRECTORIO_ORIGEN" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" \) -print0)

    echo ""
    echo -e "${CYAN}Total duplicados: ${GREEN}$duplicados_encontrados${NC}"

    if [ "$duplicados_encontrados" -eq 0 ]; then
        echo -e "${GREEN}✓ No hay duplicados${NC}"
        echo -n -e "${YELLOW}Presiona Enter...${NC}"; read -r
        return
    fi

    echo -n -e "${RED}¿Eliminar estos duplicados? (s/N): ${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        for f in "${archivos_duplicados[@]}"; do
            rm "$f"
            echo -e "  ${RED}✗ Eliminado:${NC} $(basename "$f")"
            log_mensaje "DUPLICADO ELIMINADO: $f"
        done
        echo -e "${GREEN}✓ $duplicados_encontrados duplicados eliminados${NC}"
    else
        echo -e "${YELLOW}Cancelado${NC}"
    fi
    echo -n -e "${YELLOW}Presiona Enter...${NC}"; read -r
}

eliminar_por_extension() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${YELLOW}ELIMINAR POR EXTENSIÓN${NC}                                         ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ -z "$DIRECTORIO_ORIGEN" ] || [ ! -d "$DIRECTORIO_ORIGEN" ]; then
        echo -e "${RED}✗ Primero selecciona una carpeta de origen en el menú principal${NC}"
        echo -n -e "${YELLOW}Presiona Enter...${NC}"; read -r
        return
    fi

    echo -n -e "${YELLOW}Extensión a eliminar (ej: mkv, avi, wmv): ${NC}"
    read -r extension
    extension="${extension#.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    if [ -z "$extension" ]; then
        echo -e "${RED}✗ Extensión inválida${NC}"
        sleep 2
        return
    fi

    local archivos=()
    local espacio_total=0
    while IFS= read -r -d '' archivo; do
        archivos+=("$archivo")
        local tam
        tam=$(obtener_tamanio_mb "$archivo")
        espacio_total=$((espacio_total + tam))
        echo -e "  ${YELLOW}→${NC} $(basename "$archivo") ($(formatear_tamanio "$tam"))"
    done < <(find "$DIRECTORIO_ORIGEN" -type f -iname "*.${extension}" -print0)

    echo ""
    echo -e "${CYAN}Total: ${GREEN}${#archivos[@]} archivos${NC} — ${GREEN}$(formatear_tamanio "$espacio_total")${NC}"

    if [ "${#archivos[@]}" -eq 0 ]; then
        echo -e "${YELLOW}No se encontraron archivos .${extension}${NC}"
        echo -n -e "${YELLOW}Presiona Enter...${NC}"; read -r
        return
    fi

    echo -n -e "${RED}¿Eliminar todos estos archivos .${extension}? (s/N): ${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        for f in "${archivos[@]}"; do
            rm "$f"
            echo -e "  ${RED}✗ Eliminado:${NC} $(basename "$f")"
            log_mensaje "ELIMINADO POR EXTENSIÓN (.${extension}): $f"
        done
        echo -e "${GREEN}✓ ${#archivos[@]} archivos eliminados — $(formatear_tamanio "$espacio_total") liberados${NC}"
    else
        echo -e "${YELLOW}Cancelado${NC}"
    fi
    echo -n -e "${YELLOW}Presiona Enter...${NC}"; read -r
}

################################################################################
# AYUDA
################################################################################

mostrar_ayuda() {
    cat << EOF
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${CYAN}  Convertidor de Videos v3.0 — César Auris${NC}
${CYAN}  www.solucionessystem.com${NC}
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}Uso:${NC}
  $0 [OPCIONES] [DIRECTORIO]

${YELLOW}Opciones:${NC}
  ${GREEN}-h, --help${NC}              Mostrar esta ayuda
  ${GREEN}-q, --quality CRF${NC}      CRF (0-51, default: 20)
  ${GREEN}-p, --preset PRESET${NC}    Velocidad de codificación
  ${GREEN}-m, --min-size MB${NC}      Tamaño mínimo (default: 10MB)
  ${GREEN}-o, --output DIR${NC}       Carpeta de salida
  ${GREEN}-f, --format FORMAT${NC}    Formato: mp4, mkv, mov
  ${GREEN}-i, --interactive${NC}      Confirmar video por video
  ${GREEN}-b, --backup${NC}           Crear backup al sobrescribir
  ${GREEN}--perfil NOMBRE${NC}        Perfil: facebook, youtube, whatsapp, general
  ${GREEN}--reset${NC}                Resetear historial
  ${GREEN}--stats${NC}                Ver estadísticas

${YELLOW}Perfiles disponibles:${NC}
  facebook | facebook_ligero | youtube | whatsapp | general | solo_convertir

${YELLOW}Ejemplos:${NC}
  # Menú interactivo completo
  $0

  # Convertir directamente para Facebook sin menú
  $0 --perfil facebook -o ./convertidos /ruta/mis_videos

  # Solo cambiar contenedor sin recodificar (muy rápido)
  $0 --perfil solo_convertir /ruta/mis_videos

${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
EOF
}

################################################################################
# MENÚ PRINCIPAL
################################################################################

mostrar_menu_principal() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}Convertidor Avanzado de Videos v3.0${NC}                            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}César Auris — www.solucionessystem.com${NC}                         ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Info de carpetas configuradas
    if [ -n "$DIRECTORIO_ORIGEN" ] && [ -d "$DIRECTORIO_ORIGEN" ]; then
        local info_v
        info_v=$(contar_videos_dir "$DIRECTORIO_ORIGEN")
        local nv
        nv=$(echo "$info_v" | cut -d'|' -f1)
        local tv
        tv=$(echo "$info_v" | cut -d'|' -f2)
        echo -e "${YELLOW}📂 Origen:${NC}  ${CYAN}$DIRECTORIO_ORIGEN${NC}"
        echo -e "   ${GREEN}$nv video(s)${NC} — $(formatear_tamanio "$tv") total"
    else
        echo -e "${YELLOW}📂 Origen:${NC}  ${RED}No configurado${NC}"
    fi

    if [ -n "$DIRECTORIO_SALIDA" ]; then
        echo -e "${YELLOW}📁 Salida:${NC}  ${CYAN}$DIRECTORIO_SALIDA${NC}"
    else
        echo -e "${YELLOW}📁 Salida:${NC}  ${RED}No configurada${NC}"
    fi

    echo ""
    echo -e "${YELLOW}⚙️  Perfil activo:${NC} ${GREEN}CRF $CRF | $PRESET | .${FORMATO_SALIDA} | Audio $BITRATE_AUDIO$([ -n "$RESOLUCION" ] && echo " | ${RESOLUCION//:/ x }" || echo " | res. original")${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} 📂 Seleccionar carpeta de origen"
    echo -e "  ${GREEN}[2]${NC} 📁 Seleccionar carpeta de salida"
    echo -e "  ${GREEN}[3]${NC} 🎬 Seleccionar perfil / calidad"
    echo -e "  ${GREEN}[4]${NC} ⚙️  Opciones avanzadas"
    echo -e "  ${GREEN}[5]${NC} 🔧 Utilidades (duplicados, limpiar)"
    echo ""
    echo -e "  ${WHITE}[ENTER]${NC} ▶  Iniciar conversión"
    echo ""
    echo -e "  ${RED}[0]${NC} Salir"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -n -e "${YELLOW}Selecciona una opción o ENTER para iniciar: ${NC}"
}

################################################################################
# PROCESAMIENTO DE ARGUMENTOS
################################################################################

cargar_configuracion

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) mostrar_ayuda; exit 0 ;;
        -q|--quality) CRF="$2"; SKIP_MENU=true; shift 2 ;;
        -p|--preset) PRESET="$2"; SKIP_MENU=true; shift 2 ;;
        -m|--min-size) TAMANIO_MINIMO="$2"; SKIP_MENU=true; shift 2 ;;
        -o|--output) DIRECTORIO_SALIDA="$2"; SKIP_MENU=true; shift 2 ;;
        -f|--format) FORMATO_SALIDA="$2"; SKIP_MENU=true; shift 2 ;;
        -i|--interactive) MODO_INTERACTIVO=true; shift ;;
        -b|--backup) CREAR_BACKUP=true; shift ;;
        --perfil) aplicar_perfil "$2"; SKIP_MENU=true; shift 2 ;;
        --reset)
            ARCHIVO_HISTORIAL="${1:-$(pwd)}/.historial_conversion_videos.txt"
            resetear_historial; exit 0 ;;
        --stats) mostrar_estadisticas_historial; exit 0 ;;
        *)
            if [ -d "$1" ]; then DIRECTORIO_ORIGEN="$1"; SKIP_MENU=true
            else echo -e "${RED}✗ Directorio no válido: $1${NC}"; exit 1
            fi
            shift ;;
    esac
done

################################################################################
# FLUJO INTERACTIVO
################################################################################

if [ "$SKIP_MENU" = false ]; then
    # Cargar carpetas guardadas
    [ -n "$DIRECTORIO_ORIGEN_DEFAULT" ] && [ -d "$DIRECTORIO_ORIGEN_DEFAULT" ] && DIRECTORIO_ORIGEN="$DIRECTORIO_ORIGEN_DEFAULT"
    [ -n "$DIRECTORIO_SALIDA_DEFAULT" ] && DIRECTORIO_SALIDA="$DIRECTORIO_SALIDA_DEFAULT"

    while true; do
        mostrar_menu_principal
        read -r opcion_principal

        case "${opcion_principal:-INICIAR}" in
            1) seleccionar_directorio_origen ;;
            2)
                if [ -z "$DIRECTORIO_ORIGEN" ] || [ ! -d "$DIRECTORIO_ORIGEN" ]; then
                    echo -e "${RED}✗ Primero selecciona la carpeta de origen (opción 1)${NC}"
                    sleep 2
                else
                    seleccionar_directorio_salida
                fi
                ;;
            3) seleccionar_perfil ;;
            4) menu_opciones_avanzadas ;;
            5) menu_utilidades ;;
            0) echo -e "\n${YELLOW}¡Hasta luego!${NC}"; exit 0 ;;
            INICIAR|"")
                if [ -z "$DIRECTORIO_ORIGEN" ] || [ ! -d "$DIRECTORIO_ORIGEN" ]; then
                    echo -e "\n${RED}✗ Debes seleccionar una carpeta de origen primero (opción 1)${NC}"
                    sleep 2
                else
                    if [ -z "$DIRECTORIO_SALIDA" ]; then
                        DIRECTORIO_SALIDA="${DIRECTORIO_ORIGEN}/videos_convertidos"
                    fi
                    # Guardar configuración y salir del menú para iniciar
                    guardar_configuracion
                    break
                fi
                ;;
            *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
        esac
    done
else
    [ -z "$DIRECTORIO_ORIGEN" ] && DIRECTORIO_ORIGEN="."
    [ -z "$DIRECTORIO_SALIDA" ] && DIRECTORIO_SALIDA="${DIRECTORIO_ORIGEN}/videos_convertidos"
fi

################################################################################
# VALIDACIONES PREVIAS AL PROCESO
################################################################################

verificar_ffmpeg

if [ ! -d "$DIRECTORIO_ORIGEN" ]; then
    echo -e "${RED}✗ La carpeta de origen no existe: $DIRECTORIO_ORIGEN${NC}"
    exit 1
fi

mkdir -p "$DIRECTORIO_SALIDA"

ARCHIVO_HISTORIAL="${DIRECTORIO_ORIGEN}/${ARCHIVO_HISTORIAL}"
ARCHIVO_LOG="${DIRECTORIO_ORIGEN}/${ARCHIVO_LOG}"
touch "$ARCHIVO_HISTORIAL" "$ARCHIVO_LOG"

################################################################################
# INICIO DEL PROCESO
################################################################################

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Convertidor de Videos v3.0${NC}"
echo -e "${CYAN}  César Auris — www.solucionessystem.com${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Configuración de esta sesión:${NC}"
echo "  • Origen:   $DIRECTORIO_ORIGEN"
echo "  • Salida:   $DIRECTORIO_SALIDA"
echo "  • Formato:  .${FORMATO_SALIDA} | CRF: $CRF | Preset: $PRESET"
echo "  • Audio:    $BITRATE_AUDIO | Codec: $CODEC_VIDEO"
[ -n "$RESOLUCION" ] && echo "  • Resolución: ${RESOLUCION//:/ x }" || echo "  • Resolución: original"
[ "$SOBRESCRIBIR_ORIGINAL" = true ] && echo -e "  • ${RED}Modo: Sobrescribir originales${NC}"
[ "$BATCH_SIZE" -gt 0 ] && echo "  • Batch: $BATCH_SIZE videos por lote"
echo ""
echo -e "${GREEN}Iniciando conversión...${NC}"
echo ""

log_mensaje "=========================================="
log_mensaje "INICIO — CRF:$CRF PRESET:$PRESET FORMATO:$FORMATO_SALIDA"
log_mensaje "Origen: $DIRECTORIO_ORIGEN | Salida: $DIRECTORIO_SALIDA"
log_mensaje "=========================================="

total_videos=0
videos_exitosos=0
videos_error=0
videos_omitidos=0
videos_en_lote=0

# Construir expresión find para todas las extensiones soportadas
FIND_EXPR=""
for ext in $EXTENSIONES_ENTRADA; do
    FIND_EXPR="$FIND_EXPR -o -name *.${ext}"
done
FIND_EXPR="${FIND_EXPR# -o }"

while IFS= read -r -d '' archivo; do
    total_videos=$((total_videos + 1))

    convertir_video "$archivo"
    case $? in
        0)
            videos_exitosos=$((videos_exitosos + 1))
            videos_en_lote=$((videos_en_lote + 1))
            ;;
        1)
            videos_error=$((videos_error + 1))
            videos_en_lote=$((videos_en_lote + 1))
            ;;
        2)
            videos_omitidos=$((videos_omitidos + 1))
            ;;
    esac

    # Pausa por lotes
    if [ "$BATCH_SIZE" -gt 0 ] && [ "$videos_en_lote" -ge "$BATCH_SIZE" ]; then
        echo -e "${MAGENTA}━━━━ Lote completado: $videos_en_lote videos — Total procesados: $((videos_exitosos + videos_error)) ━━━━${NC}"
        echo -n -e "${YELLOW}Presiona Enter para continuar con el siguiente lote (Ctrl+C para detener)...${NC}"
        read -r
        videos_en_lote=0
        echo ""
    fi

done < <(eval "find \"$DIRECTORIO_ORIGEN\" -type f \( $FIND_EXPR \) \
    -not -path \"*/videos_convertidos/*\" \
    -not -path \"*/comprimidos_videos/*\" \
    -not -path \"*/comprimidos_videos_temp/*\" \
    -print0" 2>/dev/null)

################################################################################
# RESUMEN FINAL
################################################################################

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Resumen Final${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  Total encontrados: $total_videos"
echo "  Omitidos:          $videos_omitidos"
echo -e "  ${GREEN}✓ Exitosos: $videos_exitosos${NC}"
[ "$videos_error" -gt 0 ] && echo -e "  ${RED}✗ Errores: $videos_error${NC}"
echo ""
echo "  Salida: $DIRECTORIO_SALIDA"
echo "  Log: $ARCHIVO_LOG"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\n${GREEN}¡Proceso completado!${NC}"
echo -e "Para estadísticas: ${CYAN}$0 --stats${NC}"
echo ""
echo -e "${CYAN}Script desarrollado por César Auris — www.solucionessystem.com${NC}"

log_mensaje "FIN — Total:$total_videos | Exitosos:$videos_exitosos | Errores:$videos_error | Omitidos:$videos_omitidos"