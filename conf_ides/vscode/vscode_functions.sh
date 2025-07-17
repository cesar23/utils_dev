#!/bin/bash

# ==============================================
# VS CODE SHELL UTILITIES
# ==============================================
# Colección de funciones útiles para trabajar con VS Code desde la terminal.
# Fuente este archivo en tu .bashrc o .zshrc para hacer las funciones disponibles.

# ==============================================
# FUNCIONES PRINCIPALES DE VS CODE
# ==============================================

##
# Abre VS Code en el directorio actual o en la ruta especificada
# Uso: vsc [ruta|archivo]
# Ejemplos:
#   vsc                # Abre el directorio actual
#   vsc ~/proyectos    # Abre la carpeta proyectos
#   vsc archivo.txt    # Abre un archivo específico
##
vsc() {
    if [ $# -eq 0 ]; then
        code .
    else
        code "$@"
    fi
}

##
# Lista las extensiones instaladas en VS Code en formato legible
# Uso: vsc_extensions
##
vsc_extensions() {
    echo -e "\n\033[1mExtensiones instaladas en VS Code:\033[0m"
    code --list-extensions | sort | awk '{printf "• %s\n", $0}'
}

# ==============================================
# GESTIÓN DE EXTENSIONES
# ==============================================

##
# Instala extensiones desde un archivo de texto (una por línea)
# Uso: vsc_install_extensions <archivo>
# Ejemplo: vsc_install_extensions mis_extensiones.txt
##
vsc_install_extensions() {
    if [ ! -f "$1" ]; then
        echo "Error: Archivo $1 no encontrado"
        return 1
    fi

    echo "Instalando extensiones de VS Code desde $1..."
    while read -r extension; do
        code --install-extension "$extension"
    done < "$1"
}

##
# Actualiza todas las extensiones instaladas en VS Code
# Uso: vsc_update_extensions
##
vsc_update_extensions() {
    echo "Actualizando todas las extensiones de VS Code..."
    code --list-extensions | xargs -L 1 code --install-extension --force
}

##
# Exporta las extensiones instaladas a un archivo
# Uso: vsc_export_extensions [archivo]
# Nombre por defecto: vscode-extensions.txt
##
vsc_export_extensions() {
    local output_file=${1:-vscode-extensions.txt}
    code --list-extensions > "$output_file"
    echo "Extensiones exportadas a $output_file"
}

# ==============================================
# INTEGRACIÓN CON GIT
# ==============================================

##
# Abre todos los archivos modificados en VS Code
# Uso: vsc_git_modified
##
vsc_git_modified() {
    git status --porcelain | awk '{print $2}' | xargs code
}

##
# Muestra el diff de git en VS Code
# Uso: vsc_git_diff
##
vsc_git_diff() {
    git diff --name-only | xargs code -d
}

# ==============================================
# OPERACIONES DE ARCHIVOS
# ==============================================

##
# Busca y abre un archivo en VS Code
# Uso: vsc_find <patrón>
# Ejemplos:
#   vsc_find "*.js"      # Busca el primer archivo JS
#   vsc_find "config.*"  # Busca archivos de configuración
##
vsc_find() {
    if [ $# -eq 0 ]; then
        echo "Uso: vsc_find <patrón>"
        return 1
    fi

    local file=$(find . -type f -name "$1" | head -n 1)
    if [ -n "$file" ]; then
        code "$file"
    else
        echo "No se encontraron archivos que coincidan: $1"
    fi
}

##
# Crea un archivo y lo abre en VS Code
# Uso: vsc_touch <archivo>
# Ejemplo: vsc_touch nuevo.txt
##
vsc_touch() {
    if [ $# -eq 0 ]; then
        echo "Uso: vsc_touch <archivo>"
        return 1
    fi

    touch "$1" && code "$1"
}

# ==============================================
# GESTIÓN DE PROYECTOS
# ==============================================

##
# Crea una estructura de proyecto y la abre en VS Code
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
    code .
    echo "Proyecto $1 creado y abierto en VS Code"
}

# ==============================================
# FUNCIONES UTILITARIAS
# ==============================================

##
# Abre VS Code en modo seguro (sin extensiones)
# Uso: vsc_safe [ruta]
##
vsc_safe() {
    code --disable-extensions "${1:-.}"
}

##
# Compara dos archivos en VS Code
# Uso: vsc_diff <archivo1> <archivo2>
##
vsc_diff() {
    if [ $# -ne 2 ]; then
        echo "Uso: vsc_diff <archivo1> <archivo2>"
        return 1
    fi
    code --diff "$1" "$2"
}

# ==============================================
# AYUDANTES DE INSTALACIÓN
# ==============================================

##
# Instala estas funciones en tu configuración de shell
# Uso: vsc_install_functions
##
vsc_install_functions() {
    local shell_rc

    # Detecta el archivo de configuración del shell
    if [ -f ~/.zshrc ]; then
        shell_rc=~/.zshrc
    else
        shell_rc=~/.bashrc
    fi

    # Verifica si ya está instalado
    if grep -q "vscode_functions.sh" "$shell_rc"; then
        echo "Las funciones de VS Code ya están instaladas en $shell_rc"
        return 0
    fi

    # Agrega al archivo de configuración del shell
    echo -e "\n# VS Code Shell Utilities\nsource $(pwd)/vscode_functions.sh" >> "$shell_rc"
    source "$shell_rc"
    echo "¡Funciones de VS Code instaladas correctamente!"
    echo "Reinicia tu terminal o ejecuta 'source $shell_rc'"
}

# ==============================================================================
# 📝 Función: vsc_info
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Muestra una lista de utilidades disponibles para VS Code desde la terminal,
#   junto con una breve descripción de cada función.
#
# 💡 Uso:
#   vsc_info
#
# 📦 Ejemplo:
#   $ vsc_info
#   (Se mostrará la lista de funciones y su descripción)
# ==============================================================================

vsc_info() {
  echo "Utilidades de VS Code cargadas. Funciones disponibles:"
  echo "• vsc                  - Abre VS Code en el directorio actual o en la ruta especificada"
  echo "• vsc_extensions       - Lista las extensiones instaladas en VS Code"
  echo "• vsc_install_extensions <archivo> - Instala extensiones desde un archivo de texto"
  echo "• vsc_update_extensions - Actualiza todas las extensiones instaladas"
  echo "• vsc_export_extensions [archivo]  - Exporta la lista de extensiones a un archivo"
  echo "• vsc_git_modified     - Abre en VS Code los archivos modificados según git"
  echo "• vsc_git_diff         - Muestra el diff de git en VS Code"
  echo "• vsc_find <patrón>    - Busca y abre el primer archivo que coincida con el patrón"
  echo "• vsc_touch <archivo>  - Crea un archivo y lo abre en VS Code"
  echo "• vsc_safe [ruta]      - Abre VS Code sin extensiones (modo seguro)"
  echo "• vsc_diff <f1> <f2>   - Compara dos archivos en VS Code"
  echo "• mkproject <nombre>   - Crea una estructura de proyecto y la abre en VS Code"
  echo "• vsc_install_functions - Instala estas funciones en tu configuración de shell"
}