#!/bin/bash

# ============================================================
#  INFORME COMPLETO DE SERVIDOR LINUX
#  Autor  : Ingeniero César Auris
#  Versión: 2.0 - General (sin dependencias de terceros)
#  Web    : https://solucionessystem.com
#  Tel    : 937516027
# ============================================================

# -------------------------------------------------------
# 🎨 COLORES
# -------------------------------------------------------
BGreen='\033[1;32m'
BYellow='\033[1;33m'
BRed='\033[1;31m'
BCyan='\033[1;36m'
BWhite='\033[1;37m'
Color_Off='\033[0m'

# -------------------------------------------------------
# 🕒 FECHAS
# -------------------------------------------------------
DATE_LOCAL=$(date "+%Y-%m-%d_%H:%M:%S")
# Calcular UTC-5 (Perú) de forma portable sin depender de 'date -d'
_ts=$(date -u +%s 2>/dev/null)
if [ -n "$_ts" ]; then
  _ts_pe=$(( _ts - 5 * 3600 ))
  DATE_PE=$(date -u -d "@${_ts_pe}" "+%Y-%m-%d_%H:%M:%S" 2>/dev/null \
         || date -r "${_ts_pe}" "+%Y-%m-%d_%H:%M:%S" 2>/dev/null \
         || date -u "+%Y-%m-%d_%H:%M:%S")
else
  DATE_PE=$(date -u "+%Y-%m-%d_%H:%M:%S")
fi
INFORME="informe_linux_${DATE_PE}.log"

# -------------------------------------------------------
# 🔧 FUNCIONES AUXILIARES
# -------------------------------------------------------

titulo() {
  echo -e "\n\n╔══════════════════════════════════════════════╗" >> "$INFORME"
  printf   "║  %-44s║\n" " $1" >> "$INFORME"
  echo -e   "╚══════════════════════════════════════════════╝\n" >> "$INFORME"
}

separador() {
  echo -e "\n────────────────────────────────────────────────\n" >> "$INFORME"
}

# Ejecuta un comando solo si existe; si no, imprime aviso
cmd_run() {
  local label="$1"; shift
  echo -e "▶ $label:" >> "$INFORME"
  if command -v "$1" &>/dev/null; then
    "$@" >> "$INFORME" 2>&1
  else
    echo "  ⚠ Comando '$1' no disponible en este sistema." >> "$INFORME"
  fi
  echo "" >> "$INFORME"
}

# Lee un archivo si existe
leer_archivo() {
  local label="$1"
  local archivo="$2"
  echo -e "▶ $label ($archivo):" >> "$INFORME"
  if [ -f "$archivo" ]; then
    cat "$archivo" >> "$INFORME" 2>&1
  else
    echo "  ⚠ Archivo no encontrado: $archivo" >> "$INFORME"
  fi
  echo "" >> "$INFORME"
}

# Hostname portátil: Arch no incluye 'hostname' por defecto (paquete inetutils)
get_hostname() {
  if command -v hostname &>/dev/null; then
    hostname
  elif [ -f /etc/hostname ]; then
    cat /etc/hostname
  else
    uname -n
  fi
}
get_fqdn() {
  if command -v hostname &>/dev/null; then
    hostname -f 2>/dev/null || get_hostname
  else
    get_hostname
  fi
}

# Detecta si hay sudo disponible sin contraseña
TIENE_SUDO=false
if sudo -n true 2>/dev/null; then
  TIENE_SUDO=true
fi

sudo_run() {
  local label="$1"; shift
  echo -e "▶ $label:" >> "$INFORME"
  if $TIENE_SUDO; then
    sudo "$@" >> "$INFORME" 2>&1
  else
    echo "  ⚠ Se requiere sudo para: $*" >> "$INFORME"
  fi
  echo "" >> "$INFORME"
}

# -------------------------------------------------------
# 📝 ENCABEZADO DEL INFORME
# -------------------------------------------------------
echo -e "${BYellow}Iniciando generación del informe del servidor...${Color_Off}"
echo ""

