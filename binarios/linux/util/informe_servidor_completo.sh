#!/bin/bash

# === COLORES ===
Color_Off='\e[0m'       # Reset de color
BGreen='\e[1;32m'       # Verde negrita
BYellow='\e[1;33m'      # Amarillo negrita
BBlue='\e[1;34m'        # Azul negrita
BRed='\e[1;31m'         # Rojo negrita
BWhite='\e[1;37m'       # Blanco negrita

informe="informe_servidor.txt"

# Función para imprimir título
function titulo {
  echo -e "${BBlue}[*] $1${Color_Off}"
  echo "=== $1 ===" >> "$informe"
}

# Función para separador visual
function separador {
  echo "" >> "$informe"
}

echo -e "${BGreen}Generando informe del sistema...${Color_Off}"
echo "=== INFORME DEL SERVIDOR ===" > "$informe"

titulo "INFORMACIÓN DEL SISTEMA"
lsb_release -a >> "$informe"
separador

titulo "INFORMACIÓN DEL HARDWARE"
sudo lshw -short >> "$informe"
separador

titulo "INFORMACIÓN DE LA CPU"
lscpu >> "$informe"
separador

titulo "INFORMACIÓN DE LA MEMORIA"
free -h >> "$informe"
separador

titulo "INFORMACIÓN DEL DISCO"
df -h >> "$informe"
lsblk >> "$informe"
separador

titulo "ESTADO DE LOS DISCOS (SMART)"
if command -v smartctl > /dev/null; then
  for disk in $(lsblk -nd --output NAME); do
    echo "=== /dev/$disk ===" >> "$informe"
    sudo smartctl -a /dev/$disk >> "$informe"
  done
else
  echo "smartctl no disponible" >> "$informe"
fi
separador

titulo "INFORMACIÓN DE LA RED"
if command -v ifconfig > /dev/null; then
  ifconfig >> "$informe"
else
  echo "ifconfig no disponible, usando 'ip addr show'" >> "$informe"
  ip addr show >> "$informe"
fi
separador

titulo "INFORMACIÓN DE SERVICIOS"
systemctl list-units --type=service --all >> "$informe"
separador

titulo "LOGS DEL SISTEMA"
journalctl -xe >> "$informe"
separador

titulo "INFORMACIÓN DEL KERNEL"
dmesg >> "$informe"
separador

# Mensaje final
echo -e "${BGreen}[✔] Informe generado exitosamente.${Color_Off}"
echo -e "${BYellow}Ruta del informe: ${BWhite}$(realpath $informe)${Color_Off}"