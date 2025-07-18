#!/bin/bash

# Ruta del archivo de configuración en Termux
BASHRC_PATH="$HOME/.bash_profile"

# Respaldo del archivo original si existe
if [ -f "$BASHRC_PATH" ]; then
    cp "$BASHRC_PATH" "$BASHRC_PATH.bak"
    echo "Se ha creado un respaldo en $BASHRC_PATH.bak"
fi

echo "" > $BASHRC_PATH
# Escribir el nuevo contenido en .bashrc
cat > "$BASHRC_PATH" << 'EOF'

VERSION_BASHRC=3.0.0
VERSION_PLATFORM='(TERMUX)'

# ::::::::::::: START CONSTANT ::::::::::::::
DATE_HOUR=$(date -u "+%Y-%m-%d %H:%M:%S") # Fecha y hora actual en formato: YYYY-MM-DD_HH:MM:SS (hora local)
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S") # Fecha y hora actual en Perú (UTC -5)
PATH_BASHRC='~/.bash_profile'  # Ruta del archivo .bashrc
# ::::::::::::: END CONSTANT ::::::::::::::
# ==========================================================================
# VERSION: TERMUX
# START ~/.bashrc - Configuración de Bash por César (version: 1.0.3)
# ==========================================================================

# Este archivo contiene configuraciones personalizadas, alias, funciones,
# y otras optimizaciones para mejorar la experiencia en la terminal.
# Para aplicar cambios después de editar, usa: `source ~/.bashrc`.
# ==========================================================================

# 🧯 Desactiva el cierre automático de la sesión Bash por inactividad.
# TMOUT es una variable especial que cierra la sesión si está inactiva por X segundos.
# Al ponerla en 0, desactivamos ese mecanismo.
export TMOUT=0

# ========================
# 1. Personalización del prompt (PS1)
# ========================
# El prompt es la línea inicial de cada comando en la terminal.
# Esta configuración muestra: usuario@host:directorio_actual (con colores).


# Colores Regulares
Color_Off='\e[0m'       # Reset de color.
Black='\e[0;30m'        # Negro.
Red='\e[0;31m'          # Rojo.
Green='\e[0;32m'        # Verde.
Yellow='\e[0;33m'       # Amarillo.
Blue='\e[0;34m'         # Azul.
Purple='\e[0;35m'       # Púrpura.
Cyan='\e[0;36m'         # Cian.
White='\e[0;37m'        # Blanco.
Gray='\e[0;90m'         # Gris.

# Colores en Negrita
BBlack='\e[1;30m'       # Negro (negrita).
BRed='\e[1;31m'         # Rojo (negrita).
BGreen='\e[1;32m'       # Verde (negrita).
BYellow='\e[1;33m'      # Amarillo (negrita).
BBlue='\e[1;34m'        # Azul (negrita).
BPurple='\e[1;35m'      # Púrpura (negrita).
BCyan='\e[1;36m'        # Cian (negrita).
BWhite='\e[1;37m'       # Blanco (negrita).
BGray='\e[1;90m'        # Gris (negrita).


# Fondo gris oscuro,fondo gris claro
Code_background='\e[7;90;47m'   # Black

# Prompt básico con colores
export PS1='\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$ '

# Agregar información del branch Git al prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/(\1)/p'
}


# ========================================
# Configuración del Prompt
# example output: root@server1 /root/curso_vps (master)#
#export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\$(pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "
export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "



