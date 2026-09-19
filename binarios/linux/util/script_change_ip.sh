#!/bin/bash

# =============================================================================
# 📋 SCRIPT: Cambio de IP Automático para Ubuntu Server
# 👨‍💻 Creado por: César Auris
# 📅 Versión: 2.0
# 🎯 Descripción: Script para cambiar configuración IP en Ubuntu Server con Netplan
# =============================================================================

# Fecha y hora actual en formato: YYYY-MM-DD_HH:MM:SS (hora local)
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")
# Fecha y hora actual en Perú (UTC -5)
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d_%H:%M:%S")
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

# Colores Regulares
Color_Off='\033[0m'       # Reset de color
Black='\033[0;30m'        # Negro
Red='\033[0;31m'          # Rojo
Green='\033[0;32m'        # Verde
Yellow='\033[0;33m'       # Amarillo
Blue='\033[0;34m'         # Azul
Purple='\033[0;35m'       # Púrpura
Cyan='\033[0;36m'         # Cian
White='\033[0;37m'        # Blanco
Gray='\033[0;90m'         # Gris

# Colores en Negrita
BBlack='\033[1;30m'       # Negro (negrita)
BRed='\033[1;31m'         # Rojo (negrita)
BGreen='\033[1;32m'       # Verde (negrita)
BYellow='\033[1;33m'      # Amarillo (negrita)
BBlue='\033[1;34m'        # Azul (negrita)
BPurple='\033[1;35m'      # Púrpura (negrita)
BCyan='\033[1;36m'        # Cian (negrita)
BWhite='\033[1;37m'       # Blanco (negrita)
BGray='\033[1;90m'        # Gris (negrita)

# =============================================================================
# 🎨 Función: show_banner
# ------------------------------------------------------------------------------
# ✅ Descripción: Muestra un banner bonito con información del script
# ==============================================================================
show_banner() {
  clear
  echo -e "${BCyan}"
  echo -e "╔══════════════════════════════════════════════════════════════════════════════"
  echo -e "║                                                                              "
  echo -e "║  SCRIPT DE CAMBIO DE IP AUTOMATICO PARA UBUNTU SERVER                        "
  echo -e "║                                                                              "
  echo -e "║  Creado por: ${BWhite}César Auris${BCyan}                                    "
  echo -e "║  Versión: ${BWhite}2.0${BCyan}                                               "
  echo -e "║  Sistema: ${BWhite}Ubuntu Server con Netplan${BCyan}                         "
  echo -e "║  Compatible: ${BWhite}VMware NAT, Bridged, IP Estática${BCyan}               "
  echo -e "║                                                                              "
  echo -e "║  Funcionalidades:                                                            "
  echo -e "║     - Configuración IP estática predefinida                                  "
  echo -e "║     - Configuración DHCP para VMware NAT                                     "
  echo -e "║     - Configuración personalizada                                            "
  echo -e "║     - Verificación automática de conectividad                                "
  echo -e "║     - Copia de seguridad automática                                          "
  echo -e "║                                                                              "
  echo -e "╚══════════════════════════════════════════════════════════════════════════════"
  echo -e "${Color_Off}"
  echo ""
}

# =============================================================================
# 📝 Función: msg
# ------------------------------------------------------------------------------
# ✅ Descripción: Imprime un mensaje con formato estándar, incluyendo timestamp
# 🔧 Parámetros: $1 - Mensaje, $2 - Tipo (INFO|WARNING|ERROR|SUCCESS|DEBUG)
# 💡 Uso: msg "Inicio del proceso" "INFO"
# ==============================================================================
msg() {
  local message="$1"
  local level="${2:-INFO}"
  local timestamp
  timestamp=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S")

  case "$level" in
    INFO)
        echo -e "${BBlue}${timestamp} - [INFO]${Color_Off} ${message}"
        ;;
    WARNING)
        echo -e "${BYellow}${timestamp} - [WARNING]${Color_Off} ${message}"
        ;;
    DEBUG)
        echo -e "${BPurple}${timestamp} - [DEBUG]${Color_Off} ${message}"
        ;;
    ERROR)
        echo -e "${BRed}${timestamp} - [ERROR]${Color_Off} ${message}"
        ;;
    SUCCESS)
        echo -e "${BGreen}${timestamp} - [SUCCESS]${Color_Off} ${message}"
        ;;
    *)
        echo -e "${BGray}[OTHER]${Color_Off} ${message}"
        ;;
  esac
}


# =============================================================================
# ⏸️ Función: pause_continue
# ------------------------------------------------------------------------------
# ✅ Descripción: Pausa la ejecución mostrando un mensaje y espera [ENTER]
# ==============================================================================
pause_continue() {
  if [ -n "$1" ]; then
    local mensaje="$1. Presiona [ENTER] para continuar..."
  else
    local mensaje="Comando ejecutado. Presiona [ENTER] para continuar..."
  fi

  echo -en "${Gray}"
  read -p "$mensaje"
  echo -en "${Color_Off}"
}

