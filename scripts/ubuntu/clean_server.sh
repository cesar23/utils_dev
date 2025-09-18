#!/bin/bash

# =============================================================================
# 📋 Uso del Script
# =============================================================================
## Copiar sin extensión para que se vea más profesional
# sudo cp clean_server.sh /usr/local/bin/clean_server
#  sudo chmod a+rx /usr/local/bin/clean_server



# =============================================================================
# 📋 SCRIPT: Limpiador Completo del Servidor
# =============================================================================
# Autor: Sistema de Administración
# Descripción: Script completo para limpieza y mantenimiento del servidor
# Versión: 2.0
# =============================================================================

# =============================================================================
# 🎯 SECTION: Variables de Configuración
# =============================================================================
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

# Variables para estadísticas
INITIAL_SIZE=0
FINAL_SIZE=0
CLEANED_FILES=0

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
# 🛠️ SECTION: Funciones Auxiliares
# =============================================================================

# Función para verificar si el usuario tiene permisos de sudo
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        msg "Este script requiere permisos de administrador (sudo)" "WARNING"
        msg "Por favor, ejecuta: sudo $0" "INFO"
        exit 1
    fi
}

# Función para mostrar información del sistema
show_system_info() {
    echo -e "\n${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BCyan}                    INFORMACIÓN DEL SISTEMA${Color_Off}"
    echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BWhite}📅 Fecha y Hora (Perú):${Color_Off} $DATE_HOUR_PE"
    echo -e "${BWhite}👤 Usuario:${Color_Off} $CURRENT_USER"
    echo -e "${BWhite}💻 Equipo:${Color_Off} $CURRENT_PC_NAME"
    echo -e "${BWhite}📁 Directorio del Script:${Color_Off} $CURRENT_DIR"
    echo -e "${BWhite}📄 Nombre del Script:${Color_Off} $SCRIPT_NAME"
    echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BGreen}👨‍💻 Desarrollado por:${Color_Off} ${BWhite}Ingeniero - Cesar Auris${Color_Off}"
    echo -e "${BGreen}📞 Teléfono:${Color_Off} ${BWhite}937516027${Color_Off}"
    echo -e "${BGreen}🌐 Website:${Color_Off} ${BWhite}https://solucionessystem.com${Color_Off}"
    echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}\n"
}

# Función para obtener tamaño en bytes de un directorio/archivo
get_size_bytes() {
    local path="$1"
    if [ -e "$path" ]; then
        du -sb "$path" 2>/dev/null | cut -f1 || echo "0"
    else
        echo "0"
    fi
}

# Función para convertir bytes a formato legible
bytes_to_human() {
    local bytes="$1"
    if [ "$bytes" -eq 0 ]; then
        echo "0B"
        return
    fi

    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    local size=$bytes

    while [ "$size" -gt 1024 ] && [ "$unit" -lt 4 ]; do
        size=$((size / 1024))
        unit=$((unit + 1))
    done

    echo "${size}${units[$unit]}"
}

# Función para confirmar acción peligrosa
confirm_dangerous_action() {
    local action="$1"
    echo -e "\n${BRed}⚠️  ADVERTENCIA: $action${Color_Off}"
    echo -e "${BYellow}Esta operación puede afectar el funcionamiento del sistema.${Color_Off}"
    read -p "¿Estás seguro de continuar? (escriba 'SI' para confirmar): " confirmation

    if [ "$confirmation" != "SI" ]; then
        msg "Operación cancelada por el usuario" "WARNING"
        return 1
    fi
    return 0
}

# Función para pausar y esperar input
pause() {
    echo -e "\n${BGray}Presiona Enter para continuar...${Color_Off}"
    read
}

# =============================================================================
# 🗑️ SECTION: Limpieza de Archivos Temporales
# =============================================================================