# Si la sesión es SSH, cambia el color del prompt
if [ -n "$SSH_CONNECTION" ]; then
    # ========================================
    # Configuración del Prompt
    # example output: root@server1 (SSH) /root/curso_vps (master)#
    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h (SSH):\[\e[0m\] \[\e[34m\]\$(pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "
    # ::: para servidor Sociedad - spdtss
#    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h (SOCIEDAD):\[\e[0m\] \[\e[34m\]\$(pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "
fi



# ========================
# 2. Alias útiles
# ========================

# Alias básicos
alias ll='ls -lh --color=auto'        # Lista archivos con tamaños legibles
alias la='ls -lha --color=auto'       # Lista todos los archivos, incluidos ocultos
alias ..='cd ..'                      # Subir un nivel en el árbol de directorios
alias ...='cd ../..'                  # Subir dos niveles
alias cls='clear'                     # Limpiar la pantalla
alias grep='grep --color=auto'        # Resaltar coincidencias
alias df='df -h'                      # Mostrar uso de disco en formato legible
alias free='free -m'                  # Mostrar memoria libre en MB
alias h='history'                     # Mostrar historial de comandos

# Alias avanzados
alias search='find . -iname'          # Buscar archivos por nombre
alias bigfiles='du -ah . | sort -rh | head -n 10' # Archivos más grandes
alias newestfile='ls -Art | tail -n 1' # Archivo más reciente
alias ports='netstat -tulnp | grep LISTEN'   # Mostrar puertos abiertos
alias update='pkg update && sudo apt upgrade -y' # Actualizar sistema
alias reload="source $PATH_BASHRC"            # Recargar configuraciones de Bash
alias reload_cat="cat $PATH_BASHRC | less"
# alias efectos
alias mm='cmatrix'             # efecto cmatrix

# ========================
# 3. Historial mejorado
# ========================
# Configura el historial para almacenar más comandos y con formato de fecha y hora.
export HISTSIZE=10000               # Número de comandos guardados en memoria
export HISTFILESIZE=20000           # Número de comandos guardados en disco
export HISTTIMEFORMAT="%F %T "      # Formato de fecha y hora (AAAA-MM-DD HH:MM:SS)
export HISTCONTROL=ignoredups:ignorespace # Ignorar duplicados y comandos con espacio inicial

# ========================
# 4. Variables de entorno
# ========================
export PATH=$PATH:/opt/mis-scripts   # Añadir scripts personalizados al PATH

# Editor de texto predeterminado en terminal
if command -v nvim &> /dev/null; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

# ========================
# 5. Colores para comandos comunes
# ========================
# Mejoras visuales para comandos como `ls` y `grep`.

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Configuración de `dircolors` si está disponible
force_color_prompt=yes
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# ========================
# 6. Funciones personalizadas
# ========================

# Buscar texto en múltiples archivos
search_text() {
    grep -rin "$1" . 2>/dev/null
}
# Ejemplo de uso: search_text "palabra_clave"

# Función: directory_space
# Descripción:
#   Muestra el tamaño ocupado por cada subdirectorio dentro de una ruta dada,
#   ordenado de mayor a menor. Si no se proporciona una ruta como argumento,
#   usa el directorio actual por defecto.
#
# Uso:
#   directory_space [ruta]
#
# Parámetros:
#   ruta (opcional): Ruta del directorio a analizar. Si no se proporciona,
#                    se usará el directorio actual.
#
# Ejemplos:
#   directory_space            # Analiza el directorio actual
#   directory_space /var/log   # Analiza el directorio /var/log
#
# Notas:
#   - Usa 'du' con --max-depth=1 para listar solo el tamaño de cada subdirectorio.
#   - Ordena los resultados en orden descendente por tamaño.
#   - El tamaño total del directorio también se muestra al final.
directory_space() {
    local path="${1:-.}"
    echo "Analizando: $path"
    du -h --max-depth=1 "$path" | sort -rh
}

# Listar los archivos más pesados
# Muestra los archivos más pesados en un directorio.
find_heaviest_files() {
    local directory=${1:-.}  # Directorio a analizar, por defecto es el actual
    local limit=${2:-10}     # Número de archivos a mostrar, por defecto 10

    echo "Buscando los $limit archivos más pesados en el directorio: $directory"
    echo "-----------------------------------------------"
    find "$directory" -type f -exec du -h {} + | sort -rh | head -n "$limit"
}
# Ejemplo de uso: find_heaviest_files "/var/log" 5

# Buscar archivos por tamaño
# Muestra archivos con un tamaño mayor al especificado.
find_files_by_size() {
    local directory=${1:-.}     # Directorio a analizar, por defecto es el actual.
    local size=${2:-1M}         # Tamaño mínimo de los archivos, por defecto 1 Megabyte.

    # Verificar si el directorio existe
    if [ ! -d "$directory" ]; then
        echo "Error: El directorio '$directory' no existe."
        return 1
    fi

    echo "Buscando archivos en '$directory' con un tamaño mayor a $size:"
    echo "------------------------------------------------------------"
    find "$directory" -type f -size +"$size" -exec du -h {} + 2>/dev/null | sort -rh
}
# Ejemplo de uso: find_files_by_size . 5M

# Iniciar un servidor HTTP simple
# Inicia un servidor HTTP en el puerto especificado.
simple_server() {
    local port=${1:-8000}
    echo "Servidor disponible en http://localhost:$port"
    python3 -m http.server "$port"
}
# Ejemplo de uso: simple_server 8080

# Generar claves SSH
# Genera una clave SSH con una etiqueta específica.
generar_ssh() {
    ssh-keygen -t rsa -b 4096 -C "$1"
    echo "Clave SSH generada para: $1"
}
# Ejemplo de uso: generar_ssh usuario@dominio.com

# Comparar archivos
# Compara dos archivos mostrando las diferencias lado a lado.
comparar() {
    diff -y "$1" "$2"
}
# Ejemplo de uso: comparar archivo1.txt archivo2.txt

# Controlar CyberPanel
# Detiene y deshabilita el servicio de CyberPanel.
stop_cyber_panel() {
    systemctl stop lscpd && systemctl disable lscpd && systemctl status lscpd
}
# Ejemplo de uso: stop_cyber_panel

# Inicia y habilita el servicio de CyberPanel.
start_cyber_panel() {
    systemctl enable lscpd && systemctl start lscpd && systemctl status lscpd
}
# Ejemplo de uso: start_cyber_panel

###############################################
# 📄 FUNCTION: listar_archivos_recientes_modificados
###############################################
# Lists the most recently modified files in a given directory.
#
# @param $1 - Directory path to scan (default: .)
# @param $2 - Number of files to display (default: 10)
#
# @return Prints the most recently modified files with their date and time.
#
# 🧪 Example usage:
#   listar_archivos_recientes_modificados "/var/www/html" 15
#   listar_archivos_recientes_modificados "/home/user"
#   listar_archivos_recientes_modificados
###############################################
listar_archivos_recientes_modificados() {
  local path="${1:-.}"         # Default path: current directory
  local count="${2:-10}"       # Default count: 10 files

  if [ ! -d "$path" ]; then
    echo "❌ Error: '$path' is not a valid directory."
    return 1
  fi

  echo "📁 Showing the last $count modified files in: $path"
  echo "─────────────────────────────────────────────────────────────"

  find "$path" -type f -printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n' \
    | sort \
    | tail -n "$count"
}


# ----------------------------------------
# Function: detect_system
# Detects the operating system distribution.
# Returns:
#   - "termux"  -> If running in Termux
#   - "wsl"     -> If running on Windows Subsystem for Linux
#   - "ubuntu"  -> If running on Ubuntu/Debian-based distributions
#   - "redhat"  -> If running on Red Hat, Fedora, CentOS, Rocky, or AlmaLinux
#   - "gitbash" -> If running on Git Bash
#   - "unknown" -> If the system is not recognized
#
# Example usage:
#   system=$(detect_system)
#   echo "Detected system: $system"
# ----------------------------------------
detect_system() {
    if [ -f /data/data/com.termux/files/usr/bin/pkg ]; then
        echo "termux"
    elif grep -q Microsoft /proc/version; then
        echo "wsl"
    elif [ -f /etc/os-release ]; then
        # Lee el ID de /etc/os-release
        source /etc/os-release
        case $ID in
            ubuntu|debian)
                echo "ubuntu"
                ;;
            rhel|centos|fedora|rocky|almalinux)
                echo "redhat"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    elif [ -n "$MSYSTEM" ]; then
        echo "gitbash"
    else
        echo "unknown"
    fi
}

# ----------------------------------------
# Function: install_package
# Installs a package based on the detected operating system.
#
# Parameters:
#   $1 -> Name of the package to install
#
# Example usage:
#   install_package fzf
#   install_package neovim
#
# Notes:
# - If running on Git Bash, it only supports installing fzf.
# - If the system is unrecognized, manual installation is required.
# ----------------------------------------
install_package() {
    package=$1  # Package name

    case "$system" in
        ubuntu|wsl)
            echo "🟢 Installing $package on Ubuntu/Debian..."
            sudo apt update -y && sudo apt install -y "$package"
            ;;
        redhat)
            echo "🔵 Installing $package on Red Hat/CentOS/Fedora..."
            # Usa dnf si está disponible, sino yum
            if command -v dnf &> /dev/null; then
                sudo dnf install -y "$package"
            else
                sudo yum install -y "$package"
            fi
            ;;
        termux)
            echo "📱 Installing $package on Termux..."
            pkg update -y && pkg install -y "$package"
            ;;
        gitbash)
            if [ "$package" == "fzf" ]; then
                echo "🪟 Installing fzf on Git Bash..."
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install --all
            fi
            ;;
        *)
            echo "❌ Unrecognized system. Please install $package manually."
            ;;
    esac
}
# ----------------------------------------
# Function: check_and_install
# Checks if a package is installed, if not, installs it.
#
# Parameters:
#   $1 -> Name of the package to check and install
#   $2 -> Command to check in terminal (optional, defaults to $1)
#
# Example usage:
#   check_and_install fzf
#   check_and_install bat batcat
# ----------------------------------------
check_and_install() {
    local package="$1"  # Package name
    local command_to_check="${2:-$1}"  # Command to check (defaults to package name)

    # Primero prueba con 'which' si está disponible, de lo contrario usa 'command -v'
    if command -v which &> /dev/null; then
        if ! which "$command_to_check" &> /dev/null; then
            echo "⚠️ Command '${command_to_check}' (package: ${package}) is not installed. Installing now..."
            install_package "$package"
        fi
    else
        if ! command -v "$command_to_check" &> /dev/null; then
            echo "⚠️ Command '${command_to_check}' (package: ${package}) is not installed. Installing now..."
            install_package "$package"
        fi
    fi
}



