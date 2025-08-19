#!/bin/bash

# =======================================
# 🕒 Fechas y horas
# =======================================

# Fecha y hora local del sistema
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")

# Fecha y hora actual en Perú (UTC -5)
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d_%H:%M:%S")

# Ruta del archivo de salida (usando la fecha Perú)
informe="informe_sistema_${DATE_HOUR_PE}.log"

# =======================================
# 🎨 Colores para consola
# =======================================

BGreen='\033[1;32m'
BYellow='\033[1;33m'
BWhite='\033[1;37m'
Color_Off='\033[0m'

# =======================================
# 🔧 Funciones auxiliares
# =======================================

# Título bonito en el log
titulo() {
  echo -e "\n========== [$1] ==========\n" >> "$informe"
}

# Separador visual
separador() {
  echo -e "\n----------------------------------------\n" >> "$informe"
}

# =======================================
# 📝 Inicio del informe
# =======================================

echo -e "${BYellow}Generando informe del sistema...${Color_Off}"
echo -e "INFORME DE SISTEMA - Fecha local: $DATE_HOUR | Fecha Perú: $DATE_HOUR_PE\n" > "$informe"

# =======================================
# 🌐 Información de red
# =======================================

titulo "INFORMACIÓN DE LA RED"
if which ifconfig > /dev/null; then
  ifconfig >> "$informe"
else
  echo "ifconfig no disponible, usando 'ip addr show'" >> "$informe"
  ip addr show >> "$informe"
fi
separador


# =======================================
# 🔧 Información del servidor
# =======================================

titulo "INFORMACIÓN DEL SERVIDOR (hostnamectl)"
hostnamectl >> "$informe"
separador

titulo "ARCHIVO /etc/hosts"
if [ -f /etc/hosts ]; then
  cat /etc/hosts >> "$informe"
else
  echo "/etc/hosts no encontrado." >> "$informe"
fi
separador


titulo "LOGS DE CYBERPANEL (últimos 100)"
if [ -f /home/cyberpanel/error-logs.txt ]; then
  if sudo -n true 2>/dev/null; then
    sudo tail -n 50 /home/cyberpanel/error-logs.txt >> "$informe"
  else
    echo "⚠️  No se pudo acceder a los logs de CyberPanel (se requiere sudo)." >> "$informe"
  fi
else
  echo "El archivo /home/cyberpanel/error-logs.txt no existe." >> "$informe"
fi
separador


# =======================================
# 🌐 VIRTUAL HOSTS LITESPEED
# =======================================

titulo "VIRTUAL HOSTS (LiteSpeed)"
if [ -d /usr/local/lsws/conf/vhosts/ ]; then
  ls /usr/local/lsws/conf/vhosts/ >> "$informe"
else
  echo "Directorio /usr/local/lsws/conf/vhosts/ no encontrado." >> "$informe"
fi
separador

# =======================================
# 🔐 CERTIFICADOS SSL LET'S ENCRYPT
# =======================================

titulo "CERTIFICADOS SSL (Let's Encrypt - cert.pem)"
if [ -d /etc/letsencrypt/live/ ]; then
  find /etc/letsencrypt/live/ -name "cert.pem" >> "$informe"
else
  echo "Directorio /etc/letsencrypt/live/ no encontrado." >> "$informe"
fi
separador

# =======================================
# 🛠️ Servicios
# =======================================

#titulo "INFORMACIÓN DE SERVICIOS (Todos)"
#systemctl list-units --type=service --all >> "$informe"
#separador

titulo "SERVICIOS ACTIVOS"
systemctl list-units --type=service --state=running >> "$informe"
separador

# =======================================
# 📜 Logs del sistema
# =======================================

titulo "ÚLTIMOS LOGS DEL SISTEMA"
journalctl -xe | tail -n 20 >> "$informe"
separador

titulo "ÚLTIMOS INICIOS DE SESIÓN SSH (Aceptados)"
journalctl _COMM=sshd | grep "Accepted" | tail -n 15 >> "$informe"
separador

# =======================================
# 🔒 Seguridad
# =======================================

titulo "ESTADO DE FAIL2BAN (sshd)"
if which fail2ban-client > /dev/null; then
  if sudo -n true 2>/dev/null; then
    sudo fail2ban-client status sshd >> "$informe"
  else
    echo "⚠️  No se pudo obtener estado de fail2ban (se requiere sudo)." >> "$informe"
  fi
else
  echo "Fail2Ban no está instalado." >> "$informe"
fi
separador

titulo "ÚLTIMOS EVENTOS DEL FIREWALL (syslog)"
if [ -f /var/log/syslog ]; then
  if sudo -n true 2>/dev/null; then
    sudo grep 'Firewall' /var/log/syslog | tail -n 10 >> "$informe"
  else
    echo "⚠️  No se pudo acceder a /var/log/syslog (se requiere sudo)." >> "$informe"
  fi
else
  echo "/var/log/syslog no disponible en este sistema." >> "$informe"
fi
separador

titulo "LOGS DE CSF (ConfigServer Security & Firewall)"
if which csf > /dev/null; then
  if sudo -n true 2>/dev/null; then
    sudo csf -l >> "$informe"
  else
    echo "⚠️  No se pudo ejecutar csf -l (se requiere sudo)." >> "$informe"
  fi
else
  echo "CSF no está instalado." >> "$informe"
fi
separador

# =======================================
#  Información de servidor de correo
# =======================================

titulo "INFORMACIÓN SERVIDOR CORREO (Postfix)"
if [ -f /etc/postfix/main.cf ]; then
  if sudo -n true 2>/dev/null; then
    echo ">> Version de Postfix:" >> "$informe"
    sudo postconf mail_version >> "$informe"
    echo "" >> "$informe"
    sudo postconf -n >> "$informe"
  else
    echo "⚠️  No se pudo acceder a la configuración de Postfix (se requiere sudo)." >> "$informe"
  fi
else
  echo "Archivo /etc/postfix/main.cf no encontrado." >> "$informe"
fi
separador


titulo "INFORMACIÓN SERVIDOR CORREO (Dovecot)"
if [ -f /etc/dovecot/dovecot.conf ]; then
  if sudo -n true 2>/dev/null; then
    echo ">> Version de Dovecot:" >> "$informe"
    sudo dovecot --version >> "$informe"
    echo "" >> "$informe"
    echo "Configuración de Dovecot:" >> "$informe"
    sudo dovecot -n >> "$informe"
  else
    echo "⚠️  No se pudo acceder a la configuración de Dovecot (se requiere sudo)." >> "$informe"
  fi
else
  echo "Archivo /etc/postfix/main.cf no encontrado." >> "$informe"
fi
separador

titulo "Logs de postfix"
if [ -f /var/log/mail.log ]; then
    echo "Logs mail:" >> "$informe"
    echo "" >> "$informe"
    sudo tail -n 25  /var/log/mail.log  >> "$informe"
else
  echo "Archivo /var/log/mail.log no encontrado." >> "$informe"
fi


# =======================================
# 🧠 Información del Kernel
# =======================================

titulo "INFORMACIÓN DEL KERNEL (dmesg)"
dmesg | tail -n 50 >> "$informe"
separador

# =======================================
# ✅ Finalización
# =======================================

echo -e "${BGreen}[✔] Informe generado exitosamente.${Color_Off}"
echo -e "${BYellow}Ruta del informe: ${BWhite}$(realpath "$informe")${Color_Off}"