clean_temp_files() {
    echo -e "\n${BCyan}🗑️ LIMPIEZA DE ARCHIVOS TEMPORALES${Color_Off}\n"

    local options=(
        "Limpiar /tmp/"
        "Limpiar /var/tmp/"
        "Limpiar cache de usuarios (~/.cache/)"
        "Limpiar /var/cache/"
        "Limpiar thumbnails y iconos cache"
        "Limpiar archivos .tmp, .temp, .bak, .old"
        "Limpiar todos los temporales"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}     LIMPIEZA DE ARCHIVOS TEMPORALES${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-8): " choice

        case $choice in
            1)
                msg "Limpiando /tmp/..." "INFO"
                local tmp_size=$(get_size_bytes "/tmp")
                sudo find /tmp -type f -atime +7 -delete 2>/dev/null || true
                sudo find /tmp -type d -empty -delete 2>/dev/null || true
                local new_size=$(get_size_bytes "/tmp")
                msg "Liberados: $(bytes_to_human $((tmp_size - new_size)))" "SUCCESS"
                ;;
            2)
                msg "Limpiando /var/tmp/..." "INFO"
                local var_tmp_size=$(get_size_bytes "/var/tmp")
                sudo find /var/tmp -type f -atime +7 -delete 2>/dev/null || true
                sudo find /var/tmp -type d -empty -delete 2>/dev/null || true
                local new_size=$(get_size_bytes "/var/tmp")
                msg "Liberados: $(bytes_to_human $((var_tmp_size - new_size)))" "SUCCESS"
                ;;
            3)
                msg "Limpiando cache de usuarios..." "INFO"
                local total_freed=0
                for user_home in /home/*; do
                    if [ -d "$user_home/.cache" ]; then
                        local cache_size=$(get_size_bytes "$user_home/.cache")
                        sudo rm -rf "$user_home/.cache"/* 2>/dev/null || true
                        local new_size=$(get_size_bytes "$user_home/.cache")
                        total_freed=$((total_freed + cache_size - new_size))
                    fi
                done
                msg "Liberados: $(bytes_to_human $total_freed)" "SUCCESS"
                ;;
            4)
                msg "Limpiando /var/cache/..." "INFO"
                local cache_size=$(get_size_bytes "/var/cache")
                sudo find /var/cache -type f -atime +30 -delete 2>/dev/null || true
                local new_size=$(get_size_bytes "/var/cache")
                msg "Liberados: $(bytes_to_human $((cache_size - new_size)))" "SUCCESS"
                ;;
            5)
                msg "Limpiando thumbnails y iconos cache..." "INFO"
                local total_freed=0
                for user_home in /home/*; do
                    if [ -d "$user_home/.thumbnails" ]; then
                        local thumb_size=$(get_size_bytes "$user_home/.thumbnails")
                        sudo rm -rf "$user_home/.thumbnails"/* 2>/dev/null || true
                        total_freed=$((total_freed + thumb_size))
                    fi
                    if [ -d "$user_home/.cache/thumbnails" ]; then
                        local cache_thumb_size=$(get_size_bytes "$user_home/.cache/thumbnails")
                        sudo rm -rf "$user_home/.cache/thumbnails"/* 2>/dev/null || true
                        total_freed=$((total_freed + cache_thumb_size))
                    fi
                done
                msg "Liberados: $(bytes_to_human $total_freed)" "SUCCESS"
                ;;
            6)
                confirm_dangerous_action "LIMPIAR ARCHIVOS .tmp, .temp, .bak, .old"
                if [ $? -eq 0 ]; then
                    msg "Buscando y eliminando archivos temporales..." "INFO"
                    local count=0
                    count=$(sudo find /home /var /opt -name "*.tmp" -o -name "*.temp" -o -name "*.bak" -o -name "*.old" | wc -l)
                    sudo find /home /var /opt -name "*.tmp" -delete 2>/dev/null || true
                    sudo find /home /var /opt -name "*.temp" -delete 2>/dev/null || true
                    sudo find /home /var /opt -name "*.bak" -delete 2>/dev/null || true
                    sudo find /home /var /opt -name "*.old" -delete 2>/dev/null || true
                    msg "Eliminados: $count archivos temporales" "SUCCESS"
                fi
                ;;
            7)
                confirm_dangerous_action "LIMPIEZA COMPLETA DE TEMPORALES"
                if [ $? -eq 0 ]; then
                    msg "Ejecutando limpieza completa de temporales..." "INFO"
                    # Ejecutar todas las limpiezas anteriores
                    sudo find /tmp -type f -atime +1 -delete 2>/dev/null || true
                    sudo find /var/tmp -type f -atime +1 -delete 2>/dev/null || true
                    sudo find /var/cache -type f -atime +7 -delete 2>/dev/null || true
                    for user_home in /home/*; do
                        sudo rm -rf "$user_home/.cache"/* 2>/dev/null || true
                        sudo rm -rf "$user_home/.thumbnails"/* 2>/dev/null || true
                    done
                    msg "Limpieza completa de temporales finalizada" "SUCCESS"
                fi
                ;;
            8)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# 📦 SECTION: Gestión de Paquetes
# =============================================================================

clean_packages() {
    echo -e "\n${BCyan}📦 GESTIÓN DE PAQUETES${Color_Off}\n"

    local options=(
        "Limpiar cache de APT"
        "Limpiar cache de YUM/DNF"
        "Limpiar cache de SNAP"
        "Eliminar paquetes huérfanos"
        "Limpiar cache de pip/pip3"
        "Limpiar cache de npm/yarn"
        "Limpiar cache de composer (PHP)"
        "Limpieza completa de paquetes"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}        GESTIÓN DE PAQUETES${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-9): " choice

        case $choice in
            1)
                if command -v apt &> /dev/null; then
                    msg "Limpiando cache de APT..." "INFO"
                    sudo apt clean
                    sudo apt autoclean
                    msg "Cache de APT limpiado" "SUCCESS"
                else
                    msg "APT no está disponible en este sistema" "WARNING"
                fi
                ;;
            2)
                if command -v yum &> /dev/null; then
                    msg "Limpiando cache de YUM..." "INFO"
                    sudo yum clean all
                    msg "Cache de YUM limpiado" "SUCCESS"
                elif command -v dnf &> /dev/null; then
                    msg "Limpiando cache de DNF..." "INFO"
                    sudo dnf clean all
                    msg "Cache de DNF limpiado" "SUCCESS"
                else
                    msg "YUM/DNF no está disponible en este sistema" "WARNING"
                fi
                ;;
            3)
                if command -v snap &> /dev/null; then
                    msg "Limpiando cache de SNAP..." "INFO"
                    sudo snap set system refresh.retain=2
                    # Limpiar versiones antiguas de snaps
                    sudo sh -c 'for snap in $(snap list --all | awk "/disabled/{print \$1,\$3}"); do snap remove "$snap"; done' 2>/dev/null || true
                    msg "Cache de SNAP limpiado" "SUCCESS"
                else
                    msg "SNAP no está disponible en este sistema" "WARNING"
                fi
                ;;
            4)
                if command -v apt &> /dev/null; then
                    msg "Eliminando paquetes huérfanos..." "INFO"
                    sudo apt autoremove -y
                    sudo apt autoclean
                    msg "Paquetes huérfanos eliminados" "SUCCESS"
                elif command -v yum &> /dev/null; then
                    msg "Eliminando paquetes huérfanos con YUM..." "INFO"
                    sudo yum autoremove -y
                    msg "Paquetes huérfanos eliminados" "SUCCESS"
                elif command -v dnf &> /dev/null; then
                    msg "Eliminando paquetes huérfanos con DNF..." "INFO"
                    sudo dnf autoremove -y
                    msg "Paquetes huérfanos eliminados" "SUCCESS"
                else
                    msg "Sistema de paquetes no soportado" "WARNING"
                fi
                ;;
            5)
                if command -v pip &> /dev/null || command -v pip3 &> /dev/null; then
                    msg "Limpiando cache de pip..." "INFO"
                    pip cache purge 2>/dev/null || true
                    pip3 cache purge 2>/dev/null || true
                    # Limpiar cache manual
                    rm -rf ~/.cache/pip/* 2>/dev/null || true
                    msg "Cache de pip limpiado" "SUCCESS"
                else
                    msg "pip no está disponible en este sistema" "WARNING"
                fi
                ;;
            6)
                if command -v npm &> /dev/null; then
                    msg "Limpiando cache de npm..." "INFO"
                    npm cache clean --force 2>/dev/null || true
                    msg "Cache de npm limpiado" "SUCCESS"
                fi
                if command -v yarn &> /dev/null; then
                    msg "Limpiando cache de yarn..." "INFO"
                    yarn cache clean 2>/dev/null || true
                    msg "Cache de yarn limpiado" "SUCCESS"
                fi
                if ! command -v npm &> /dev/null && ! command -v yarn &> /dev/null; then
                    msg "npm/yarn no están disponibles en este sistema" "WARNING"
                fi
                ;;
            7)
                if command -v composer &> /dev/null; then
                    msg "Limpiando cache de composer..." "INFO"
                    composer clear-cache 2>/dev/null || true
                    msg "Cache de composer limpiado" "SUCCESS"
                else
                    msg "Composer no está disponible en este sistema" "WARNING"
                fi
                ;;
            8)
                confirm_dangerous_action "LIMPIEZA COMPLETA DE PAQUETES"
                if [ $? -eq 0 ]; then
                    msg "Ejecutando limpieza completa de paquetes..." "INFO"

                    # APT
                    if command -v apt &> /dev/null; then
                        sudo apt clean && sudo apt autoclean && sudo apt autoremove -y
                    fi

                    # YUM/DNF
                    if command -v yum &> /dev/null; then
                        sudo yum clean all && sudo yum autoremove -y
                    elif command -v dnf &> /dev/null; then
                        sudo dnf clean all && sudo dnf autoremove -y
                    fi

                    # SNAP
                    if command -v snap &> /dev/null; then
                        sudo snap set system refresh.retain=2
                    fi

                    # pip, npm, composer
                    pip cache purge 2>/dev/null || true
                    pip3 cache purge 2>/dev/null || true
                    npm cache clean --force 2>/dev/null || true
                    yarn cache clean 2>/dev/null || true
                    composer clear-cache 2>/dev/null || true

                    msg "Limpieza completa de paquetes finalizada" "SUCCESS"
                fi
                ;;
            9)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# 📋 SECTION: Limpieza y Rotación de Logs
# =============================================================================

clean_logs() {
    echo -e "\n${BCyan}📋 LIMPIEZA Y ROTACIÓN DE LOGS${Color_Off}\n"

    local options=(
        "Limpieza profunda de logs (PELIGROSO)"
        "Limpieza selectiva de logs"
        "Rotación automática de logs"
        "Comprimir logs antiguos"
        "Eliminar logs antiguos (>30 días)"
        "Limpiar logs por aplicación"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}      LIMPIEZA Y ROTACIÓN DE LOGS${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-7): " choice

        case $choice in
            1)
                deep_clean_logs
                ;;
            2)
                selective_clean_logs
                ;;
            3)
                rotate_logs
                ;;
            4)
                compress_old_logs
                ;;
            5)
                delete_old_logs
                ;;
            6)
                clean_app_logs
                ;;
            7)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# Función para limpieza profunda de logs (la original)
deep_clean_logs() {
    echo -e "\n${BRed}⚠️  ADVERTENCIA: LIMPIEZA PROFUNDA DE LOGS${Color_Off}"
    echo -e "${BYellow}Esta operación eliminará TODOS los logs del sistema.${Color_Off}"
    echo -e "${BYellow}Los logs son importantes para diagnósticos futuros.${Color_Off}\n"

    read -p "¿Estás seguro de continuar? (escriba 'SI' para confirmar): " confirmation

    if [ "$confirmation" != "SI" ]; then
        msg "Operación cancelada por el usuario" "WARNING"
        return 1
    fi

    msg "Iniciando limpieza profunda de logs..." "INFO"

    # Rotar y limpiar journalctl
    msg "Rotando y limpiando journalctl..." "INFO"
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=1s

    # Vaciar logs del kernel
    msg "Vaciando logs del kernel..." "INFO"
    sudo dmesg -C

    # Limpiar logs específicos de CyberPanel y LiteSpeed
    if [ -f "/home/cyberpanel/error-logs.txt" ]; then
        msg "Limpiando logs de CyberPanel..." "INFO"
        sudo truncate -s 0 /home/cyberpanel/error-logs.txt
    fi

    if [ -f "/usr/local/lsws/logs/access.log" ]; then
        msg "Limpiando logs de acceso de LiteSpeed..." "INFO"
        sudo truncate -s 0 /usr/local/lsws/logs/access.log
    fi

    if [ -f "/usr/local/lsws/logs/error.log" ]; then
        msg "Limpiando logs de error de LiteSpeed..." "INFO"
        sudo truncate -s 0 /usr/local/lsws/logs/error.log
    fi

    # Limpiar logs del sistema
    msg "Limpiando logs del sistema..." "INFO"
    [ -f "/var/log/mail.log" ] && sudo truncate -s 0 /var/log/mail.log
    [ -f "/var/log/syslog" ] && sudo truncate -s 0 /var/log/syslog
    [ -f "/var/log/auth.log" ] && sudo truncate -s 0 /var/log/auth.log

    # Limpiar todos los archivos *.log en /var/log
    msg "Limpiando todos los archivos *.log en /var/log..." "WARNING"
    sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

    msg "🎉 Limpieza profunda de logs completada exitosamente!" "SUCCESS"
}

# Función para limpieza selectiva de logs
selective_clean_logs() {
    echo -e "\n${BGreen}🎯 LIMPIEZA SELECTIVA DE LOGS${Color_Off}"
    echo -e "${BWhite}Selecciona los logs que deseas limpiar:${Color_Off}\n"

    local options=(
        "Journalctl (systemd logs)"
        "Kernel logs (dmesg)"
        "CyberPanel logs"
        "LiteSpeed/OpenLiteSpeed logs"
        "Mail logs"
        "System logs (syslog)"
        "Authentication logs (auth.log)"
        "Todos los archivos *.log en /var/log"
        "Volver"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}        LIMPIEZA SELECTIVA DE LOGS${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-9): " choice

        case $choice in
            1)
                msg "Limpiando journalctl..." "INFO"
                sudo journalctl --rotate
                sudo journalctl --vacuum-time=7d
                msg "Journalctl limpiado (mantenidos últimos 7 días)" "SUCCESS"
                ;;
            2)
                msg "Limpiando kernel logs..." "INFO"
                sudo dmesg -C
                msg "Kernel logs limpiados" "SUCCESS"
                ;;
            3)
                if [ -f "/home/cyberpanel/error-logs.txt" ]; then
                    msg "Limpiando CyberPanel logs..." "INFO"
                    sudo truncate -s 0 /home/cyberpanel/error-logs.txt
                    msg "CyberPanel logs limpiados" "SUCCESS"
                else
                    msg "CyberPanel logs no encontrados" "WARNING"
                fi
                ;;
            4)
                local cleaned=0
                if [ -f "/usr/local/lsws/logs/access.log" ]; then
                    sudo truncate -s 0 /usr/local/lsws/logs/access.log
                    cleaned=1
                fi
                if [ -f "/usr/local/lsws/logs/error.log" ]; then
                    sudo truncate -s 0 /usr/local/lsws/logs/error.log
                    cleaned=1
                fi

                if [ $cleaned -eq 1 ]; then
                    msg "LiteSpeed logs limpiados" "SUCCESS"
                else
                    msg "LiteSpeed logs no encontrados" "WARNING"
                fi
                ;;
            5)
                if [ -f "/var/log/mail.log" ]; then
                    msg "Limpiando mail logs..." "INFO"
                    sudo truncate -s 0 /var/log/mail.log
                    msg "Mail logs limpiados" "SUCCESS"
                else
                    msg "Mail logs no encontrados" "WARNING"
                fi
                ;;
            6)
                if [ -f "/var/log/syslog" ]; then
                    msg "Limpiando syslog..." "INFO"
                    sudo truncate -s 0 /var/log/syslog
                    msg "Syslog limpiado" "SUCCESS"
                else
                    msg "Syslog no encontrado" "WARNING"
                fi
                ;;
            7)
                if [ -f "/var/log/auth.log" ]; then
                    msg "Limpiando auth.log..." "INFO"
                    sudo truncate -s 0 /var/log/auth.log
                    msg "Auth.log limpiado" "SUCCESS"
                else
                    msg "Auth.log no encontrado" "WARNING"
                fi
                ;;
            8)
                confirm_dangerous_action "LIMPIAR TODOS LOS ARCHIVOS *.log"
                if [ $? -eq 0 ]; then
                    msg "Limpiando todos los archivos *.log..." "WARNING"
                    sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
                    msg "Todos los archivos *.log limpiados" "SUCCESS"
                fi
                ;;
            9)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
    done
}

# Función para rotar logs
rotate_logs() {
    msg "Rotando logs del sistema..." "INFO"

    # Rotar journalctl manteniendo últimos 30 días
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=30d

    # Rotar logs tradicionales si logrotate está disponible
    if command -v logrotate &> /dev/null; then
        sudo logrotate -f /etc/logrotate.conf
        msg "Logs rotados con logrotate" "SUCCESS"
    fi

    msg "Rotación de logs completada" "SUCCESS"
}

# Función para comprimir logs antiguos
compress_old_logs() {
    msg "Comprimiendo logs antiguos..." "INFO"

    # Comprimir logs de más de 7 días
    find /var/log -name "*.log" -type f -mtime +7 -exec gzip {} \; 2>/dev/null || true
    find /var/log -name "*.log.*[0-9]" -type f ! -name "*.gz" -exec gzip {} \; 2>/dev/null || true

    msg "Logs antiguos comprimidos" "SUCCESS"
}

# Función para eliminar logs antiguos
delete_old_logs() {
    confirm_dangerous_action "ELIMINAR LOGS ANTIGUOS (>30 días)"
    if [ $? -eq 0 ]; then
        msg "Eliminando logs antiguos..." "INFO"

        # Eliminar logs comprimidos de más de 30 días
        find /var/log -name "*.gz" -type f -mtime +30 -delete 2>/dev/null || true
        find /var/log -name "*.old" -type f -mtime +30 -delete 2>/dev/null || true
        find /var/log -name "*.[0-9]*" -type f -mtime +30 -delete 2>/dev/null || true

        msg "Logs antiguos eliminados" "SUCCESS"
    fi
}

# Función para limpiar logs por aplicación
clean_app_logs() {
    echo -e "\n${BGreen}📱 LIMPIAR LOGS POR APLICACIÓN${Color_Off}"

    local apps=(
        "Apache"
        "Nginx"
        "MySQL/MariaDB"
        "PHP"
        "Docker"
        "Volver"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}      LIMPIAR LOGS POR APLICACIÓN${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!apps[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${apps[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una aplicación (1-6): " choice

        case $choice in
            1) # Apache
                msg "Limpiando logs de Apache..." "INFO"
                [ -f "/var/log/apache2/access.log" ] && sudo truncate -s 0 /var/log/apache2/access.log
                [ -f "/var/log/apache2/error.log" ] && sudo truncate -s 0 /var/log/apache2/error.log
                sudo find /var/log/apache2/ -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
                msg "Logs de Apache limpiados" "SUCCESS"
                ;;
            2) # Nginx
                msg "Limpiando logs de Nginx..." "INFO"
                [ -f "/var/log/nginx/access.log" ] && sudo truncate -s 0 /var/log/nginx/access.log
                [ -f "/var/log/nginx/error.log" ] && sudo truncate -s 0 /var/log/nginx/error.log
                sudo find /var/log/nginx/ -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
                msg "Logs de Nginx limpiados" "SUCCESS"
                ;;
            3) # MySQL/MariaDB
                msg "Limpiando logs de MySQL/MariaDB..." "INFO"
                [ -f "/var/log/mysql/error.log" ] && sudo truncate -s 0 /var/log/mysql/error.log
                [ -f "/var/log/mysql/mysql.log" ] && sudo truncate -s 0 /var/log/mysql/mysql.log
                sudo find /var/log/mysql/ -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
                msg "Logs de MySQL/MariaDB limpiados" "SUCCESS"
                ;;
            4) # PHP
                msg "Limpiando logs de PHP..." "INFO"
                [ -f "/var/log/php_errors.log" ] && sudo truncate -s 0 /var/log/php_errors.log
                sudo find /var/log -name "php*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
                msg "Logs de PHP limpiados" "SUCCESS"
                ;;
            5) # Docker
                if command -v docker &> /dev/null; then
                    msg "Limpiando logs de Docker..." "INFO"
                    sudo docker system prune -f --volumes 2>/dev/null || true
                    sudo find /var/lib/docker/containers/ -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
                    msg "Logs de Docker limpiados" "SUCCESS"
                else
                    msg "Docker no está instalado" "WARNING"
                fi
                ;;
            6)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
    done
}

# =============================================================================
# 💾 SECTION: Limpieza de Bases de Datos
# =============================================================================

clean_databases() {
    echo -e "\n${BCyan}💾 LIMPIEZA DE BASES DE DATOS${Color_Off}\n"

    local options=(
        "Optimizar tablas MySQL/MariaDB"
        "Limpiar binlog de MySQL"
        "Vaciar slow query log"
        "Limpiar error log de MySQL"
        "Optimizar bases de datos SQLite"
        "Limpiar logs de PostgreSQL"
        "Limpieza completa de bases de datos"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}       LIMPIEZA DE BASES DE DATOS${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-8): " choice

        case $choice in
            1)
                if command -v mysql &> /dev/null || command -v mariadb &> /dev/null; then
                    confirm_dangerous_action "OPTIMIZAR TABLAS MYSQL/MARIADB"
                    if [ $? -eq 0 ]; then
                        msg "Optimizando tablas de MySQL/MariaDB..." "INFO"
                        echo "SHOW DATABASES;" | mysql -u root -p 2>/dev/null | grep -v "Database\|information_schema\|performance_schema\|mysql\|sys" | while read db; do
                            if [ -n "$db" ]; then
                                msg "Optimizando base de datos: $db" "INFO"
                                mysqlcheck -u root -p --optimize "$db" 2>/dev/null || true
                            fi
                        done
                        msg "Optimización completada" "SUCCESS"
                    fi
                else
                    msg "MySQL/MariaDB no está disponible" "WARNING"
                fi
                ;;
            2)
                if command -v mysql &> /dev/null; then
                    confirm_dangerous_action "LIMPIAR BINLOG DE MYSQL"
                    if [ $? -eq 0 ]; then
                        msg "Limpiando binlog de MySQL..." "INFO"
                        echo "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);" | mysql -u root -p 2>/dev/null || true
                        msg "Binlog limpiado" "SUCCESS"
                    fi
                else
                    msg "MySQL no está disponible" "WARNING"
                fi
                ;;
            3)
                msg "Vaciando slow query log..." "INFO"
                [ -f "/var/log/mysql/mysql-slow.log" ] && sudo truncate -s 0 /var/log/mysql/mysql-slow.log
                [ -f "/var/log/mysql-slow.log" ] && sudo truncate -s 0 /var/log/mysql-slow.log
                msg "Slow query log vaciado" "SUCCESS"
                ;;
            4)
                msg "Limpiando error log de MySQL..." "INFO"
                [ -f "/var/log/mysql/error.log" ] && sudo truncate -s 0 /var/log/mysql/error.log
                [ -f "/var/log/mysql.err" ] && sudo truncate -s 0 /var/log/mysql.err
                msg "Error log de MySQL limpiado" "SUCCESS"
                ;;
            5)
                msg "Optimizando bases de datos SQLite..." "INFO"
                find /var -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null | while read db; do
                    if [ -w "$db" ]; then
                        sqlite3 "$db" "VACUUM;" 2>/dev/null || true
                        msg "Optimizada: $db" "DEBUG"
                    fi
                done
                msg "Bases de datos SQLite optimizadas" "SUCCESS"
                ;;
            6)
                if command -v psql &> /dev/null; then
                    msg "Limpiando logs de PostgreSQL..." "INFO"
                    sudo find /var/log/postgresql -name "*.log" -mtime +7 -delete 2>/dev/null || true
                    msg "Logs de PostgreSQL limpiados" "SUCCESS"
                else
                    msg "PostgreSQL no está disponible" "WARNING"
                fi
                ;;
            7)
                confirm_dangerous_action "LIMPIEZA COMPLETA DE BASES DE DATOS"
                if [ $? -eq 0 ]; then
                    msg "Ejecutando limpieza completa de bases de datos..." "INFO"

                    # MySQL/MariaDB
                    if command -v mysql &> /dev/null; then
                        echo "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 3 DAY);" | mysql -u root -p 2>/dev/null || true
                        [ -f "/var/log/mysql/mysql-slow.log" ] && sudo truncate -s 0 /var/log/mysql/mysql-slow.log
                        [ -f "/var/log/mysql/error.log" ] && sudo truncate -s 0 /var/log/mysql/error.log
                    fi

                    # SQLite
                    find /var -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null | while read db; do
                        if [ -w "$db" ]; then
                            sqlite3 "$db" "VACUUM;" 2>/dev/null || true
                        fi
                    done

                    # PostgreSQL
                    if command -v psql &> /dev/null; then
                        sudo find /var/log/postgresql -name "*.log" -mtime +7 -delete 2>/dev/null || true
                    fi

                    msg "Limpieza completa de bases de datos finalizada" "SUCCESS"
                fi
                ;;
            8)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# 🌐 SECTION: Limpieza de Servidores Web
# =============================================================================

clean_web_servers() {
    echo -e "\n${BCyan}🌐 LIMPIEZA DE SERVIDORES WEB${Color_Off}\n"

    local options=(
        "Limpiar cache de Apache/Nginx"
        "Limpiar logs de acceso antiguos"
        "Limpiar cache de PHP OPcache"
        "Limpiar cache de Redis/Memcached"
        "Limpiar archivos de sesión PHP antiguos"
        "Limpiar cache de aplicaciones web"
        "Limpieza completa de servidores web"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}      LIMPIEZA DE SERVIDORES WEB${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-8): " choice

        case $choice in
            1)
                msg "Limpiando cache de servidores web..." "INFO"

                # Apache
                if [ -d "/var/cache/apache2" ]; then
                    sudo rm -rf /var/cache/apache2/* 2>/dev/null || true
                    msg "Cache de Apache limpiado" "SUCCESS"
                fi

                # Nginx
                if [ -d "/var/cache/nginx" ]; then
                    sudo rm -rf /var/cache/nginx/* 2>/dev/null || true
                    msg "Cache de Nginx limpiado" "SUCCESS"
                fi

                # LiteSpeed
                if [ -d "/usr/local/lsws/cachedata" ]; then
                    sudo rm -rf /usr/local/lsws/cachedata/* 2>/dev/null || true
                    msg "Cache de LiteSpeed limpiado" "SUCCESS"
                fi
                ;;
            2)
                confirm_dangerous_action "LIMPIAR LOGS DE ACCESO ANTIGUOS"
                if [ $? -eq 0 ]; then
                    msg "Limpiando logs de acceso antiguos..." "INFO"

                    # Eliminar logs de acceso de más de 30 días
                    find /var/log/apache2 -name "access.log.*" -mtime +30 -delete 2>/dev/null || true
                    find /var/log/nginx -name "access.log.*" -mtime +30 -delete 2>/dev/null || true
                    find /usr/local/lsws/logs -name "access.log.*" -mtime +30 -delete 2>/dev/null || true

                    msg "Logs de acceso antiguos eliminados" "SUCCESS"
                fi
                ;;
            3)
                if command -v php &> /dev/null; then
                    msg "Limpiando cache de PHP OPcache..." "INFO"

                    # Limpiar OPcache via CLI
                    php -r "if (function_exists('opcache_reset')) { opcache_reset(); echo 'OPcache limpiado'; } else { echo 'OPcache no disponible'; }"

                    # Limpiar archivos de cache si existen
                    [ -d "/var/cache/php" ] && sudo rm -rf /var/cache/php/* 2>/dev/null || true

                    msg "Cache de PHP OPcache limpiado" "SUCCESS"
                else
                    msg "PHP no está disponible" "WARNING"
                fi
                ;;
            4)
                msg "Limpiando cache de Redis/Memcached..." "INFO"

                # Redis
                if command -v redis-cli &> /dev/null; then
                    redis-cli flushall 2>/dev/null || true
                    msg "Cache de Redis limpiado" "SUCCESS"
                fi

                # Memcached
                if command -v memcached &> /dev/null && command -v telnet &> /dev/null; then
                    echo 'flush_all' | telnet localhost 11211 2>/dev/null || true
                    msg "Cache de Memcached limpiado" "SUCCESS"
                fi

                if ! command -v redis-cli &> /dev/null && ! command -v memcached &> /dev/null; then
                    msg "Redis/Memcached no están disponibles" "WARNING"
                fi
                ;;
            5)
                msg "Limpiando archivos de sesión PHP antiguos..." "INFO"

                # Limpiar sesiones PHP (por defecto en /var/lib/php/sessions)
                if [ -d "/var/lib/php/sessions" ]; then
                    find /var/lib/php/sessions -name "sess_*" -mtime +1 -delete 2>/dev/null || true
                fi

                # Otros directorios comunes de sesiones
                find /tmp -name "sess_*" -mtime +1 -delete 2>/dev/null || true
                find /var/tmp -name "sess_*" -mtime +1 -delete 2>/dev/null || true

                msg "Archivos de sesión PHP antiguos limpiados" "SUCCESS"
                ;;
            6)
                msg "Limpiando cache de aplicaciones web..." "INFO"

                # WordPress cache (común en /wp-content/cache)
                find /var/www -path "*/wp-content/cache" -type d -exec rm -rf {}/* \; 2>/dev/null || true

                # Drupal cache
                find /var/www -path "*/sites/default/files/css" -type d -exec rm -rf {}/* \; 2>/dev/null || true
                find /var/www -path "*/sites/default/files/js" -type d -exec rm -rf {}/* \; 2>/dev/null || true

                # Joomla cache
                find /var/www -path "*/cache" -name "*.php" -delete 2>/dev/null || true

                msg "Cache de aplicaciones web limpiado" "SUCCESS"
                ;;
            7)
                confirm_dangerous_action "LIMPIEZA COMPLETA DE SERVIDORES WEB"
                if [ $? -eq 0 ]; then
                    msg "Ejecutando limpieza completa de servidores web..." "INFO"

                    # Limpiar todos los caches
                    sudo rm -rf /var/cache/apache2/* 2>/dev/null || true
                    sudo rm -rf /var/cache/nginx/* 2>/dev/null || true
                    sudo rm -rf /usr/local/lsws/cachedata/* 2>/dev/null || true

                    # PHP
                    php -r "if (function_exists('opcache_reset')) { opcache_reset(); }" 2>/dev/null || true
                    sudo rm -rf /var/cache/php/* 2>/dev/null || true

                    # Sesiones PHP
                    find /var/lib/php/sessions -name "sess_*" -mtime +0 -delete 2>/dev/null || true
                    find /tmp -name "sess_*" -delete 2>/dev/null || true

                    # Redis/Memcached
                    redis-cli flushall 2>/dev/null || true

                    # Aplicaciones web
                    find /var/www -path "*/wp-content/cache" -type d -exec rm -rf {}/* \; 2>/dev/null || true
                    find /var/www -path "*/cache" -name "*.php" -delete 2>/dev/null || true

                    msg "Limpieza completa de servidores web finalizada" "SUCCESS"
                fi
                ;;
            8)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# 🧹 SECTION: Limpieza del Sistema