mostrar_uso() {
  echo "Uso: vi [archivo]"
}


vi() {
    if [ -f "$1" ]; then
        if command -v nvim &> /dev/null; then
            nvim "$1"
        else
            vim "$1"
        fi

    else
        echo -en "--- ${Red}Error: El archivo '$1' no existe.${Color_Off} \n"
        mostrar_uso
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Function: show_date
# Description: Displays the current date and time in three formats:
#              - Readable format in Spanish (local system time)
#              - UTC time
#              - Peru time (calculated as UTC -5)
# Usage: Call the function without arguments: show_date
# -----------------------------------------------------------------------------
show_date() {
    # Readable date in Spanish
    readable_date=$(LC_TIME=es_ES.UTF-8 date "+%A %d de %B de %Y, %H:%M:%S")

    # Date in UTC
    utc_date=$(date -u "+%Y-%m-%d %H:%M:%S UTC")

    # Date in Peru (UTC -5)
    peru_date=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S UTC-5")

    # Display results
    echo "Fecha actual (formato legible): $readable_date"
    echo "Fecha actual en UTC:            $utc_date"
    echo "Fecha actual en Perú (UTC-5):   $peru_date"
}
# ==============================================================================
# 📦 Función: create_file
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Crea un archivo con contenido ingresado en múltiples líneas desde la terminal
#   (finalizando con Ctrl+D). Si no se pasa un nombre de archivo como parámetro,
#   lo solicita interactivamente. Luego marca el archivo como ejecutable.
#
# 💡 Uso:
#   create_file              # Solicita nombre interactivo
#   create_file fichero.txt  # Usa nombre pasado como parámetro
#
# 🎨 Requiere:
#   - Permiso de escritura en el directorio actual
#   - Variables de color definidas previamente
# ==============================================================================
create_file() {
  local FILE_NAME="$1"

  echo ""

  # Si no se pasa como parámetro, pedirlo al usuario
  if [ -z "$FILE_NAME" ]; then
    echo -e "${BBlue}✏️️  Nombre del archivo a crear (ej. mi_script.sh):${Color_Off}"
    read -rp "> " FILE_NAME
  fi

  if [ -z "$FILE_NAME" ]; then
    echo -e "${BRed}❌ Error: Debes ingresar un nombre de archivo válido.${Color_Off}"
    return 1
  fi

  if [ -f "$FILE_NAME" ]; then
    echo -e "${BYellow}⚠️  El archivo ya existe. ¿Deseas sobrescribirlo? [s/n]${Color_Off}"
    read -rp "> " RESP
    [[ "$RESP" != [sS] ]] && echo -e "${BRed}❌ Cancelado.${Color_Off}" && return 1
  fi

  echo ""
  echo -e "${BPurple}✏️  Escribe el contenido del archivo (Ctrl+D para finalizar):${Color_Off}"
  CONTENT=$(cat)

  echo "$CONTENT" > "$FILE_NAME"
  chmod +x "$FILE_NAME"

  echo ""
  echo -e "${BGreen}✅ Archivo '$FILE_NAME' creado correctamente y marcado como ejecutable.${Color_Off}"
}

# ========================
# 6. Verificar y instalar paquetes necesarios
# ========================

# Detect operating system
system=$(detect_system)

# Check and install fzf if not installed (no message if already installed)
check_and_install fzf fzf
check_and_install tree tree
check_and_install bat bat
check_and_install neovim nvim
check_and_install net-tools netstat

# ========================
# 7. Menú interactivo
# ========================

alias ls='ls --color=auto'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi


# Verificar si el sistema operativo es Linux
if [[ "$(uname -s)" == "Linux" ]]; then
    # echo "El sistema operativo es Linux. Configurando ulimit..."
    ulimit -n 4096
fi



menu(){
  echo -e "${Gray}========================${Color_Off}"
  echo -e "${Gray}VERSION_BASHRC: ${VERSION_BASHRC}${Color_Off}"
  echo -e "${Gray}VERSION_PLATFORM: ${VERSION_PLATFORM}${Color_Off}"
  echo -e "${Gray}------------------------${Color_Off}"
  echo -e "${Gray}Fecha UTC:        $DATE_HOUR${Color_Off}"
  echo -e "${Gray}Fecha UTC-5 (PE): $DATE_HOUR_PE${Color_Off}"
  echo -e "${Gray}========================${Color_Off}"
  echo -e ""
  echo -e "${Gray}Seleccione una opción:${Color_Off}"
  echo -e "${Gray}1) Opciones Generales${Color_Off}"
  echo -e "${Gray}2) Navegacion${Color_Off}"
  echo -e "${Gray}3) Docker${Color_Off}"
  echo -e "${Gray}4) Docker Comandos${Color_Off}"
  echo -e "${Gray}5) CyberPanel${Color_Off}"
  echo -e "${Gray}6) FZF${Color_Off}"
  echo -e "${Gray}7) Script Python${Color_Off}"
  echo -e "${Gray}8) Ficheros de configuración${Color_Off}"
  echo -e "${Gray}9) Salir${Color_Off}"
  read -p "Seleccione una opción (Enter para salir): " opt
  case $opt in
    1) submenu_generales ;;
    2) menu_search ;; # esto es del fichero ./libs_shell/gitbash/func_navegacion.sh
    3) submenu_docker ;;
    4) submenu_docker_comandos ;;
    5) submenu_cyberpanel ;;
    6) submenu_fzf ;;
    7) submenu_python_utils ;;
    8) submenu_ficheros_configuracion ;;
    9) return ;;
    "") return ;;  # Si se presiona Enter sin escribir nada, salir
  *) echo -e "${Red}Opción inválida${Color_Off}" ; menu ;;
  esac
}
submenu_generales(){
  cls
  echo -e "${Yellow}Submenú Opciones disponibles:${Color_Off}"
  echo -e "${Gray}   - create_file : ${Cyan}Crear un fichero de manera manual${Color_Off}"
  echo -e "${Gray}   - listar_archivos_recientes_modificados : ${Cyan} ficheros recientes y modificados  Ejemplo: listar_archivos_recientes_modificados '/var/www/html' 15${Color_Off}"
  echo -e "${Gray}   - generar_ssh : ${Cyan}Generar claves SSH. Ejemplo: generar_ssh usuario@dominio.com${Color_Off}"
  echo -e "${Gray}   - comparar : ${Cyan}Comparar dos archivos. Ejemplo: comparar archivo1.txt archivo2.txt${Color_Off}"
  echo -e "${Gray}   - search_text : ${Cyan}Buscar texto en múltiples archivos del directorio actual. Ejemplo: search_text 'texto_a_buscar'${Color_Off}"
  echo -e "${Gray}   - directory_space : ${Cyan}Ver peso de sus directorios pasar el path opcional . Ejemplo: directory_space '/var/www'${Color_Off}"
  echo -e "${Gray}   - find_files_by_size : ${Cyan}Archivos por tamaño. Ejemplo: find_files_by_size . 5M${Color_Off}"
  echo -e "${Gray}   - find_heaviest_files : ${Cyan}Listar los archivos más pesados en un directorio. Ejemplo: find_heaviest_files /ruta/al/directorio 10${Color_Off}"
  echo -e "${Gray}   - simple_server : ${Cyan}Iniciar un servidor HTTP simple en el puerto especificado (por defecto 8000). Ejemplo: simple_server 8080${Color_Off}"
  echo -e "${Gray}Utilidades Red:${Color_Off}"
  echo -e "${Gray}   - Obtener Ip Publica : ${Cyan}curl checkip.amazonaws.com${Color_Off}"
  echo -e "${Gray}Alias básicos disponibles:${Color_Off}"
  echo -e "${Gray}   - ll : ${Cyan}Lista archivos con tamaños legibles (ls -lh).${Color_Off}"
  echo -e "${Gray}   - la : ${Cyan}Lista todos los archivos, incluidos ocultos (ls -lha).${Color_Off}"
  echo -e "${Gray}   - rm : ${Cyan}Borrar archivos con confirmación.${Color_Off}"
  echo -e "${Gray}   - cp : ${Cyan}Copiar archivos con confirmación.${Color_Off}"
  echo -e "${Gray}   - mm : ${Cyan}Efecto Hacker${Color_Off}"
  echo -e "${Gray}   - mv : ${Cyan}Mover archivos con confirmación.${Color_Off}"
  echo -e "${Gray}   - cls : ${Cyan}Limpiar la pantalla.${Color_Off}"
  echo -e "${Gray}Alias avanzados disponibles:${Color_Off}"
  echo -e "${Gray}   - search : ${Cyan}Buscar archivos por nombre. Ejemplo: search '*.log'${Color_Off}"
  echo -e "${Gray}   - bigfiles : ${Cyan}Mostrar los 10 archivos más grandes en el directorio actual.${Color_Off}"
  echo -e "${Gray}   - newestfile : ${Cyan}Mostrar el archivo más reciente del directorio actual.${Color_Off}"
  echo -e "${Gray}Configuraciones adicionales:${Color_Off}"
  echo -e "${Gray}   - ulimit -n 4096 : ${Cyan}Incrementa el límite de archivos abiertos.${Color_Off}"
  echo -e "${Gray}   - history : ${Cyan}Historial extendido con fecha y hora.${Color_Off}"
  echo -e "${Gray}   - PATH : ${Cyan}Incluye scripts personalizados en /opt/mis-scripts.${Color_Off}"
}

