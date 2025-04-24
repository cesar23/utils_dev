#!/bin/bash

# Ruta del archivo .nanorc
NANO_CONFIG_PATH="$HOME/.nanorc"

# Respaldo del archivo original si existe
if [ -f "$NANO_CONFIG_PATH" ]; then
    cp "$NANO_CONFIG_PATH" "$NANO_CONFIG_PATH.bak"
    echo "Se ha creado un respaldo en $NANO_CONFIG_PATH.bak"
fi

echo "" > $NANO_CONFIG_PATH

# Escribir el nuevo contenido en .bashrc
cat > "$NANO_CONFIG_PATH" << 'EOF'

###############################################################################
# 🎨 INCLUYE COLOREADO DE SINTAXIS
###############################################################################
include /usr/share/nano/*.nanorc
#include ~/.nano-syntax/*.nanorc

###############################################################################
# ⚙ CONFIGURACIONES COMPATIBLES CON NANO 2.9.8
###############################################################################

# 📌 Mostrar números de línea
set linenumbers

# 📌 Mostrar siempre la posición del cursor (línea y columna)
set constantshow

# 📌 Usar espacios en lugar de tabs
set tabstospaces

# 📌 Tamaño de tabulación: 2 espacios
set tabsize 2

# 📌 Resaltar llaves y paréntesis coincidentes
set matchbrackets "()[]{}"

# 📌 No guardar archivos temporales (como .save)
set tempfile

EOF

echo "✅ Configuración aplicada en $NANO_CONFIG_PATH"
source "$NANO_CONFIG_PATH"