# =============================================================================

clean_system() {
    echo -e "\n${BCyan}🧹 LIMPIEZA DEL SISTEMA${Color_Off}\n"

    local options=(
        "Limpiar Swap (swapoff/swapon)"
        "Limpiar buffer/cache de memoria"
        "Limpiar archivos de core dumps"
        "Limpiar archivos de crash reports"
        "Limpiar archivos de backup antiguos"
        "Limpiar archivos temporales del kernel"
        "Limpieza completa del sistema"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}         LIMPIEZA DEL SISTEMA${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-8): " choice

        case $choice in
            1)
                confirm_dangerous_action "LIMPIAR SWAP"
                if [ $? -eq 0 ]; then
                    msg "Limpiando SWAP..." "INFO"
                    sudo swapoff -a && sudo swapon -a
                    msg "SWAP limpiado y reactivado" "SUCCESS"
                fi
                ;;
            2)
                confirm_dangerous_action "LIMPIAR BUFFER/CACHE DE MEMORIA"
                if [ $? -eq 0 ]; then
                    msg "Limpiando buffer/cache de memoria..." "INFO"
                    echo 1 | sudo tee /proc/sys/vm/drop_caches > /dev/null
                    echo 2 | sudo tee /proc/sys/vm/drop_caches > /dev/null
                    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
                    msg "Buffer/cache de memoria limpiado" "SUCCESS"
                fi
                ;;
            3)
                msg "Limpiando archivos de core dumps..." "INFO"
                find /var/crash -name "core.*" -delete 2>/dev/null || true
                find /tmp -name "core.*" -delete 2>/dev/null || true
                find /var/tmp -name "core.*" -delete 2>/dev/null || true
                find / -maxdepth 2 -name "core" -type f -delete 2>/dev/null || true
                msg "Archivos de core dumps limpiados" "SUCCESS"
                ;;
            4)
                msg "Limpiando archivos de crash reports..." "INFO"
                sudo rm -rf /var/crash/* 2>/dev/null || true
                sudo rm -rf /var/lib/systemd/coredump/* 2>/dev/null || true
                msg "Archivos de crash reports limpiados" "SUCCESS"
                ;;
            5)
                confirm_dangerous_action "LIMPIAR ARCHIVOS DE BACKUP ANTIGUOS"
                if [ $? -eq 0 ]; then
                    msg "Limpiando archivos de backup antiguos..." "INFO"

                    # Buscar y eliminar backups de más de 30 días
                    find /var/backups -name "*.gz" -mtime +30 -delete 2>/dev/null || true
                    find /var/backups -name "*.bak" -mtime +30 -delete 2>/dev/null || true
                    find /home -name "*.backup" -mtime +30 -delete 2>/dev/null || true
                    find / -maxdepth 3 -name "backup.*" -mtime +30 -delete 2>/dev/null || true

                    msg "Archivos de backup antiguos limpiados" "SUCCESS"
                fi
                ;;
            6)
                msg "Limpiando archivos temporales del kernel..." "INFO"
                sudo rm -rf /var/lib/systemd/coredump/* 2>/dev/null || true
                sudo rm -rf /var/spool/abrt/* 2>/dev/null || true
                find /var/log -name "*.old" -delete 2>/dev/null || true
                msg "Archivos temporales del kernel limpiados" "SUCCESS"
                ;;
            7)
                confirm_dangerous_action "LIMPIEZA COMPLETA DEL SISTEMA"
                if [ $? -eq 0 ]; then
                    msg "Ejecutando limpieza completa del sistema..." "INFO"

                    # Limpiar SWAP
                    sudo swapoff -a && sudo swapon -a

                    # Limpiar memoria
                    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

                    # Limpiar dumps y crashes
                    find /var/crash -name "core.*" -delete 2>/dev/null || true
                    find /tmp -name "core.*" -delete 2>/dev/null || true
                    sudo rm -rf /var/crash/* 2>/dev/null || true
                    sudo rm -rf /var/lib/systemd/coredump/* 2>/dev/null || true

                    # Limpiar backups antiguos
                    find /var/backups -name "*.gz" -mtime +30 -delete 2>/dev/null || true
                    find /var/backups -name "*.bak" -mtime +30 -delete 2>/dev/null || true

                    # Limpiar temporales del kernel
                    sudo rm -rf /var/spool/abrt/* 2>/dev/null || true
                    find /var/log -name "*.old" -delete 2>/dev/null || true

                    msg "Limpieza completa del sistema finalizada" "SUCCESS"
                fi
                ;;
            8)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# 📊 SECTION: Análisis de Espacio
# =============================================================================

analyze_space() {
    echo -e "\n${BCyan}📊 ANÁLISIS DE ESPACIO${Color_Off}\n"

    local options=(
        "Mostrar archivos más grandes del sistema"
        "Mostrar directorios que ocupan más espacio"
        "Analizar uso de inodos"
        "Encontrar archivos duplicados"
        "Análisis de logs por tamaño"
        "Reporte completo de espacio"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}         ANÁLISIS DE ESPACIO${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-7): " choice

        case $choice in
            1)
                msg "Buscando archivos más grandes del sistema..." "INFO"
                echo -e "\n${BWhite}📁 TOP 30 ARCHIVOS MÁS GRANDES:${Color_Off}"
                find / -type f -size +100M -exec du -h {} + 2>/dev/null | sort -rh | head -30 | nl
                ;;
            2)
                msg "Analizando directorios que ocupan más espacio..." "INFO"
                echo -e "\n${BWhite}📂 TOP 15 DIRECTORIOS MÁS GRANDES:${Color_Off}"
                du -h --max-depth=2 / 2>/dev/null | sort -rh | head -15 | nl
                ;;
            3)
                msg "Analizando uso de inodos..." "INFO"
                echo -e "\n${BWhite}💾 USO DE INODOS POR FILESYSTEM:${Color_Off}"
                df -i | grep -v "Filesystem"
                echo -e "\n${BWhite}📁 DIRECTORIOS CON MÁS ARCHIVOS:${Color_Off}"
                find / -xdev -type d -exec bash -c 'echo "$(find "$1" -maxdepth 1 | wc -l) $1"' _ {} \; 2>/dev/null | sort -rn | head -10
                ;;
            4)
                msg "Buscando archivos duplicados (esto puede tomar tiempo)..." "INFO"
                echo -e "\n${BWhite}🔄 ARCHIVOS DUPLICADOS:${Color_Off}"
                find /home /var/www -type f -size +1M -exec md5sum {} + 2>/dev/null | sort | uniq -d -w 32 | head -20
                ;;
            5)
                msg "Analizando logs por tamaño..." "INFO"
                echo -e "\n${BWhite}📋 LOGS MÁS GRANDES:${Color_Off}"
                find /var/log -name "*.log" -exec du -h {} + 2>/dev/null | sort -rh | head -20 | nl

                echo -e "\n${BWhite}📊 ESTADÍSTICAS DE LOGS:${Color_Off}"
                local total_logs=$(find /var/log -name "*.log" | wc -l)
                local total_size=$(du -sh /var/log 2>/dev/null | cut -f1)
                echo -e "Total de archivos .log: $total_logs"
                echo -e "Tamaño total de /var/log: $total_size"
                ;;
            6)
                msg "Generando reporte completo de espacio..." "INFO"

                echo -e "\n${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
                echo -e "${BCyan}                    REPORTE COMPLETO DE ESPACIO${Color_Off}"
                echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"

                echo -e "\n${BWhite}💿 USO DE DISCO:${Color_Off}"
                df -h | grep -v "tmpfs"

                echo -e "\n${BWhite}💾 USO DE INODOS:${Color_Off}"
                df -i | grep -v "tmpfs"

                echo -e "\n${BWhite}📁 TOP 10 DIRECTORIOS MÁS GRANDES:${Color_Off}"
                du -h --max-depth=1 / 2>/dev/null | sort -rh | head -10 | nl

                echo -e "\n${BWhite}📄 TOP 10 ARCHIVOS MÁS GRANDES:${Color_Off}"
                find / -type f -size +50M -exec du -h {} + 2>/dev/null | sort -rh | head -10 | nl

                echo -e "\n${BWhite}📋 RESUMEN DE LOGS:${Color_Off}"
                local log_count=$(find /var/log -name "*.log" | wc -l)
                local log_size=$(du -sh /var/log 2>/dev/null | cut -f1)
                echo -e "Archivos .log: $log_count"
                echo -e "Tamaño /var/log: $log_size"

                echo -e "\n${BWhite}🗂️ ARCHIVOS TEMPORALES:${Color_Off}"
                local tmp_size=$(du -sh /tmp 2>/dev/null | cut -f1)
                local var_tmp_size=$(du -sh /var/tmp 2>/dev/null | cut -f1)
                echo -e "Tamaño /tmp: $tmp_size"
                echo -e "Tamaño /var/tmp: $var_tmp_size"

                echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
                ;;
            7)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# 🔐 SECTION: Seguridad y Auditoría
# =============================================================================

security_cleanup() {
    echo -e "\n${BCyan}🔐 SEGURIDAD Y AUDITORÍA${Color_Off}\n"

    local options=(
        "Limpiar logs de autenticación antiguos"
        "Limpiar historial de comandos"
        "Limpiar archivos de configuración backup"
        "Limpiar certificados expirados"
        "Limpiar claves SSH temporales"
        "Auditoría de seguridad básica"
        "Limpieza completa de seguridad"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}        SEGURIDAD Y AUDITORÍA${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-8): " choice

        case $choice in
            1)
                confirm_dangerous_action "LIMPIAR LOGS DE AUTENTICACIÓN ANTIGUOS"
                if [ $? -eq 0 ]; then
                    msg "Limpiando logs de autenticación antiguos..." "INFO"
                    find /var/log -name "auth.log.*" -mtime +30 -delete 2>/dev/null || true
                    find /var/log -name "secure.*" -mtime +30 -delete 2>/dev/null || true
                    find /var/log -name "messages.*" -mtime +30 -delete 2>/dev/null || true
                    msg "Logs de autenticación antiguos limpiados" "SUCCESS"
                fi
                ;;
            2)
                confirm_dangerous_action "LIMPIAR HISTORIAL DE COMANDOS"
                if [ $? -eq 0 ]; then
                    msg "Limpiando historial de comandos..." "INFO"

                    # Limpiar historial de bash para todos los usuarios
                    for user_home in /home/*; do
                        [ -f "$user_home/.bash_history" ] && sudo truncate -s 0 "$user_home/.bash_history"
                        [ -f "$user_home/.zsh_history" ] && sudo truncate -s 0 "$user_home/.zsh_history"
                    done

                    # Root
                    [ -f "/root/.bash_history" ] && sudo truncate -s 0 /root/.bash_history
                    [ -f "/root/.zsh_history" ] && sudo truncate -s 0 /root/.zsh_history

                    msg "Historial de comandos limpiado" "SUCCESS"
                fi
                ;;
            3)
                msg "Limpiando archivos de configuración backup..." "INFO"
                find /etc -name "*.bak" -delete 2>/dev/null || true
                find /etc -name "*.old" -delete 2>/dev/null || true
                find /etc -name "*~" -delete 2>/dev/null || true
                msg "Archivos de configuración backup limpiados" "SUCCESS"
                ;;
            4)
                msg "Buscando y limpiando certificados expirados..." "INFO"

                # Buscar certificados en ubicaciones comunes
                find /etc/ssl/certs -name "*.pem" -exec openssl x509 -checkend 0 -noout -in {} \; -print 2>/dev/null | grep -B1 "Certificate will expire" || true

                msg "Verificación de certificados completada (revisar manualmente los expirados)" "WARNING"
                ;;
            5)
                msg "Limpiando claves SSH temporales..." "INFO"

                # Limpiar archivos known_hosts antiguos
                for user_home in /home/*; do
                    if [ -d "$user_home/.ssh" ]; then
                        find "$user_home/.ssh" -name "known_hosts.old" -delete 2>/dev/null || true
                        find "$user_home/.ssh" -name "*.tmp" -delete 2>/dev/null || true
                    fi
                done

                # Root SSH
                if [ -d "/root/.ssh" ]; then
                    find /root/.ssh -name "known_hosts.old" -delete 2>/dev/null || true
                    find /root/.ssh -name "*.tmp" -delete 2>/dev/null || true
                fi

                msg "Claves SSH temporales limpiadas" "SUCCESS"
                ;;
            6)
                msg "Ejecutando auditoría de seguridad básica..." "INFO"

                echo -e "\n${BWhite}🔍 AUDITORÍA DE SEGURIDAD:${Color_Off}"

                # Verificar intentos de login fallidos
                echo -e "\n${BYellow}Intentos de login fallidos recientes:${Color_Off}"
                grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "No se encontraron intentos fallidos recientes"

                # Verificar conexiones SSH activas
                echo -e "\n${BYellow}Conexiones SSH activas:${Color_Off}"
                who | grep pts || echo "No hay conexiones SSH activas"

                # Verificar procesos sospechosos
                echo -e "\n${BYellow}Procesos con más uso de CPU:${Color_Off}"
                ps aux --sort=-%cpu | head -5

                # Verificar conexiones de red
                echo -e "\n${BYellow}Conexiones de red establecidas:${Color_Off}"
                netstat -an | grep ESTABLISHED | wc -l | xargs echo "Conexiones establecidas:"

                msg "Auditoría de seguridad completada" "SUCCESS"
                ;;
            7)
                confirm_dangerous_action "LIMPIEZA COMPLETA DE SEGURIDAD"
                if [ $? -eq 0 ]; then
                    msg "Ejecutando limpieza completa de seguridad..." "INFO"

                    # Limpiar logs antiguos
                    find /var/log -name "auth.log.*" -mtime +30 -delete 2>/dev/null || true
                    find /var/log -name "secure.*" -mtime +30 -delete 2>/dev/null || true

                    # Limpiar configuraciones backup
                    find /etc -name "*.bak" -delete 2>/dev/null || true
                    find /etc -name "*.old" -delete 2>/dev/null || true
                    find /etc -name "*~" -delete 2>/dev/null || true

                    # Limpiar SSH temporales
                    for user_home in /home/*; do
                        if [ -d "$user_home/.ssh" ]; then
                            find "$user_home/.ssh" -name "known_hosts.old" -delete 2>/dev/null || true
                            find "$user_home/.ssh" -name "*.tmp" -delete 2>/dev/null || true
                        fi
                    done

                    msg "Limpieza completa de seguridad finalizada" "SUCCESS"
                fi
                ;;
            8)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# ⚙️ SECTION: Servicios Específicos
# =============================================================================

clean_specific_services() {
    echo -e "\n${BCyan}⚙️ SERVICIOS ESPECÍFICOS${Color_Off}\n"

    local options=(
        "Limpiar Docker containers y imágenes"
        "Limpiar cache de CyberPanel/OpenLiteSpeed"
        "Limpiar logs de cPanel/Plesk"
        "Limpiar cache de WordPress"
        "Limpiar logs de FTP/SFTP"
        "Limpiar servicios de correo"
        "Limpieza completa de servicios"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}        SERVICIOS ESPECÍFICOS${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-8): " choice

        case $choice in
            1)
                if command -v docker &> /dev/null; then
                    confirm_dangerous_action "LIMPIAR DOCKER CONTAINERS E IMÁGENES"
                    if [ $? -eq 0 ]; then
                        msg "Limpiando Docker..." "INFO"

                        # Parar y eliminar containers parados
                        docker container prune -f 2>/dev/null || true

                        # Eliminar imágenes sin usar
                        docker image prune -a -f 2>/dev/null || true

                        # Eliminar volúmenes sin usar
                        docker volume prune -f 2>/dev/null || true

                        # Eliminar networks sin usar
                        docker network prune -f 2>/dev/null || true

                        # Limpiar sistema completo
                        docker system prune -a -f --volumes 2>/dev/null || true

                        # Limpiar logs de containers
                        sudo find /var/lib/docker/containers/ -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true

                        msg "Docker limpiado completamente" "SUCCESS"
                    fi
                else
                    msg "Docker no está instalado en este sistema" "WARNING"
                fi
                ;;
            2)
                msg "Limpiando cache de CyberPanel/OpenLiteSpeed..." "INFO"

                # LiteSpeed Cache
                if [ -d "/usr/local/lsws/cachedata" ]; then
                    sudo rm -rf /usr/local/lsws/cachedata/* 2>/dev/null || true
                    msg "Cache de LiteSpeed limpiado" "SUCCESS"
                fi

                # CyberPanel logs y cache
                if [ -f "/home/cyberpanel/error-logs.txt" ]; then
                    sudo truncate -s 0 /home/cyberpanel/error-logs.txt
                fi

                if [ -d "/home/cyberpanel/logs" ]; then
                    sudo find /home/cyberpanel/logs -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
                fi

                msg "Cache de CyberPanel/OpenLiteSpeed limpiado" "SUCCESS"
                ;;
            3)
                msg "Limpiando logs de cPanel/Plesk..." "INFO"

                # cPanel logs
                if [ -d "/usr/local/cpanel/logs" ]; then
                    sudo find /usr/local/cpanel/logs -name "*.log" -mtime +7 -exec truncate -s 0 {} \; 2>/dev/null || true
                    msg "Logs de cPanel limpiados" "SUCCESS"
                fi

                # Plesk logs
                if [ -d "/var/log/plesk" ]; then
                    sudo find /var/log/plesk -name "*.log" -mtime +7 -exec truncate -s 0 {} \; 2>/dev/null || true
                    msg "Logs de Plesk limpiados" "SUCCESS"
                fi

                if [ ! -d "/usr/local/cpanel/logs" ] && [ ! -d "/var/log/plesk" ]; then
                    msg "cPanel/Plesk no encontrados en este sistema" "WARNING"
                fi
                ;;
            4)
                msg "Limpiando cache de WordPress..." "INFO"

                # Función para limpiar WordPress
                clean_wordpress_cache() {
                    local wp_root="$1"
                    msg "Encontrado WordPress en: $wp_root" "INFO"

                    # Limpiar cache de plugins comunes
                    rm -rf "$wp_root/wp-content/cache"/* 2>/dev/null || true
                    rm -rf "$wp_root/wp-content/uploads/cache"/* 2>/dev/null || true

                    # W3 Total Cache
                    rm -rf "$wp_root/wp-content/cache/config"/* 2>/dev/null || true
                    rm -rf "$wp_root/wp-content/cache/minify"/* 2>/dev/null || true
                    rm -rf "$wp_root/wp-content/cache/page_enhanced"/* 2>/dev/null || true

                    # WP Rocket
                    rm -rf "$wp_root/wp-content/cache/wp-rocket"/* 2>/dev/null || true

                    # WP Super Cache
                    rm -rf "$wp_root/wp-content/cache/supercache"/* 2>/dev/null || true

                    # LiteSpeed Cache
                    rm -rf "$wp_root/wp-content/cache/litespeed"/* 2>/dev/null || true
                    rm -rf "$wp_root/wp-content/cache/ls_cache"/* 2>/dev/null || true
                    rm -rf "$wp_root/wp-content/litespeed"/* 2>/dev/null || true

                }

                # Buscar instalaciones de WordPress en diferentes ubicaciones

                # 1. Apache tradicional (/var/www)
                find /var/www -name "wp-config.php" -type f -maxdepth 4 2>/dev/null | while read wp_config; do
                    clean_wordpress_cache "$(dirname "$wp_config")"
                done

                # 2. CyberPanel con OpenLiteSpeed (/home/dominio.com)
                find /home -maxdepth 2 -name "wp-config.php" -type f 2>/dev/null | while read wp_config; do
                    clean_wordpress_cache "$(dirname "$wp_config")"
                done

                # 3. cPanel (/home/usuario/public_html)
                find /home/*/public_html -name "wp-config.php" -type f -maxdepth 2 2>/dev/null | while read wp_config; do
                    clean_wordpress_cache "$(dirname "$wp_config")"
                done

                # 4. cPanel subdominios (/home/usuario/dominio.com)
                find /home -maxdepth 3 -path "*/public_html" -prune -o -name "wp-config.php" -type f -print 2>/dev/null | while read wp_config; do
                    clean_wordpress_cache "$(dirname "$wp_config")"
                done

                # 5. Plesk (/var/www/vhosts/dominio.com/httpdocs)
                find /var/www/vhosts -name "wp-config.php" -type f -maxdepth 4 2>/dev/null | while read wp_config; do
                    clean_wordpress_cache "$(dirname "$wp_config")"
                done

                msg "Cache de WordPress limpiado" "SUCCESS"
                ;;
            5)
                msg "Limpiando logs de FTP/SFTP..." "INFO"

                # ProFTPD
                [ -f "/var/log/proftpd/proftpd.log" ] && sudo truncate -s 0 /var/log/proftpd/proftpd.log

                # vsftpd
                [ -f "/var/log/vsftpd.log" ] && sudo truncate -s 0 /var/log/vsftpd.log

                # Pure-FTPd
                [ -f "/var/log/pure-ftpd/pure-ftpd.log" ] && sudo truncate -s 0 /var/log/pure-ftpd/pure-ftpd.log

                # SFTP logs (generalmente en auth.log, pero podemos limpiar específicos)
                grep -l "sftp" /var/log/*.log 2>/dev/null | xargs sudo truncate -s 0 2>/dev/null || true

                msg "Logs de FTP/SFTP limpiados" "SUCCESS"
                ;;
            6)
                msg "Limpiando servicios de correo..." "INFO"

                # Postfix
                [ -f "/var/log/mail.log" ] && sudo truncate -s 0 /var/log/mail.log
                [ -f "/var/log/mail.err" ] && sudo truncate -s 0 /var/log/mail.err
                [ -f "/var/log/mail.warn" ] && sudo truncate -s 0 /var/log/mail.warn

                # Dovecot
                [ -f "/var/log/dovecot.log" ] && sudo truncate -s 0 /var/log/dovecot.log

                # Exim
                [ -f "/var/log/exim4/mainlog" ] && sudo truncate -s 0 /var/log/exim4/mainlog
                [ -f "/var/log/exim4/rejectlog" ] && sudo truncate -s 0 /var/log/exim4/rejectlog

                # Limpiar queue de correos antiguos
                if command -v postqueue &> /dev/null; then
                    sudo postsuper -d ALL 2>/dev/null || true
                fi

                msg "Servicios de correo limpiados" "SUCCESS"
                ;;
            7)
                confirm_dangerous_action "LIMPIEZA COMPLETA DE SERVICIOS"
                if [ $? -eq 0 ]; then
                    msg "Ejecutando limpieza completa de servicios..." "INFO"

                    # Docker
                    if command -v docker &> /dev/null; then
                        docker system prune -a -f --volumes 2>/dev/null || true
                        sudo find /var/lib/docker/containers/ -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
                    fi

                    # LiteSpeed/CyberPanel
                    sudo rm -rf /usr/local/lsws/cachedata/* 2>/dev/null || true
                    [ -f "/home/cyberpanel/error-logs.txt" ] && sudo truncate -s 0 /home/cyberpanel/error-logs.txt

                    # WordPress - Función para limpiar cache
                    clean_wp_cache_complete() {
                        local wp_root="$1"
                        rm -rf "$wp_root/wp-content/cache"/* 2>/dev/null || true
                        rm -rf "$wp_root/wp-content/cache/wp-rocket"/* 2>/dev/null || true
                        rm -rf "$wp_root/wp-content/cache/litespeed"/* 2>/dev/null || true
                        rm -rf "$wp_root/wp-content/cache/ls_cache"/* 2>/dev/null || true
                        rm -rf "$wp_root/wp-content/litespeed"/* 2>/dev/null || true
                    }

                    # Buscar WordPress en todas las ubicaciones comunes
                    find /var/www -name "wp-config.php" -type f -maxdepth 4 2>/dev/null | while read wp_config; do
                        clean_wp_cache_complete "$(dirname "$wp_config")"
                    done
                    find /home -maxdepth 2 -name "wp-config.php" -type f 2>/dev/null | while read wp_config; do
                        clean_wp_cache_complete "$(dirname "$wp_config")"
                    done
                    find /home/*/public_html -name "wp-config.php" -type f -maxdepth 2 2>/dev/null | while read wp_config; do
                        clean_wp_cache_complete "$(dirname "$wp_config")"
                    done
                    find /var/www/vhosts -name "wp-config.php" -type f -maxdepth 4 2>/dev/null | while read wp_config; do
                        clean_wp_cache_complete "$(dirname "$wp_config")"
                    done

                    # Correo
                    [ -f "/var/log/mail.log" ] && sudo truncate -s 0 /var/log/mail.log
                    command -v postsuper &> /dev/null && sudo postsuper -d ALL 2>/dev/null || true

                    # FTP
                    [ -f "/var/log/proftpd/proftpd.log" ] && sudo truncate -s 0 /var/log/proftpd/proftpd.log
                    [ -f "/var/log/vsftpd.log" ] && sudo truncate -s 0 /var/log/vsftpd.log

                    msg "Limpieza completa de servicios finalizada" "SUCCESS"
                fi
                ;;
            8)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# 🛠️ SECTION: Mantenimiento Avanzado