submenu_docker(){
  cls
  echo -e "${Yellow}Submenú Docker:${Color_Off}"
  echo -e "${Gray}   - d : ${Cyan}docker${Color_Off}"
  echo -e "${Gray}   - dps : ${Cyan}docker ps${Color_Off}"
  echo -e "${Gray}   - di : ${Cyan}docker images${Color_Off}"
  echo -e "${Gray}   - drm : ${Cyan}docker rm -f${Color_Off}"
  echo -e "${Gray}   - drmi : ${Cyan}docker rmi${Color_Off}"
  echo -e "${Gray}   - dlog : ${Cyan}docker logs -f${Color_Off}"
  echo ""
  echo -e "${Gray}   - dc : ${Cyan}docker-compose ${Color_Off}"
  echo -e "${Gray}   - dcu : ${Cyan}docker-compose up -d ${Color_Off}"
  echo -e "${Gray}   - dcd : ${Cyan}docker-compose down ${Color_Off}"
  echo -e "${Gray}   - dcb : ${Cyan}docker-compose build ${Color_Off}"
  echo -e "${Gray}   - dcr : ${Cyan}docker-compose restart ${Color_Off}"
  echo ""
  echo -e "${Gray}   - dinspect : ${Cyan}Inspecionar contenedor - Uso: dinspect <nombre_contenedor> ${Color_Off}"
  echo -e "${Gray}   - dlogin : ${Cyan}Listar e Ingresar a contenedor - Uso: dit ${Color_Off}"
  echo -e "${Gray}   - droot : ${Cyan}Listar e Ingresar a contenedor MODO : ROOT- Uso: dit ${Color_Off}"
  echo -e "${Gray}   - dcrestart : ${Cyan}docker-compose down && docker-compose up -d ${Color_Off}"
}