# =============================================================================
# 🚀 INICIO DEL SCRIPT
# =============================================================================

# Mostrar banner después de definir colores
show_banner
msg "Iniciando script de cambio de IP automático" "INFO"
msg "Usuario: $MY_INFO" "DEBUG"
msg "Directorio: $CURRENT_DIR" "DEBUG"

# Detectar automáticamente el archivo de netplan
NETPLAN_FILE=""
for file in /etc/netplan/*.yaml; do
    if [ -f "$file" ]; then
        NETPLAN_FILE="$file"
        break
    fi
done

if [ -z "$NETPLAN_FILE" ]; then
    msg "No se encontró ningún archivo de configuración Netplan en /etc/netplan/" "ERROR"
    exit 1
fi

BACKUP_FILE="${NETPLAN_FILE}.bak_$(date +%Y%m%d%H%M%S)"
INTERFACE="ens33"

msg "Mostrando información de red actual..." "INFO"
echo -e "${BCyan}-----------------------------------------------${Color_Off}"
echo -e "${BCyan}Información de red actual:${Color_Off}"
ip a && ip route
echo ""
msg "Iniciando el proceso de cambio de IP..." "INFO"
echo -e "${BCyan}-----------------------------------------------${Color_Off}"
echo -e "${BCyan}Interfaces disponibles (excluyendo loopback):${Color_Off}"
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
echo "$INTERFACES"
echo ""

echo -e "${BCyan}-----------------------------------------------${Color_Off}"
echo -e "${BCyan}Puerta de enlace actual:${Color_Off}"
CURRENT_GW=$(ip route | grep 'default' | awk '{print $3}')
echo "$CURRENT_GW"
echo ""

# 1. Verificar que el script se ejecute con root
if [ "$(id -u)" -ne 0 ]; then
  msg "Este script debe ejecutarse con sudo. Ejemplo: sudo ./script_change_ip.sh" "ERROR"
  exit 1
fi
# 1.5. Verificar que la interfaz existe
if ! ip link show ${INTERFACE} > /dev/null 2>&1; then
  msg "La interfaz ens33 no se encuentra. Verifique sus interfaces de red." "ERROR"
  exit 1
fi


# 2. Hacer una copia de seguridad del archivo Netplan actual
msg "Haciendo copia de seguridad de ${NETPLAN_FILE} a ${BACKUP_FILE}..." "INFO"
cp "${NETPLAN_FILE}" "${BACKUP_FILE}"
if [ $? -ne 0 ]; then
  msg "No se pudo hacer la copia de seguridad. Abortando." "ERROR"
  exit 1
fi
msg "Copia de seguridad creada en ${BACKUP_FILE}." "SUCCESS"

# --- Variables para las configuraciones predefinidas ---
# Configuración 1: 192.168.0.60 (Red anterior)
IP_OPT1="192.168.0.60/24"
GW_OPT1="192.168.0.1"
DNS_OPT1_1="8.8.8.8"
DNS_OPT1_2="8.8.4.4"

# Configuración 2: 192.168.43.60 (Red actual Wi-Fi)
IP_OPT2="192.168.43.60/24"
GW_OPT2="192.168.43.1"
DNS_OPT2_1="8.8.8.8"
DNS_OPT2_2="8.8.4.4"

# --- Menú de Selección ---
CHOICE=""
while [[ ! "$CHOICE" =~ ^[1-4]$ ]]; do
  echo -e "\n${BCyan}╔══════════════════════════════════════════════════════════════════════════════╗${Color_Off}"
  echo -e "${BCyan}║                    SELECCIONE LA CONFIGURACION IP                        ║${Color_Off}"
  echo -e "${BCyan}╚══════════════════════════════════════════════════════════════════════════════╝${Color_Off}"
  echo ""
  echo -e "${BGreen}1)${Color_Off} ${BWhite}IP: ${IP_OPT1}${Color_Off} ${Gray}(Red 192.168.0.x)${Color_Off}"
  echo -e "${BGreen}2)${Color_Off} ${BWhite}IP: ${IP_OPT2}${Color_Off} ${Gray}(Red 192.168.43.x)${Color_Off}"
  echo -e "${BGreen}3)${Color_Off} ${BWhite}DHCP (VMware NAT - IP automática)${Color_Off} ${Gray}(Recomendado para VMware)${Color_Off}"
  echo -e "${BGreen}4)${Color_Off} ${BWhite}Configuración personalizada${Color_Off} ${Gray}(IP, Gateway, DNS manual)${Color_Off}"
  echo ""
  echo -n -e "${BYellow}Ingrese su elección (1, 2, 3 o 4): ${Color_Off}"
  read CHOICE

  case $CHOICE in
    1)
      NEW_IP="$IP_OPT1"
      GATEWAY="$GW_OPT1"
      DNS1="$DNS_OPT1_1"
      DNS2="$DNS_OPT1_2"
      CONFIG_TYPE="static"
      msg "Ha seleccionado: ${NEW_IP}" "SUCCESS"
      ;;
    2)
      NEW_IP="$IP_OPT2"
      GATEWAY="$GW_OPT2"
      DNS1="$DNS_OPT2_1"
      DNS2="$DNS_OPT2_2"
      CONFIG_TYPE="static"
      msg "Ha seleccionado: ${NEW_IP}" "SUCCESS"
      ;;
    3)
      CONFIG_TYPE="dhcp"
      msg "Ha seleccionado: DHCP (VMware NAT - IP automática)" "SUCCESS"
      msg "Esta configuración es ideal para VMware en modo NAT" "INFO"
      msg "No se requiere configuración adicional - VMware manejará todo automáticamente" "INFO"
      ;;
    4)
      echo -e "\n${BCyan}╔══════════════════════════════════════════════════════════════════════════════╗${Color_Off}"
      echo -e "${BCyan}║                    CONFIGURACION PERSONALIZADA                          ║${Color_Off}"
      echo -e "${BCyan}╚══════════════════════════════════════════════════════════════════════════════╝${Color_Off}"
      CONFIG_TYPE="static"

      # Solicitar IP
      while true; do
        echo -n -e "${BYellow}Ingrese la IP con máscara (ej: 192.168.1.100/24): ${Color_Off}"
        read NEW_IP
        if [[ "$NEW_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
          break
        else
          msg "Formato de IP inválido. Use el formato: IP/máscara (ej: 192.168.1.100/24)" "WARNING"
        fi
      done

      # Solicitar Gateway
      while true; do
        echo -n -e "${BYellow}Ingrese la puerta de enlace (ej: 192.168.1.1): ${Color_Off}"
        read GATEWAY
        if [[ "$GATEWAY" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
          break
        else
          msg "Formato de gateway inválido. Use el formato: IP (ej: 192.168.1.1)" "WARNING"
        fi
      done

      # Solicitar DNS primario
      while true; do
        echo -n -e "${BYellow}Ingrese el DNS primario (por defecto 8.8.8.8): ${Color_Off}"
        read DNS1
        if [ -z "$DNS1" ]; then
          DNS1="8.8.8.8"
          break
        elif [[ "$DNS1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
          break
        else
          msg "Formato de DNS inválido. Use el formato: IP (ej: 8.8.8.8)" "WARNING"
        fi
      done

      # Solicitar DNS secundario
      while true; do
        echo -n -e "${BYellow}Ingrese el DNS secundario (por defecto 8.8.4.4): ${Color_Off}"
        read DNS2
        if [ -z "$DNS2" ]; then
          DNS2="8.8.4.4"
          break
        elif [[ "$DNS2" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
          break
        else
          msg "Formato de DNS inválido. Use el formato: IP (ej: 8.8.4.4)" "WARNING"
        fi
      done

      echo -e "\n${BGreen}Configuración personalizada:${Color_Off}"
      echo -e "${BWhite}IP: ${NEW_IP}${Color_Off}"
      echo -e "${BWhite}Gateway: ${GATEWAY}${Color_Off}"
      echo -e "${BWhite}DNS1: ${DNS1}${Color_Off}"
      echo -e "${BWhite}DNS2: ${DNS2}${Color_Off}"

      echo -n -e "${BYellow}¿Confirma esta configuración? (s/n): ${Color_Off}"
      read CONFIRM
      if [[ ! "$CONFIRM" =~ ^[sS]$ ]]; then
        msg "Configuración cancelada. Reiniciando selección..." "WARNING"
        CHOICE=""
        continue
      fi
      ;;
    *)
      msg "Opción no válida. Por favor, ingrese 1, 2, 3 o 4." "WARNING"
      ;;
  esac
done

# 3. Generar el nuevo contenido del archivo Netplan
if [ "$CONFIG_TYPE" = "dhcp" ]; then
    msg "Generando configuración DHCP para VMware NAT..." "INFO"
    NEW_CONFIG=$(cat <<EOF
network:
  version: 2
  ethernets:
    ${INTERFACE}:
      dhcp4: true
EOF
)
else
    msg "Generando nueva configuración para ${NEW_IP}..." "INFO"
    NEW_CONFIG=$(cat <<EOF
network:
  version: 2
  ethernets:
    ${INTERFACE}:
      addresses:
        - ${NEW_IP}
      nameservers:
        addresses:
          - ${DNS1}
          - ${DNS2}
      routes:
        - to: 0.0.0.0/0
          via: ${GATEWAY}
EOF
)
fi

# 4. Escribir la nueva configuración en el archivo Netplan
msg "Escribiendo nueva configuración en ${NETPLAN_FILE}..." "INFO"
echo "${NEW_CONFIG}" > "${NETPLAN_FILE}"
if [ $? -ne 0 ]; then
  msg "No se pudo escribir la nueva configuración en ${NETPLAN_FILE}. Abortando." "ERROR"
  exit 1
fi
msg "Nueva configuración escrita correctamente." "SUCCESS"

# 5. Generar y aplicar los cambios de Netplan
msg "Generando configuración de Netplan..." "INFO"
netplan --debug generate
if [ $? -ne 0 ]; then
  msg "La configuración generada por Netplan tiene errores. Revise la configuración." "ERROR"
  msg "Revertiendo a la copia de seguridad..." "WARNING"
  cp "${BACKUP_FILE}" "${NETPLAN_FILE}"
  msg "Por favor, revise la configuración y vuelva a intentar." "ERROR"
  exit 1
fi

msg "Configuración generada correctamente. Aplicando cambios..." "SUCCESS"
netplan apply
if [ $? -ne 0 ]; then
  msg "Los cambios de Netplan no pudieron aplicarse. Revise la configuración." "ERROR"
  msg "Revertiendo a la copia de seguridad..." "WARNING"
  cp "${BACKUP_FILE}" "${NETPLAN_FILE}"
  netplan apply # Intenta aplicar la versión original
  msg "Por favor, reinicie la máquina virtual o el servicio de red si sigue sin conexión." "ERROR"
  exit 1
fi

msg "Cambios de Netplan aplicados correctamente." "SUCCESS"
msg "Verificando nueva configuración para ${INTERFACE}..." "INFO"
if [ "$CONFIG_TYPE" = "dhcp" ]; then
    msg "Esperando asignación automática de IP por DHCP de VMware..." "INFO"
    msg "VMware NAT asignará automáticamente una IP en el rango 192.168.x.x" "INFO"
    sleep 5
fi
echo -e "${BGreen}IP asignada:${Color_Off}"
ip -4 a show ${INTERFACE} | grep "inet " | awk '{print $2}'

# 6. Realizar comprobación de conectividad
msg "Realizando comprobación de conectividad (ping a 8.8.8.8)..." "INFO"
ping -c 4 8.8.8.8 # Ping 4 veces al servidor DNS de Google

if [ $? -eq 0 ]; then
  echo -e "\n${BGreen}╔══════════════════════════════════════════════════════════════════════════════╗${Color_Off}"
  echo -e "${BGreen}║                    CONECTIVIDAD EXITOSA                                      ║${Color_Off}"
  echo -e "${BGreen}╚══════════════════════════════════════════════════════════════════════════════╝${Color_Off}"
  msg "La máquina virtual puede alcanzar Internet correctamente." "SUCCESS"
  msg "Script completado exitosamente." "SUCCESS"
  exit 0
else
  echo -e "\n${BRed}╔══════════════════════════════════════════════════════════════════════════════╗${Color_Off}"
  echo -e "${BRed}║                    ERROR DE CONECTIVIDAD                                      ║${Color_Off}"
  echo -e "${BRed}╚══════════════════════════════════════════════════════════════════════════════╝${Color_Off}"
  msg "Falló la comprobación de conectividad. Puede que haya un problema." "ERROR"
  echo -e "${BYellow}Verifique la configuración de red de su VMware:${Color_Off}"
  echo ""
  if [ "$CONFIG_TYPE" = "dhcp" ]; then
    echo -e "${BCyan}Para DHCP (opción 3):${Color_Off}"
    echo -e "${BWhite}- VMware debe estar en modo 'NAT'${Color_Off}"
    echo -e "${BWhite}- La VM debería recibir automáticamente una IP en el rango 192.168.x.x${Color_Off}"
    echo -e "${BWhite}- No se requiere configuración adicional en VMware${Color_Off}"
  else
    echo -e "${BCyan}Para IP estática:${Color_Off}"
    echo -e "${BWhite}- Si usa 192.168.43.x, VMware debe estar en modo 'Bridged'${Color_Off}"
    echo -e "${BWhite}- Si usa 192.168.0.x, configure VMware en modo 'NAT' o 'Bridged' según su red${Color_Off}"
  fi
  echo ""
  msg "Verifique también que VMware Tools esté instalado y funcionando." "WARNING"
  msg "Script completado con errores." "ERROR"
  exit 1
fi
