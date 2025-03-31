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