submenu_docker_comandos(){
  cls
  curl -sSL https://raw.githubusercontent.com/cesar23/utils_dev/master/binarios/linux/util/docker_info.sh | bash

}


submenu_cyberpanel(){
  cls
  echo -e "${Yellow}Submenú Configuraciones CyberPanel:${Color_Off}"
  echo -e "${Gray}   - stop_cyber_panel : ${Cyan}Detener CyberPanel.${Color_Off}"
  echo -e "${Gray}   - start_cyber_panel : ${Cyan}Iniciar CyberPanel.${Color_Off}"
}

submenu_fzf(){
  cls
  echo -e "${Yellow}Submenú FZF:${Color_Off}"
  echo -e "${Gray}   - sd : ${Cyan}Buscar y cambiar de directorio.${Color_Off}"
  echo -e "${Gray}   - sde : ${Cyan}Navegación estilo explorador de Windows.${Color_Off}"
  echo -e "${Gray}   - sf : ${Cyan}Buscar archivos excluyendo carpetas y tipos de archivos.${Color_Off}"
  echo -e "${Gray}   - sff : ${Cyan}Buscar archivos sin exclusiones.${Color_Off}"
}

submenu_python_utils(){
  cls
  echo -e "${Yellow}Submenú Comandos Python:${Color_Off}"
  echo -e "${Gray}   - run_server_py : ${Cyan}Crea un servidor de explorador de ficheros.${Color_Off}"
  echo -e "${Gray}        ${Yellow}Ejemplos de uso:${Color_Off}"
  echo -e "${Gray}            ${Purple}run_server_py  :${Cyan}directorio actual.${Color_Off}"
  echo -e "${Gray}            ${Purple}run_server_py 9090 : ${Cyan}directorio actual y con puerto 9090.${Color_Off}"
  echo -e "${Gray}            ${Purple}run_server_py 9090 /d/repos : ${Cyan}puerto y directorio pasado por parametro.${Color_Off}"
  echo -e "${Gray}   - optimize_img_dir : ${Cyan} ${Yellow}(solo Linux)${Color_Off} ${Cyan}Comprime Recursivamente imagenes tipo (jpg,png) en el directorio actual o pasandole un path ejemplo: optimize_img_dir '/mnt/e/imgs'  ${Color_Off}"

}

