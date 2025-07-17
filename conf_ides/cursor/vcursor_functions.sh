#!/bin/bash

# ==============================================
# VS CODE SHELL UTILITIES
# ==============================================
# Colección de funciones útiles para trabajar con VS Code desde la terminal.
# Fuente este archivo en tu .bashrc o .zshrc para hacer las funciones disponibles.

# ==============================================
# FUNCIONES PRINCIPALES DE VS CURSOR
# ==============================================

##
# Abre VS Code en el directorio actual o en la ruta especificada
# Uso: vcursor [ruta|archivo]
# Ejemplos:
#   vcursor                # Abre el directorio actual
#   vcursor ~/proyectos    # Abre la carpeta proyectos
#   vcursor archivo.txt    # Abre un archivo específico
##
vcursor() {
    if [ $# -eq 0 ]; then
        Cursor .
    else
        Cursor "$@"
    fi
}

##
# Lista las extensiones instaladas en VS Code en formato legible
# Uso: vcursor_extensions
##
vcursor_extensions() {
    echo -e "\n\033[1mExtensiones instaladas en VS Cursor:\033[0m"
    Cursor --list-extensions | sort | awk '{printf "• %s\n", $0}'
}

# ==============================================
# GESTIÓN DE EXTENSIONES
# ==============================================

##
# Instala extensiones desde un archivo de texto (una por línea)
# Uso: vcursor_install_extensions <archivo>
# Ejemplo: vcursor_install_extensions mis_extensiones.txt
##
vcursor_install_extensions() {
    if [ ! -f "$1" ]; then
        echo "Error: Archivo $1 no encontrado"
        return 1
    fi

    echo "Instalando extensiones de VS Cursor desde $1..."
    while read -r extension; do
        Cursor --install-extension "$extension"
    done < "$1"
}

##
# Actualiza todas las extensiones instaladas en VS Cursor
# Uso: vcursor_update_extensions
##
vcursor_update_extensions() {
    echo "Actualizando todas las extensiones de VS Cursor..."
    Cursor --list-extensions | xargs -L 1 Cursor --install-extension --force
}

##
# Exporta las extensiones instaladas a un archivo
# Uso: vcursor_export_extensions [archivo]
# Nombre por defecto: vsCursor-extensions.txt
##
vcursor_export_extensions() {
    local output_file=${1:-vsCursor-extensions.txt}
    Cursor --list-extensions > "$output_file"
    echo "Extensiones exportadas a $output_file"
}

# ==============================================
# INTEGRACIÓN CON GIT
# ==============================================

##
# Abre todos los archivos modificados en VS Cursor
# Uso: vcursor_git_modified
##
vcursor_git_modified() {
    git status --porcelain | awk '{print $2}' | xargs Cursor
}

##
# Muestra el diff de git en VS Cursor
# Uso: vcursor_git_diff
##
vcursor_git_diff() {
    git diff --name-only | xargs Cursor -d
}

# ==============================================
# OPERACIONES DE ARCHIVOS
# ==============================================

##
# Busca y abre un archivo en VS Cursor
# Uso: vcursor_find <patrón>
# Ejemplos:
#   vcursor_find "*.js"      # Busca el primer archivo JS
#   vcursor_find "config.*"  # Busca archivos de configuración
##
vcursor_find() {
    if [ $# -eq 0 ]; then
        echo "Uso: vcursor_find <patrón>"
        return 1
    fi

    local file=$(find . -type f -name "$1" | head -n 1)
    if [ -n "$file" ]; then
        Cursor "$file"
    else
        echo "No se encontraron archivos que coincidan: $1"
    fi
}

##
# Crea un archivo y lo abre en VS Cursor
# Uso: vcursor_touch <archivo>
# Ejemplo: vcursor_touch nuevo.txt
##
vcursor_touch() {
    if [ $# -eq 0 ]; then
        echo "Uso: vcursor_touch <archivo>"
        return 1
    fi

    touch "$1" && Cursor "$1"
}

# ==============================================
# GESTIÓN DE PROYECTOS
# ==============================================

##
# Crea una estructura de proyecto y la abre en VS Cursor
# Uso: mkproject <nombre-proyecto>
# Crea:
#   nombre-proyecto/
#     ├── src/
#     ├── docs/
#     ├── assets/
#     └── README.md
##
mkproject() {
    if [ $# -eq 0 ]; then
        echo "Uso: mkproject <nombre-proyecto>"
        return 1
    fi

    mkdir -p "$1"/{src,docs,assets} && \
    cd "$1" && \
    touch README.md && \
    git init && \
    Cursor .
    echo "Proyecto $1 creado y abierto en VS Cursor"
}

# ==============================================
# FUNCIONES UTILITARIAS
# ==============================================

##
# Abre VS Cursor en modo seguro (sin extensiones)
# Uso: vcursor_safe [ruta]
##
vcursor_safe() {
    Cursor --disable-extensions "${1:-.}"
}

##
# Compara dos archivos en VS Cursor
# Uso: vcursor_diff <archivo1> <archivo2>
##
vcursor_diff() {
    if [ $# -ne 2 ]; then
        echo "Uso: vcursor_diff <archivo1> <archivo2>"
        return 1
    fi
    Cursor --diff "$1" "$2"
}

# ==============================================
# AYUDANTES DE INSTALACIÓN
# ==============================================

##
# Instala estas funciones en tu configuración de shell
# Uso: vcursor_install_functions
##
vcursor_install_functions() {
    local shell_rc

    # Detecta el archivo de configuración del shell
    if [ -f ~/.zshrc ]; then
        shell_rc=~/.zshrc
    else
        shell_rc=~/.bashrc
    fi

    # Verifica si ya está instalado
    if grep -q "vcursorode_functions.sh" "$shell_rc"; then
        echo "Las funciones de VS Code ya están instaladas en $shell_rc"
        return 0
    fi

    # Agrega al archivo de configuración del shell
    echo -e "\n# VS Code Shell Utilities\nsource $(pwd)/vcursorode_functions.sh" >> "$shell_rc"
    source "$shell_rc"
    echo "¡Funciones de VS Code instaladas correctamente!"
    echo "Reinicia tu terminal o ejecuta 'source $shell_rc'"
}

# ==============================================================================
# 📝 Función: vcursor_info
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Muestra una lista de utilidades disponibles para VS Code desde la terminal,
#   junto con una breve descripción de cada función.
#
# 💡 Uso:
#   vcursor_info
#
# 📦 Ejemplo:
#   $ vcursor_info
#   (Se mostrará la lista de funciones y su descripción)
# ==============================================================================

vcursor_info() {
  echo "Utilidades de VS Code cargadas. Funciones disponibles:"
  echo "• vcursor                  - Abre VS Code en el directorio actual o en la ruta especificada"
  echo "• vcursor_extensions       - Lista las extensiones instaladas en VS Code"
  echo "• vcursor_install_extensions <archivo> - Instala extensiones desde un archivo de texto"
  echo "• vcursor_update_extensions - Actualiza todas las extensiones instaladas"
  echo "• vcursor_export_extensions [archivo]  - Exporta la lista de extensiones a un archivo"
  echo "• vcursor_git_modified     - Abre en VS Code los archivos modificados según git"
  echo "• vcursor_git_diff         - Muestra el diff de git en VS Code"
  echo "• vcursor_find <patrón>    - Busca y abre el primer archivo que coincida con el patrón"
  echo "• vcursor_touch <archivo>  - Crea un archivo y lo abre en VS Code"
  echo "• vcursor_safe [ruta]      - Abre VS Code sin extensiones (modo seguro)"
  echo "• vcursor_diff <f1> <f2>   - Compara dos archivos en VS Code"
  echo "• mkproject <nombre>   - Crea una estructura de proyecto y la abre en VS Code"
  echo "• vcursor_install_functions - Instala estas funciones en tu configuración de shell"
}