cat > "$INFORME" <<EOF
╔═══════════════════════════════════════════════════════╗
║         INFORME COMPLETO DE SERVIDOR LINUX            ║
╠═══════════════════════════════════════════════════════╣
║  Fecha local  : $DATE_LOCAL
║  Fecha Perú   : $DATE_PE
╠═══════════════════════════════════════════════════════╣
║  Desarrollado por : Ingeniero César Auris             ║
║  Teléfono         : 937516027                         ║
║  Website          : https://solucionessystem.com      ║
╚═══════════════════════════════════════════════════════╝

EOF

# ============================================================
# 1. IDENTIFICACIÓN DEL SISTEMA
# ============================================================
titulo "1. IDENTIFICACIÓN DEL SISTEMA"

echo -e "▶ Hostname y sistema operativo:" >> "$INFORME"
echo "  Hostname  : $(get_hostname)" >> "$INFORME"
echo "  FQDN      : $(get_fqdn)" >> "$INFORME"
echo "" >> "$INFORME"

leer_archivo "OS Release" "/etc/os-release"

cmd_run "Información del host (hostnamectl)" hostnamectl

echo -e "▶ Kernel y arquitectura (uname -a):" >> "$INFORME"
uname -a >> "$INFORME"
echo "" >> "$INFORME"

leer_archivo "Versión del kernel (/proc/version)" "/proc/version"

echo -e "▶ Uptime y carga del sistema:" >> "$INFORME"
uptime >> "$INFORME"
echo "" >> "$INFORME"

leer_archivo "Carga promedio (/proc/loadavg)" "/proc/loadavg"

echo -e "▶ Fecha y hora del sistema:" >> "$INFORME"
date >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Variables de zona horaria:" >> "$INFORME"
timedatectl 2>/dev/null >> "$INFORME" || cat /etc/timezone 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 2. HARDWARE: CPU
# ============================================================
titulo "2. HARDWARE — CPU"

cmd_run "Información de CPU (lscpu)" lscpu

leer_archivo "Detalles de CPU (/proc/cpuinfo — resumen)" "/proc/cpuinfo"
# Solo resumen de cpuinfo para no llenar el log
echo -e "▶ Resumen rápido /proc/cpuinfo:" >> "$INFORME"
grep -E "^(model name|cpu MHz|cache size|siblings|cpu cores|flags)" /proc/cpuinfo 2>/dev/null | sort -u >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 3. HARDWARE: MEMORIA RAM Y SWAP
# ============================================================
titulo "3. HARDWARE — MEMORIA RAM Y SWAP"

echo -e "▶ Resumen de memoria (free -h):" >> "$INFORME"
free -h >> "$INFORME"
echo "" >> "$INFORME"

leer_archivo "Detalles de memoria (/proc/meminfo)" "/proc/meminfo"
separador

# ============================================================
# 4. HARDWARE: DISCOS Y ALMACENAMIENTO
# ============================================================
titulo "4. HARDWARE — DISCOS Y ALMACENAMIENTO"

cmd_run "Dispositivos de bloque (lsblk -f)" lsblk -f
cmd_run "Dispositivos de bloque - árbol (lsblk)" lsblk
cmd_run "Particiones del disco (fdisk -l)" fdisk -l