submenu_ficheros_configuracion(){
  cls
  echo -e "${Yellow}Submenú Ficheros Configuracion:${Color_Off}"
  echo -e "${Code_background} ~/.bashrc ${Color_Off}${Cyan} → Configuración del shell interactivo (para Bash).${Color_Off}"
  echo -e "${Code_background} /etc/network/interfaces ${Cyan} → Configuración de la red (Debian/Ubuntu).${Color_Off}"
  echo -e "${Code_background} /etc/sysconfig/network-scripts/ifcfg-eth0 ${Cyan} → Configuración de la red (RHEL/CentOS)..${Color_Off}"
  echo -e "${Code_background} /etc/resolv.conf ${Cyan} → Configuración de servidores DNS..${Color_Off}"
  echo -e "${Code_background} /etc/hosts.allow y /etc/hosts.deny ${Cyan} → Control de acceso a servicios..${Color_Off}"
  echo -e "${Code_background} /etc/nsswitch.conf ${Cyan} → Orden de búsqueda de nombres de host..${Color_Off}"
  echo -e "${Code_background} /etc/hostname ${Cyan} → Nombre del host del sistema..${Color_Off}"
  echo -e "${Code_background} /etc/iptables/rules.v4 y /etc/iptables/rules.v6 ${Cyan} → Configuración de reglas de firewall (si usa iptables)..${Color_Off}"

}


