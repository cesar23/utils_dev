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

###############################################################################
# ⚙ CONFIGURACIÓN COMPATIBLE CON NANO 6.2
###############################################################################

# 📌 Muestra números de línea
set linenumbers

# 📌 Muestra posición constante del cursor (línea, columna)
set constantshow

# 📌 Usa colores suaves del terminal para textos largos
set softwrap

# 📌 Usa espacios en lugar de tabs
set tabstospaces

# 📌 Tamaño de tabulación de 2 espacios
set tabsize 2

# 📌 Muestra tabuladores y espacios como caracteres visibles
set whitespace "»·"     # "»" para tab, "·" para espacio

# 📌 Resalta paréntesis y llaves coincidentes
set matchbrackets "()[]{}<>"

# 📌 Evita guardar archivos temporales o backups
set noconvert
set tempfile


EOF

echo "✅ Configuración aplicada en $NANO_CONFIG_PATH"
source "$NANO_CONFIG_PATH"