#!/bin/bash

# URL del archivo zip
ZIP_URL="https://raw.githubusercontent.com/cesar23/utils_dev/refs/heads/master/dotfiles/bashrc/libs_shell.zip"

# Carpeta de destino
DEST_DIR="$USERPROFILE/libs_shell"

# Ruta temporal para el zip descargado
TEMP_ZIP="/tmp/libs_shell.zip"

# Crear carpeta temporal si no existe
mkdir -p /tmp

# Descargar el archivo zip
echo "📥 Descargando archivo..."
curl -L "$ZIP_URL" -o "$TEMP_ZIP"

# Verifica si se descargó correctamente
if [ $? -ne 0 ]; then
  echo "❌ Error al descargar el archivo."
  exit 1
fi

# Eliminar carpeta existente si ya existe
if [ -d "$DEST_DIR" ]; then
  echo "⚠️  Carpeta existente encontrada. Eliminando $DEST_DIR..."
  rm -rf "$DEST_DIR"
fi

# Descomprimir el zip en el directorio de usuario
echo "📂 Descomprimiendo en $USERPROFILE..."
unzip -q "$TEMP_ZIP" -d "$USERPROFILE"

# Confirmación
if [ -d "$DEST_DIR" ]; then
  echo "✅ Carpeta 'libs_shell' lista en: $DEST_DIR"
else
  echo "❌ Algo salió mal. No se encontró la carpeta 'libs_shell'."
fi