#    ./conf_funciones_level_2.sh
#    ./conf_funciones_level_2.sh 9090
#    ./conf_funciones_level_2.sh 9090 /E/deysi^

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: (Optional)Cargar Script si queremos poner adicionales
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::

scriptPath2=${0%/*}
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(exec /usr/bin/hostname)
INFO_PC="${CURRENT_USER}@${CURRENT_PC_NAME}"

# :::::::: Importanmos las librerias
if [ -f "${HOME}/libs_shell/init.sh" ]; then
 source "${HOME}/libs_shell/init.sh"
fi



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: (Optional) FZF
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::




# ================== Aliases ==================
# Alias para usar 'batcat' como 'bat' en lugar de 'batcat'
alias bat="batcat"

# ------------------------- Funciones útiles -------------------------

# sd - Función para buscar y cambiar directorios recursivamente usando fzf
# Ejemplo de uso:
#   sd         # Busca directorios en el directorio actual y navega entre ellos.
#   sd /path   # Busca directorios dentro de /path.
function sd() {
  local dir
  # Busca directorios en el directorio actual o en el especificado, luego usa fzf para seleccionar uno.
  dir=$(find "${1:-.}" -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# sde - Función que permite navegar entre directorios como un explorador de Windows
# Ejemplo de uso:
#   sde       # Navega entre directorios, incluyendo opción para retroceder con ".."
function sde() {
  # Configuración de fzf
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
  bind '"\C-r": " \C-a\C-k\C-r\C-y\ey\C-m"'

  while true; do
    # Usa un array para manejar correctamente directorios con espacios
    dirs=("..")

    # Añade los directorios a la lista
    while IFS= read -r -d $'\0' dir; do
        dirs+=("$dir")
    done < <(find . -maxdepth 1 -type d -print0)

    # Usa fzf para seleccionar un directorio, manejando correctamente los nombres con espacios
    dir=$(printf "%s\n" "${dirs[@]}" | fzf --header "Selecciona un directorio ('..' para retroceder)")

    if [[ -n "$dir" ]]; then
      if [[ "$dir" == ".." ]]; then
        cd ..
      else
        cd "$dir"
      fi
     echo -e "${Gray}Estás en: $(pwd)" # Muestra la ruta actual
    else
      break  # Sale del bucle si no se selecciona nada
    fi
  done

}

# sf - Función para buscar archivos excluyendo carpetas y tipos de ficheros específicos
# Ejemplo de uso:
#   sf        # Busca archivos excluyendo ficheros no deseados y los abre en nvim
function sf() {
  export FZF_DEFAULT_OPTS="--height 100% --layout=reverse --border"
  bind '"\C-r": " \C-a\C-k\C-r\C-y\ey\C-m"'

  # Verificar si fzf está instalado
  if which fzf > /dev/null; then
    # Encuentra archivos, excluyendo carpetas y tipos de ficheros no deseados
         # Verificamos si existe bactcat
     if command -v batcat &> /dev/null; then
         # Busca todos los archivos sin restricciones
        find . -type d \( -iname '$RECYCLE.BIN' -o \
                      -iname '.git' -o \
                      -iname 'node_modules' -o \
                      -iname 'dist' \) -prune -o -type f \( -not -iname '*.dll' -a \
                                                            -not -iname '*.exe' \) -print \
            | fzf --preview 'batcat --style=numbers --color=always --line-range :500 {}' \
            | xargs -r nvim  # Abre el archivo seleccionado en nvim
     else
         find . -type d \( -iname '$RECYCLE.BIN' -o \
                      -iname '.git' -o \
                      -iname 'node_modules' -o \
                      -iname 'dist' \) -prune -o -type f \( -not -iname '*.dll' -a \
                                                            -not -iname '*.exe' \) -print \
            | fzf --preview 'cat {}' \
            | xargs -r nvim  # Abre el archivo seleccionado en nvim
     fi


  else
    echo "fzf no está instalado."
  fi
}

# sff - Función para buscar archivos sin omitir ningún fichero o carpeta
# Ejemplo de uso:
#   sff       # Busca cualquier archivo en el directorio actual y lo abre en nvim
function sff() {
  export FZF_DEFAULT_OPTS="--height 100% --layout=reverse --border"
  bind '"\C-r": " \C-a\C-k\C-r\C-y\ey\C-m"'

  # Verificar si fzf está instalado
  if which fzf > /dev/null; then

     # Verificamos si existe bactcat
     if command -v batcat &> /dev/null; then
         # Busca todos los archivos sin restricciones
        find . -print \
        | fzf --preview 'batcat --style=numbers --color=always --line-range :500 {}' \
        | xargs -r nvim  # Abre el archivo seleccionado en nvim
     else
         find . -print \
        | fzf --preview 'cat {}' \
        | xargs -r nvim  # Abre el archivo seleccionado en nvim
     fi



  else
    echo "fzf no está instalado."
  fi
}

# ================================================
# ====================== docker ==================
# ================================================
# Alias básicos para Docker
alias d="docker"              # Abreviatura para Docker
alias dps="docker ps"         # Mostrar contenedores en ejecución
alias di="docker images"      # Listar imágenes
alias drm="docker rm -f"      # Eliminar contenedor forzadamente
alias drmi="docker rmi"       # Eliminar imagen
alias dlog="docker logs -f"   # Ver logs en tiempo real

# Alias básicos para Docker Compose
alias dc="docker-compose"     # Abreviatura para Docker Compose
alias dcu="docker-compose up -d"   # Iniciar servicios en segundo plano
alias dcd="docker-compose down"    # Detener y eliminar servicios
alias dcb="docker-compose build"   # Construir servicios
alias dcr="docker-compose restart" # Reiniciar servicios

# ----------- Funciones


dinspect() {
    if [ -z "$1" ]; then
        echo "Uso: dinspect <nombre_contenedor>"
    else
        docker inspect "$1"
    fi
}



# Función para listar contenedores en ejecución
listar_contenedores() {
    echo -e "${Cyan}Contenedores en ejecución:${Color_Off}"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
}
    # Función para entrar al contenedor
entrar_contenedor() {
    local CONTAINER=$1

    # Intenta usar bash, si no existe, usa sh (/bin/bash  o bash)
    echo -e "${Green}Entrando al contenedor '${Yellow}$CONTAINER${Green}'...${Color_Off}"
    echo -e "${Gray}docker exec -it "$CONTAINER" bash ${Color_Off}"
    if docker exec -it "$CONTAINER" bash 2>/dev/null; then
        return 0
    else
        echo -e "${Yellow}bash no está disponible en el contenedor, intentando con sh...${Color_Off}"
        docker exec -it "$CONTAINER" /bin/sh
        return $?
    fi
}

dlogin(){
  cls 2>/dev/null || clear

    # Flujo principal del script
    listar_contenedores

    echo -e "${Yellow}"
    read -p "Ingrese el nombre o ID del contenedor: " CONTAINER
    echo -e "${Color_Off}"

    # Validar entrada del usuario
    if [ -z "$CONTAINER" ]; then
        echo -e "${Red}Error: No se ingresó un nombre o ID de contenedor.${Color_Off}"
        return 1
    fi

    # Intentar entrar al contenedor
    entrar_contenedor "$CONTAINER"
    RET=$?

    # Mensaje final según el resultado
    if [ $RET -eq 0 ]; then
        echo -e "${Green}Sesión del contenedor finalizada correctamente.${Color_Off}"
    else
        echo -e "${Red}Hubo un problema al intentar acceder al contenedor.${Color_Off}"
    fi


}
droot() {
    listar_contenedores
    echo -e "${Yellow}"
    read -p "Ingrese el nombre o ID del contenedor: " CONTAINER
    echo -e "${Color_Off}"

    docker exec -it --user root "$CONTAINER" bash

}

dcrestart() {
    docker-compose down && docker-compose up -d
}
# ==========================================================================
# END ~/.bashrc - Configuración de Bash por César
# ==========================================================================

EOF

echo "✅ Configuración aplicada en $BASHRC_PATH"
source "$BASHRC_PATH"