echo -e "▶ Uso del sistema de archivos (df -hT):" >> "$INFORME"
df -hT >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Uso de inodos (df -i):" >> "$INFORME"
df -i >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Top 15 directorios más grandes en / (du):" >> "$INFORME"
du -sh /* 2>/dev/null | sort -hr | head -n 15 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Top 10 directorios más grandes en /home:" >> "$INFORME"
du -sh /home/* 2>/dev/null | sort -hr | head -n 10 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Top 10 directorios más grandes en /var:" >> "$INFORME"
du -sh /var/* 2>/dev/null | sort -hr | head -n 10 >> "$INFORME"
echo "" >> "$INFORME"

leer_archivo "Información de montajes (/proc/mounts)" "/proc/mounts"
separador

# ============================================================
# 5. HARDWARE: PCI Y DISPOSITIVOS
# ============================================================
titulo "5. HARDWARE — DISPOSITIVOS PCI Y USB"

cmd_run "Dispositivos PCI (lspci)" lspci
cmd_run "Dispositivos USB (lsusb)" lsusb

echo -e "▶ Información DMI/BIOS (dmidecode - resumen):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo dmidecode -t system   2>/dev/null >> "$INFORME" || echo "  dmidecode no disponible." >> "$INFORME"
  sudo dmidecode -t bios     2>/dev/null >> "$INFORME"
  sudo dmidecode -t memory   2>/dev/null >> "$INFORME"
else
  echo "  ⚠ Se requiere sudo para dmidecode." >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 6. RED
# ============================================================
titulo "6. RED — INTERFACES Y CONFIGURACIÓN"

echo -e "▶ Interfaces de red:" >> "$INFORME"
if command -v ip &>/dev/null; then
  ip addr show >> "$INFORME" 2>&1
elif command -v ifconfig &>/dev/null; then
  ifconfig >> "$INFORME" 2>&1
else
  cat /proc/net/if_inet6 2>/dev/null >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Tabla de enrutamiento (ip route):" >> "$INFORME"
ip route show >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Tabla de enrutamiento IPv6:" >> "$INFORME"
ip -6 route show >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Estadísticas de red (ip -s link):" >> "$INFORME"
ip -s link >> "$INFORME" 2>&1
echo "" >> "$INFORME"

leer_archivo "Archivo /etc/hosts" "/etc/hosts"
leer_archivo "Servidores DNS (/etc/resolv.conf)" "/etc/resolv.conf"
leer_archivo "Configuración NSS (/etc/nsswitch.conf)" "/etc/nsswitch.conf"

echo -e "▶ Puertos abiertos y servicios escuchando (ss -tulnp):" >> "$INFORME"
ss -tulnp >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Conexiones activas establecidas (ss -tnp state established):" >> "$INFORME"
ss -tnp state established 2>/dev/null >> "$INFORME" || netstat -tnp 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Estadísticas de red (/proc/net/dev):" >> "$INFORME"
cat /proc/net/dev >> "$INFORME" 2>&1
echo "" >> "$INFORME"

separador

# ============================================================
# 7. USUARIOS Y SESIONES
# ============================================================
titulo "7. USUARIOS Y SESIONES"

echo -e "▶ Usuarios conectados actualmente (who):" >> "$INFORME"
who >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Sesiones activas detalladas (w):" >> "$INFORME"
w >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Últimos 20 inicios de sesión (last):" >> "$INFORME"
last -n 20 >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Últimos 10 intentos fallidos (lastb):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo lastb -n 10 2>/dev/null >> "$INFORME" || echo "  lastb no disponible." >> "$INFORME"
else
  echo "  ⚠ Se requiere sudo para lastb." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Usuarios con shell válida (/etc/passwd):" >> "$INFORME"
grep -E "(/bin/bash|/bin/sh|/bin/zsh|/bin/fish)" /etc/passwd >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Grupos del sistema (/etc/group — sin sistema):" >> "$INFORME"
grep -v "^#" /etc/group | grep -v ":x:[0-9]\{1,2\}:" >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Usuarios con UID 0 (root) — posibles backdoors:" >> "$INFORME"
awk -F: '($3 == 0) {print}' /etc/passwd >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Usuarios con sudo (sudoers):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo grep -E "^[^#]" /etc/sudoers 2>/dev/null | grep -v "^Defaults" >> "$INFORME"
  sudo ls /etc/sudoers.d/ 2>/dev/null >> "$INFORME"
else
  echo "  ⚠ Se requiere sudo para leer /etc/sudoers." >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 8. PROCESOS Y RECURSOS
# ============================================================
titulo "8. PROCESOS Y RECURSOS"

echo -e "▶ Snapshot de procesos (top -b -n1):" >> "$INFORME"
top -b -n 1 | head -30 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Top 15 procesos por uso de CPU:" >> "$INFORME"
ps aux --sort=-%cpu | head -16 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Top 15 procesos por uso de RAM:" >> "$INFORME"
ps aux --sort=-%mem | head -16 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Conteo total de procesos:" >> "$INFORME"
echo "  Total de procesos activos: $(ps aux | wc -l)" >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Límites del sistema (/proc/sys/kernel):" >> "$INFORME"
echo "  PID máximo    : $(cat /proc/sys/kernel/pid_max 2>/dev/null)" >> "$INFORME"
echo "  Threads máx   : $(cat /proc/sys/kernel/threads-max 2>/dev/null)" >> "$INFORME"
echo "  File handles  : $(cat /proc/sys/fs/file-max 2>/dev/null)" >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Archivos abiertos actuales:" >> "$INFORME"
cat /proc/sys/fs/file-nr 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 9. SERVICIOS SYSTEMD
# ============================================================
titulo "9. SERVICIOS — SYSTEMD"

echo -e "▶ Servicios en ejecución:" >> "$INFORME"
systemctl list-units --type=service --state=running --no-pager >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Servicios fallidos:" >> "$INFORME"
systemctl list-units --type=service --state=failed --no-pager >> "$INFORME" 2>&1
echo "" >> "$INFORME"

echo -e "▶ Unidades habilitadas al inicio:" >> "$INFORME"
systemctl list-unit-files --type=service --state=enabled --no-pager >> "$INFORME" 2>&1
echo "" >> "$INFORME"

separador

# ============================================================
# 10. TAREAS PROGRAMADAS (CRON)
# ============================================================
titulo "10. TAREAS PROGRAMADAS (CRON)"

echo -e "▶ Crontab del usuario actual:" >> "$INFORME"
crontab -l 2>/dev/null >> "$INFORME" || echo "  Sin tareas cron para el usuario actual." >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Crontab de root:" >> "$INFORME"
if $TIENE_SUDO; then
  sudo crontab -l -u root 2>/dev/null >> "$INFORME" || echo "  Sin tareas cron para root." >> "$INFORME"
fi
echo "" >> "$INFORME"

for dir in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly; do
  echo -e "▶ Contenido de $dir:" >> "$INFORME"
  if [ -d "$dir" ]; then
    ls -la "$dir" >> "$INFORME" 2>&1
  else
    echo "  No existe: $dir" >> "$INFORME"
  fi
  echo "" >> "$INFORME"
done

leer_archivo "Archivo /etc/crontab" "/etc/crontab"

echo -e "▶ Timers systemd activos:" >> "$INFORME"
systemctl list-timers --no-pager 2>/dev/null >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 11. VARIABLES DE ENTORNO Y CONFIGURACIÓN DEL SISTEMA
# ============================================================
titulo "11. VARIABLES DE ENTORNO Y CONFIGURACIÓN"

echo -e "▶ Variables de entorno del proceso actual:" >> "$INFORME"
env | sort >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Parámetros del kernel (sysctl -a — selección):" >> "$INFORME"
if $TIENE_SUDO; then
  sudo sysctl -a 2>/dev/null | grep -E "^(net\.(core|ipv4|ipv6)\.|vm\.|kernel\.(hostname|domainname|pid_max|randomize_va_space|dmesg_restrict))" >> "$INFORME"
else
  sysctl -a 2>/dev/null | grep -E "^(net\.(core|ipv4|ipv6)\.|vm\.|kernel\.)" >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Límites de recursos (ulimit -a):" >> "$INFORME"
ulimit -a >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 12. SEGURIDAD
# ============================================================
titulo "12. SEGURIDAD"

echo -e "▶ Estado de SELinux:" >> "$INFORME"
if command -v getenforce &>/dev/null; then
  getenforce >> "$INFORME"
  sestatus 2>/dev/null >> "$INFORME"
else
  echo "  SELinux no disponible." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Estado de AppArmor:" >> "$INFORME"
if command -v aa-status &>/dev/null; then
  if $TIENE_SUDO; then
    sudo aa-status 2>/dev/null >> "$INFORME"
  else
    aa-status 2>/dev/null >> "$INFORME"
  fi
else
  echo "  AppArmor no disponible." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Estado de UFW (firewall):" >> "$INFORME"
if command -v ufw &>/dev/null; then
  if $TIENE_SUDO; then
    sudo ufw status verbose >> "$INFORME" 2>&1
  else
    echo "  ⚠ Se requiere sudo para ufw." >> "$INFORME"
  fi
else
  echo "  UFW no disponible." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Reglas de iptables:" >> "$INFORME"
if $TIENE_SUDO; then
  sudo iptables -L -n -v 2>/dev/null >> "$INFORME" || echo "  iptables no disponible." >> "$INFORME"
else
  echo "  ⚠ Se requiere sudo para iptables." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Estado de Fail2ban:" >> "$INFORME"
if command -v fail2ban-client &>/dev/null; then
  if $TIENE_SUDO; then
    sudo fail2ban-client status 2>/dev/null >> "$INFORME"
  else
    echo "  ⚠ Se requiere sudo para fail2ban-client." >> "$INFORME"
  fi
else
  echo "  Fail2ban no instalado." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Logins SSH aceptados (últimos 20):" >> "$INFORME"
journalctl _COMM=sshd --no-pager 2>/dev/null | grep "Accepted" | tail -n 20 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Intentos fallidos SSH (últimos 20):" >> "$INFORME"
journalctl _COMM=sshd --no-pager 2>/dev/null | grep -E "(Failed|Invalid)" | tail -n 20 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Configuración SSH (/etc/ssh/sshd_config — sin comentarios):" >> "$INFORME"
grep -E "^[^#]" /etc/ssh/sshd_config 2>/dev/null >> "$INFORME" || echo "  No se pudo leer sshd_config." >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Archivos SUID encontrados (posibles riesgos):" >> "$INFORME"
find / -perm -4000 -type f 2>/dev/null | head -30 >> "$INFORME"
echo "" >> "$INFORME"

separador

# ============================================================
# 13. LOGS DEL SISTEMA
# ============================================================
titulo "13. LOGS DEL SISTEMA"

echo -e "▶ Últimas 30 líneas del journal del sistema:" >> "$INFORME"
journalctl -xe --no-pager 2>/dev/null | tail -n 30 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Errores críticos recientes (journalctl -p 0..3):" >> "$INFORME"
journalctl -p 0..3 --no-pager --since "7 days ago" 2>/dev/null | tail -n 30 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Últimas líneas de /var/log/syslog o /var/log/messages:" >> "$INFORME"
if [ -f /var/log/syslog ]; then
  tail -n 30 /var/log/syslog >> "$INFORME" 2>&1
elif [ -f /var/log/messages ]; then
  tail -n 30 /var/log/messages >> "$INFORME" 2>&1
else
  echo "  No se encontró syslog ni messages." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Últimas líneas de /var/log/auth.log:" >> "$INFORME"
if [ -f /var/log/auth.log ]; then
  tail -n 30 /var/log/auth.log >> "$INFORME" 2>&1
else
  echo "  No se encontró auth.log (puede estar en journald)." >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# 14. PAQUETES Y SOFTWARE
# ============================================================
titulo "14. PAQUETES Y SOFTWARE INSTALADO"

echo -e "▶ Gestor de paquetes y versiones instaladas:" >> "$INFORME"
if command -v pacman &>/dev/null; then
  echo "  Gestor: Pacman (Arch Linux / Manjaro)" >> "$INFORME"
  echo "  Paquetes instalados: $(pacman -Q 2>/dev/null | wc -l)" >> "$INFORME"
  echo "" >> "$INFORME"
  echo "  Actualizaciones disponibles (checkupdates):" >> "$INFORME"
  if command -v checkupdates &>/dev/null; then
    checkupdates 2>/dev/null | head -20 >> "$INFORME" || echo "  Sin actualizaciones pendientes o no disponible." >> "$INFORME"
  else
    echo "  (instala 'pacman-contrib' para usar checkupdates)" >> "$INFORME"
  fi
  echo "" >> "$INFORME"
  echo "  Paquetes instalados explícitamente (últimos 20):" >> "$INFORME"
  pacman -Qe 2>/dev/null | tail -20 >> "$INFORME"
elif command -v apt &>/dev/null; then
  echo "  Gestor: APT (Debian/Ubuntu)" >> "$INFORME"
  echo "  Paquetes instalados: $(dpkg -l 2>/dev/null | grep -c "^ii")" >> "$INFORME"
  echo "" >> "$INFORME"
  echo "  Actualizaciones disponibles:" >> "$INFORME"
  apt list --upgradable 2>/dev/null | head -20 >> "$INFORME"
elif command -v dnf &>/dev/null; then
  echo "  Gestor: DNF (RHEL/Fedora/CentOS)" >> "$INFORME"
  echo "  Paquetes instalados: $(rpm -qa 2>/dev/null | wc -l)" >> "$INFORME"
  dnf check-update 2>/dev/null | head -20 >> "$INFORME"
elif command -v yum &>/dev/null; then
  echo "  Gestor: YUM (CentOS/RHEL)" >> "$INFORME"
  echo "  Paquetes instalados: $(rpm -qa 2>/dev/null | wc -l)" >> "$INFORME"
else
  echo "  Gestor de paquetes no detectado." >> "$INFORME"
fi
echo "" >> "$INFORME"

echo -e "▶ Versiones de lenguajes/runtimes instalados:" >> "$INFORME"
for lang in python3 python php node java ruby go perl gcc; do
  if command -v "$lang" &>/dev/null; then
    printf "  %-10s: %s\n" "$lang" "$($lang --version 2>&1 | head -1)" >> "$INFORME"
  fi
done
echo "" >> "$INFORME"

echo -e "▶ Versiones de bases de datos instaladas:" >> "$INFORME"
for db in mysql mariadb psql mongo redis-cli sqlite3; do
  if command -v "$db" &>/dev/null; then
    printf "  %-12s: %s\n" "$db" "$($db --version 2>&1 | head -1)" >> "$INFORME"
  fi
done
echo "" >> "$INFORME"

separador

# ============================================================
# 15. KERNEL Y DMESG
# ============================================================
titulo "15. KERNEL — DMESG Y MÓDULOS"

echo -e "▶ Últimos mensajes del kernel (dmesg):" >> "$INFORME"
dmesg 2>/dev/null | tail -n 40 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Errores y warnings del kernel:" >> "$INFORME"
dmesg 2>/dev/null | grep -E -i "(error|warn|fail|crit)" | tail -n 20 >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Módulos del kernel cargados (lsmod):" >> "$INFORME"
lsmod >> "$INFORME" 2>&1
echo "" >> "$INFORME"

separador

# ============================================================
# 16. INFORMACIÓN VIRTUALIZACIÓN / CONTENEDORES
# ============================================================
titulo "16. VIRTUALIZACIÓN Y CONTENEDORES"

echo -e "▶ Tipo de virtualización detectado:" >> "$INFORME"
if command -v systemd-detect-virt &>/dev/null; then
  echo "  systemd-detect-virt: $(systemd-detect-virt)" >> "$INFORME"
fi
echo "  /proc/1/environ (busca docker/lxc):" >> "$INFORME"
cat /proc/1/environ 2>/dev/null | tr '\0' '\n' | grep -E "(container|docker|lxc)" >> "$INFORME" || echo "  No se detectó entorno de contenedor." >> "$INFORME"
echo "" >> "$INFORME"

echo -e "▶ Docker (si está instalado):" >> "$INFORME"
if command -v docker &>/dev/null; then
  docker version 2>/dev/null >> "$INFORME"
  echo "" >> "$INFORME"
  echo "  Contenedores activos:" >> "$INFORME"
  docker ps 2>/dev/null >> "$INFORME"
else
  echo "  Docker no instalado." >> "$INFORME"
fi
echo "" >> "$INFORME"

separador

# ============================================================
# ✅ PIE DEL INFORME
# ============================================================
echo -e "\n\n════════════════════════════════════════════════" >> "$INFORME"
echo -e "  Informe generado el: $(date)" >> "$INFORME"
echo -e "  Usuario que ejecutó: $(whoami)" >> "$INFORME"
echo -e "  Hostname            : $(get_hostname)" >> "$INFORME"
echo -e "════════════════════════════════════════════════" >> "$INFORME"

# ============================================================
# RESUMEN EN CONSOLA
# ============================================================
echo ""
echo -e "${BGreen}╔═══════════════════════════════════════════════╗${Color_Off}"
echo -e "${BGreen}║   ✔  Informe generado exitosamente            ║${Color_Off}"
echo -e "${BGreen}╚═══════════════════════════════════════════════╝${Color_Off}"
echo ""
echo -e "${BYellow}📄 Archivo : ${BWhite}$(realpath "$INFORME")${Color_Off}"
echo -e "${BYellow}📦 Tamaño  : ${BWhite}$(du -sh "$INFORME" | cut -f1)${Color_Off}"
echo ""
echo -e "${BCyan}Secciones incluidas:${Color_Off}"
SCRIPT_PATH="${BASH_SOURCE[0]}"
if [ -f "$SCRIPT_PATH" ]; then
  grep -E '^titulo "[0-9]+\.' "$SCRIPT_PATH" | sed 's/titulo "//;s/".*//' | while read -r linea; do
    echo "  • $linea"
  done
else
  echo "  • Ver secciones en el archivo de log generado."
fi
echo ""