# =============================================================================

advanced_maintenance() {
    echo -e "\n${BCyan}🛠️ MANTENIMIENTO AVANZADO${Color_Off}\n"

    local options=(
        "Defragmentar bases de datos"
        "Optimizar configuraciones automáticamente"
        "Verificar integridad de archivos"
        "Limpiar registros de systemd antiguos"
        "Sincronizar y limpiar repositorios"
        "Reparar permisos de archivos"
        "Mantenimiento completo avanzado"
        "Volver al menú principal"
    )

    while true; do
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        echo -e "${BCyan}       MANTENIMIENTO AVANZADO${Color_Off}"
        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"

        for i in "${!options[@]}"; do
            echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
        done

        echo -e "${BCyan}═══════════════════════════════════════${Color_Off}"
        read -p "Selecciona una opción (1-8): " choice

        case $choice in
            1)
                confirm_dangerous_action "DEFRAGMENTAR BASES DE DATOS"
                if [ $? -eq 0 ]; then
                    msg "Defragmentando bases de datos..." "INFO"

                    # MySQL/MariaDB
                    if command -v mysql &> /dev/null; then
                        msg "Defragmentando MySQL/MariaDB..." "INFO"
                        mysql -u root -p -e "SHOW DATABASES;" 2>/dev/null | grep -v "Database\|information_schema\|performance_schema\|mysql\|sys" | while read db; do
                            if [ -n "$db" ]; then
                                msg "Defragmentando base de datos: $db" "INFO"
                                mysqlcheck -u root -p --optimize --all-databases 2>/dev/null || true
                            fi
                        done
                    fi

                    # SQLite
                    find /var -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null | while read db; do
                        if [ -w "$db" ]; then
                            sqlite3 "$db" "VACUUM;" 2>/dev/null || true
                            msg "Defragmentada: $(basename "$db")" "DEBUG"
                        fi
                    done

                    msg "Defragmentación de bases de datos completada" "SUCCESS"
                fi
                ;;
            2)
                msg "Optimizando configuraciones automáticamente..." "INFO"

                # Optimizar sysctl
                if [ -f "/etc/sysctl.conf" ]; then
                    sudo sysctl -p /etc/sysctl.conf 2>/dev/null || true
                fi

                # Optimizar servicios
                sudo systemctl daemon-reload 2>/dev/null || true

                # Actualizar locate database
                if command -v updatedb &> /dev/null; then
                    sudo updatedb 2>/dev/null || true
                fi

                # Optimizar man pages
                if command -v mandb &> /dev/null; then
                    sudo mandb -q 2>/dev/null || true
                fi

                msg "Configuraciones optimizadas" "SUCCESS"
                ;;
            3)
                confirm_dangerous_action "VERIFICAR INTEGRIDAD DE ARCHIVOS"
                if [ $? -eq 0 ]; then
                    msg "Verificando integridad de archivos del sistema..." "INFO"

                    # Verificar filesystem
                    msg "Verificando filesystem (solo lectura)..." "INFO"
                    sudo fsck -n / 2>/dev/null || true

                    # Verificar archivos importantes
                    if command -v debsums &> /dev/null; then
                        msg "Verificando checksums de paquetes..." "INFO"
                        debsums -s 2>/dev/null || true
                    fi

                    msg "Verificación de integridad completada" "SUCCESS"
                fi
                ;;
            4)
                msg "Limpiando registros de systemd antiguos..." "INFO"

                # Limpiar journalctl manteniendo últimos 30 días
                sudo journalctl --rotate
                sudo journalctl --vacuum-time=30d
                sudo journalctl --vacuum-size=100M

                # Limpiar logs de systemd
                sudo find /var/log/journal -name "*.journal" -mtime +30 -delete 2>/dev/null || true

                msg "Registros de systemd antiguos limpiados" "SUCCESS"
                ;;
            5)
                msg "Sincronizando y limpiando repositorios..." "INFO"

                # APT
                if command -v apt &> /dev/null; then
                    sudo apt update 2>/dev/null || true
                    sudo apt clean
                    sudo apt autoclean
                fi

                # YUM/DNF
                if command -v yum &> /dev/null; then
                    sudo yum clean all 2>/dev/null || true
                    sudo yum makecache fast 2>/dev/null || true
                elif command -v dnf &> /dev/null; then
                    sudo dnf clean all 2>/dev/null || true
                    sudo dnf makecache 2>/dev/null || true
                fi

                msg "Repositorios sincronizados y limpiados" "SUCCESS"
                ;;
            6)
                confirm_dangerous_action "REPARAR PERMISOS DE ARCHIVOS"
                if [ $? -eq 0 ]; then
                    msg "Reparando permisos de archivos importantes..." "INFO"

                    # Permisos básicos del sistema
                    sudo chmod 755 /usr/bin/* 2>/dev/null || true
                    sudo chmod 644 /etc/passwd /etc/group 2>/dev/null || true
                    sudo chmod 600 /etc/shadow /etc/gshadow 2>/dev/null || true
                    sudo chmod 755 /etc/init.d/* 2>/dev/null || true

                    msg "Permisos de archivos reparados" "SUCCESS"
                fi
                ;;
            7)
                confirm_dangerous_action "MANTENIMIENTO COMPLETO AVANZADO"
                if [ $? -eq 0 ]; then
                    msg "Ejecutando mantenimiento completo avanzado..." "INFO"

                    # Ejecutar todas las funciones de mantenimiento avanzado
                    msg "Defragmentando bases de datos..." "INFO"
                    if command -v mysql &> /dev/null; then
                        mysqlcheck -u root -p --optimize --all-databases 2>/dev/null || true
                    fi
                    find /var -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null | while read db; do
                        if [ -w "$db" ]; then
                            sqlite3 "$db" "VACUUM;" 2>/dev/null || true
                        fi
                    done

                    # Optimizar configuraciones
                    sudo sysctl -p /etc/sysctl.conf 2>/dev/null || true
                    sudo systemctl daemon-reload 2>/dev/null || true
                    command -v updatedb &> /dev/null && sudo updatedb 2>/dev/null || true

                    # Limpiar systemd
                    sudo journalctl --rotate
                    sudo journalctl --vacuum-time=30d

                    # Sincronizar repositorios
                    if command -v apt &> /dev/null; then
                        sudo apt update 2>/dev/null || true
                        sudo apt clean
                    fi

                    msg "Mantenimiento completo avanzado finalizado" "SUCCESS"
                fi
                ;;
            8)
                return 0
                ;;
            *)
                msg "Opción no válida" "ERROR"
                ;;
        esac
        pause
        clear
    done
}

# =============================================================================
# 📋 SECTION: Menú Principal
# =============================================================================

show_main_menu() {
    clear
    show_system_info

    echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BCyan}                    LIMPIADOR COMPLETO DEL SERVIDOR${Color_Off}"
    echo -e "${BCyan}                           Versión 2.0${Color_Off}"
    echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"

    local options=(
        "🗑️  Limpieza de Archivos Temporales"
        "📦 Gestión de Paquetes"
        "📋 Limpieza y Rotación de Logs"
        "💾 Limpieza de Bases de Datos"
        "🌐 Limpieza de Servidores Web"
        "🧹 Limpieza del Sistema"
        "📊 Análisis de Espacio"
        "🔐 Seguridad y Auditoría"
        "⚙️  Servicios Específicos"
        "🛠️  Mantenimiento Avanzado"
        "🚀 Limpieza Completa Automática"
        "❌ Salir"
    )

    for i in "${!options[@]}"; do
        echo -e "${BWhite}$((i+1)).${Color_Off} ${options[i]}"
    done

    echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
}

# Función para limpieza completa automática
complete_cleanup() {
    echo -e "\n${BRed}⚠️  ADVERTENCIA: LIMPIEZA COMPLETA AUTOMÁTICA${Color_Off}"
    echo -e "${BYellow}Esta operación ejecutará TODAS las limpiezas del sistema.${Color_Off}"
    echo -e "${BYellow}Puede tomar varios minutos y afectar el rendimiento temporalmente.${Color_Off}\n"

    read -p "¿Estás seguro de continuar? (escriba 'SI' para confirmar): " confirmation

    if [ "$confirmation" != "SI" ]; then
        msg "Operación cancelada por el usuario" "WARNING"
        return 1
    fi

    msg "Iniciando limpieza completa automática del servidor..." "INFO"
    
    local start_time=$(date +%s)
    INITIAL_SIZE=$(df / | awk 'NR==2 {print $3}')

    # 1. Limpieza de temporales
    msg "Paso 1/10: Limpiando archivos temporales..." "INFO"
    sudo find /tmp -type f -atime +1 -delete 2>/dev/null || true
    sudo find /var/tmp -type f -atime +1 -delete 2>/dev/null || true
    for user_home in /home/*; do
        sudo rm -rf "$user_home/.cache"/* 2>/dev/null || true
        sudo rm -rf "$user_home/.thumbnails"/* 2>/dev/null || true
    done

    # 2. Gestión de paquetes
    msg "Paso 2/10: Limpiando paquetes..." "INFO"
    if command -v apt &> /dev/null; then
        sudo apt clean && sudo apt autoclean && sudo apt autoremove -y
    fi
    if command -v yum &> /dev/null; then
        sudo yum clean all && sudo yum autoremove -y
    elif command -v dnf &> /dev/null; then
        sudo dnf clean all && sudo dnf autoremove -y
    fi

    # 3. Logs
    msg "Paso 3/10: Limpiando logs..." "INFO"
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=7d
    sudo find /var/log -name "*.log" -mtime +7 -exec truncate -s 0 {} \;

    # 4. Bases de datos
    msg "Paso 4/10: Optimizando bases de datos..." "INFO"
    find /var -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null | while read db; do
        if [ -w "$db" ]; then
            sqlite3 "$db" "VACUUM;" 2>/dev/null || true
        fi
    done

    # 5. Servidores web
    msg "Paso 5/10: Limpiando servidores web..." "INFO"
    sudo rm -rf /var/cache/apache2/* 2>/dev/null || true
    sudo rm -rf /var/cache/nginx/* 2>/dev/null || true
    sudo rm -rf /usr/local/lsws/cachedata/* 2>/dev/null || true
    find /var/lib/php/sessions -name "sess_*" -mtime +1 -delete 2>/dev/null || true

    # 6. Sistema
    msg "Paso 6/10: Limpiando sistema..." "INFO"
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    find /var/crash -name "core.*" -delete 2>/dev/null || true
    sudo rm -rf /var/crash/* 2>/dev/null || true

    # 7. Docker (si está disponible)
    msg "Paso 7/10: Limpiando Docker..." "INFO"
    if command -v docker &> /dev/null; then
        docker system prune -a -f --volumes 2>/dev/null || true
    fi

    # 8. WordPress cache
    msg "Paso 8/10: Limpiando cache de WordPress..." "INFO"
    find /var/www -path "*/wp-content/cache" -type d -exec rm -rf {}/* \; 2>/dev/null || true
    find /home -path "*/wp-content/cache" -type d -exec rm -rf {}/* \; 2>/dev/null || true

    # 9. Correo
    msg "Paso 9/10: Limpiando servicios de correo..." "INFO"
    [ -f "/var/log/mail.log" ] && sudo truncate -s 0 /var/log/mail.log
    command -v postsuper &> /dev/null && sudo postsuper -d ALL 2>/dev/null || true

    # 10. Mantenimiento final
    msg "Paso 10/10: Mantenimiento final..." "INFO"
    sudo systemctl daemon-reload 2>/dev/null || true
    command -v updatedb &> /dev/null && sudo updatedb 2>/dev/null || true

    FINAL_SIZE=$(df / | awk 'NR==2 {print $3}')
    local freed_space=$((INITIAL_SIZE - FINAL_SIZE))
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo -e "\n${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BCyan}                    LIMPIEZA COMPLETA FINALIZADA${Color_Off}"
    echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BGreen}✅ Espacio liberado: $(bytes_to_human $((freed_space * 1024)))${Color_Off}"
    echo -e "${BGreen}⏱️  Tiempo transcurrido: ${duration} segundos${Color_Off}"
    echo -e "${BGreen}🎉 Limpieza completa exitosa!${Color_Off}"
    echo -e "${BCyan}═══════════════════════════════════════════════════════════════${Color_Off}"
}

# =============================================================================
# 🚀 SECTION: Función Principal
# =============================================================================

main() {
    # Verificar permisos de sudo al inicio
    check_sudo

    while true; do
        show_main_menu
        read -p "Selecciona una opción (1-12): " choice

        case $choice in
            1) clean_temp_files ;;
            2) clean_packages ;;
            3) clean_logs ;;
            4) clean_databases ;;
            5) clean_web_servers ;;
            6) clean_system ;;
            7) analyze_space ;;
            8) security_cleanup ;;
            9) clean_specific_services ;;
            10) advanced_maintenance ;;
            11) complete_cleanup ;;
            12)
                msg "¡Gracias por usar el Limpiador Completo del Servidor!" "SUCCESS"
                exit 0
                ;;
            *)
                msg "Opción no válida. Por favor selecciona una opción del 1 al 12." "ERROR"
                pause
                ;;
        esac
    done
}

# Ejecutar función principal
main "$@"
