#!/bin/bash

# paquetes  necesarios: sudo apt install smartmontools lsb-release lshw smartmontools net-tools

echo "=== INFORMACIÓN DEL SISTEMA ===" > informe_servidor.txt
lsb_release -a   >> informe_servidor.txt
echo "" >> informe_servidor.txt

echo "=== INFORMACIÓN DEL HARDWARE ===" >> informe_servidor.txt
sudo lshw -short >> informe_servidor.txt
echo "" >> informe_servidor.txt

echo "=== INFORMACIÓN DE LA CPU ===" >> informe_servidor.txt
lscpu >> informe_servidor.txt
echo "" >> informe_servidor.txt

echo "=== INFORMACIÓN DE LA MEMORIA ===" >> informe_servidor.txt
free -h >> informe_servidor.txt
echo "" >> informe_servidor.txt

echo "=== INFORMACIÓN DEL DISCO ===" >> informe_servidor.txt
df -h >> informe_servidor.txt
lsblk >> informe_servidor.txt
echo "" >> informe_servidor.txt

echo "=== ESTADO DE LOS DISCOS (SMART) ===" >> informe_servidor.txt
if command -v smartctl > /dev/null; then
  for disk in $(lsblk -nd --output NAME); do
    echo "=== /dev/$disk ===" >> informe_servidor.txt
    sudo smartctl -a /dev/$disk >> informe_servidor.txt
  done
else
  echo "smartctl no disponible" >> informe_servidor.txt
fi
echo "" >> informe_servidor.txt

echo "=== INFORMACIÓN DE LA RED ===" >> informe_servidor.txt
if command -v ifconfig > /dev/null; then
  ifconfig >> informe_servidor.txt
else
  echo "ifconfig no disponible, usando 'ip addr show'" >> informe_servidor.txt
  ip addr show >> informe_servidor.txt
fi
echo "" >> informe_servidor.txt

echo "=== INFORMACIÓN DE SERVICIOS ===" >> informe_servidor.txt
systemctl list-units --type=service --all >> informe_servidor.txt
echo "" >> informe_servidor.txt

echo "=== LOGS DEL SISTEMA ===" >> informe_servidor.txt
journalctl -xe >> informe_servidor.txt
echo "" >> informe_servidor.txt

echo "=== INFORMACIÓN DEL KERNEL ===" >> informe_servidor.txt
dmesg >> informe_servidor.txt