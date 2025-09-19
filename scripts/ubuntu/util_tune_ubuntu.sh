#!/bin/bash

# util_tune_ubuntu.sh
# Script para actualizar Ubuntu y instalar herramientas esenciales
# Compatible con Ubuntu 24.04.3

set -euo pipefail  # Salir en caso de error

# =============================================================================
# 🎯 SECTION: Variables de Configuración
# =============================================================================
# Fecha y hora actual en formato: YYYY-MM-DD_HH:MM:SS (hora local)
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")
# Fecha y hora actual en Perú (UTC -5)
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d_%H:%M:%S") # Fecha y hora actuales en formato YYYY-MM-DD_HH:MM:SS.
CURRENT_USER=$(id -un)             # Nombre del usuario actual.
CURRENT_USER_HOME="${HOME:-$USERPROFILE}"  # Ruta del perfil del usuario actual.
CURRENT_PC_NAME=$(hostname)        # Nombre del equipo actual.
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"  # Información combinada del usuario y del equipo.
PATH_SCRIPT=$(readlink -f "${BASH_SOURCE:-$0}")  # Ruta completa del script actual.
SCRIPT_NAME=$(basename "$PATH_SCRIPT")           # Nombre del archivo del script.
CURRENT_DIR=$(dirname "$PATH_SCRIPT")            # Ruta del directorio donde se encuentra el script.
NAME_DIR=$(basename "$CURRENT_DIR")              # Nombre del directorio actual.
TEMP_PATH_SCRIPT=$(echo "$PATH_SCRIPT" | sed 's/.sh/.tmp/g')  # Ruta para un archivo temporal basado en el nombre del script.
TEMP_PATH_SCRIPT_SYSTEM=$(echo "${TMPDIR:-/tmp}/${SCRIPT_NAME}" | sed 's/.sh/.tmp/g')  # Ruta para un archivo temporal en /tmp.
ROOT_PATH=$(realpath -m "${CURRENT_DIR}/..")

# Variables para estadísticas
INITIAL_SIZE=0
FINAL_SIZE=0
CLEANED_FILES=0

# =============================================================================
# 🎨 SECTION: Colores para su uso
# =============================================================================
# Definición de colores que se pueden usar en la salida del terminal.

# Colores Regulares
Color_Off='\033[0m'       # Reset de color.
Black='\033[0;30m'        # Negro.
Red='\033[0;31m'          # Rojo.
Green='\033[0;32m'        # Verde.
Yellow='\033[0;33m'       # Amarillo.
Blue='\033[0;34m'         # Azul.
Purple='\033[0;35m'       # Púrpura.
Cyan='\033[0;36m'         # Cian.
White='\033[0;37m'        # Blanco.
Gray='\033[0;90m'         # Gris.

# Colores en Negrita
BBlack='\033[1;30m'       # Negro (negrita).
BRed='\033[1;31m'         # Rojo (negrita).
BGreen='\033[1;32m'       # Verde (negrita).
BYellow='\033[1;33m'      # Amarillo (negrita).
BBlue='\033[1;34m'        # Azul (negrita).
BPurple='\033[1;35m'      # Púrpura (negrita).
BCyan='\033[1;36m'        # Cian (negrita).
BWhite='\033[1;37m'       # Blanco (negrita).
BGray='\033[1;90m'        # Gris (negrita).

# ==============================================================================
# 📝 Función: msg
# ------------------------------------------------------------------------------
# ✅ Descripción:
#   Imprime un mensaje con formato estándar, incluyendo:
#   - Marca de tiempo en UTC-5 (Perú)
#   - Tipo de mensaje (INFO, WARNING, ERROR, o personalizado)
#   - Colores para terminal (si están definidos previamente)
#
# 🔧 Parámetros:
#   $1 - Mensaje a mostrar (texto)
#   $2 - Tipo de mensaje (INFO | WARNING | ERROR | otro) [opcional, por defecto: INFO]
#
# 💡 Uso:
#   msg "Inicio del proceso"               # Por defecto: INFO
#   msg "Plugin no instalado" "WARNING"
#   msg "Error de conexión" "ERROR"
#   msg "Mensaje personalizado" "DEBUG"
#
# 🎨 Requiere:
#   Variables de color: BBlue, BYellow, BRed, BWhite, BGray, Color_Off
# ==============================================================================

msg() {
  local message="$1"
  local level="${2:-INFO}"
  local timestamp
  timestamp=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S")

  local SHOW_DETAIL=1
  if [ -n "${SO_SYSTEM:-}" ] && [ "${SO_SYSTEM:-}" = "termux" ]; then
    SHOW_DETAIL=0
  fi

  case "$level" in
    INFO)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BBlue}[INFO]${Color_Off} ${message}"
        else
          echo -e "${BBlue}${timestamp} - [INFO]${Color_Off} ${message}"
        fi
        ;;
    WARNING)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BYellow}[WARNING]${Color_Off} ${message}"
        else
          echo -e "${BYellow}${timestamp} - [WARNING]${Color_Off} ${message}"
        fi
        ;;
    DEBUG)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BPurple}[DEBUG]${Color_Off} ${message}"
        else
          echo -e "${BPurple}${timestamp} - [DEBUG]${Color_Off} ${message}"
        fi
        ;;
    ERROR)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BRed}[ERROR]${Color_Off} ${message}"
        else
          echo -e "${BRed}${timestamp} - [ERROR]${Color_Off} ${message}"
        fi
        ;;
    SUCCESS)
        if [ "$SHOW_DETAIL" -eq 0 ]; then
          echo -e "${BGreen}[SUCCESS]${Color_Off} ${message}"
        else
          echo -e "${BGreen}${timestamp} - ${BGreen}[SUCCESS]${Color_Off} ${message}"
        fi
        ;;
    *)
          echo -e "${BGray}[OTHER]${Color_Off} ${message}"
        ;;
  esac
}

# =============================================================================
# 🔧 FUNCIONES PRINCIPALES
# =============================================================================

# =============================================================================
# 📝 Función: fn_info_server
# ------------------------------------------------------------------------------
# ✅ Descripción: Muestra información del servidor y banner inicial
# 🔧 Parámetros: Ninguno
# =============================================================================
fn_info_server() {
    # Banner
    echo -e "${BBlue}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                    UTIL TUNE UBUNTU                           ║
║              Actualización y Herramientas Básicas             ║
║                     Ubuntu 24.04.3                            ║
║                                                               ║
║              Ingeniero - Cesar Auris                          ║
║              Teléfono: 937516027                              ║
║              Website: https://solucionessystem.com            ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${Color_Off}"

    # Información del sistema y script
    msg "Script: ${BWhite}${SCRIPT_NAME}${Color_Off}" "INFO"
    msg "Usuario: ${BWhite}${MY_INFO}${Color_Off}" "INFO"
    msg "Fecha: ${BWhite}${DATE_HOUR_PE}${Color_Off}" "INFO"
    msg "Directorio: ${BWhite}${CURRENT_DIR}${Color_Off}" "INFO"
}

# =============================================================================
# 📝 Función: fn_update_system
# ------------------------------------------------------------------------------
# ✅ Descripción: Actualiza el sistema Ubuntu completo
# 🔧 Parámetros: Ninguno
# =============================================================================
fn_update_system() {
    if [[ "$TEST_BASHRC_ONLY" == "true" ]]; then
        msg "🧪 Saltando actualización del sistema en modo testing" "WARNING"
        return 0
    fi
    msg ""
    msg "==========================================" "INFO"
    msg "=== INICIANDO ACTUALIZACIÓN DE UBUNTU ===" "INFO"
    msg "==========================================" "INFO"
    msg ""
    # 1. Actualización de repositorios
    msg "Actualizando lista de repositorios..." "INFO"
    if apt update > /dev/null 2>&1; then
        msg "Lista de repositorios actualizada correctamente" "SUCCESS"
    else
        msg "Error al actualizar repositorios" "ERROR"
        exit 1
    fi

    # 2. Actualización del sistema
    msg "Actualizando el sistema completo..." "INFO"
    if apt upgrade -y > /dev/null 2>&1; then
        msg "Sistema actualizado correctamente" "SUCCESS"
    else
        msg "Error durante la actualización del sistema" "ERROR"
        exit 1
    fi

    # 3. Actualización de distribución
    msg "Actualizando distribución (si hay actualizaciones disponibles)..." "INFO"
    if apt dist-upgrade -y > /dev/null 2>&1; then
        msg "Distribución actualizada correctamente" "SUCCESS"
    else
        msg "Error durante la actualización de distribución" "WARNING"
    fi
}

# =============================================================================
# 📝 Función: fn_install_paquetes
# ------------------------------------------------------------------------------
# ✅ Descripción: Instala paquetes esenciales del sistema
# 🔧 Parámetros: Ninguno
# =============================================================================
fn_install_paquetes() {
    msg ""
    msg "==========================================" "INFO"
    msg "=== INSTALACION DE PAQUETES NECESARIOS ===" "INFO"
    msg "==========================================" "INFO"
    msg ""

    # Lista de paquetes a instalar
    local PACKAGES=(
        "curl"                    # Herramienta para transferir datos
        "wget"                    # Descargador de archivos
        "git"                     # Control de versiones
        "vim"                     # Editor de texto
        "neovim"                  # Editor moderno (nvim)
        "nano"                    # Editor simple
        "htop"                    # Monitor de procesos
        "tree"                    # Visualizador de directorios
        "unzip"                   # Descompresor
        "zip"                     # Compresor
        "build-essential"         # Herramientas de compilación
        "software-properties-common" # Gestión de repositorios
        "apt-transport-https"     # Soporte HTTPS para apt
        "ca-certificates"         # Certificados CA
        "gnupg"                   # Herramientas GPG
        "lsb-release"            # Información de la distribución
        "net-tools"              # Herramientas de red
        "rsync"                  # Sincronización de archivos
        "screen"                 # Multiplexor de terminal
        "tmux"                   # Multiplexor moderno
    )

    # Contadores
    local INSTALLED_COUNT=0
    local ALREADY_INSTALLED_COUNT=0
    local FAILED_COUNT=0

    # Instalar paquetes uno por uno
    for package in "${PACKAGES[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            msg "📦 $package ya está instalado" "INFO"
            ALREADY_INSTALLED_COUNT=$((ALREADY_INSTALLED_COUNT + 1))
        else
            msg "📥 Instalando $package..." "INFO"
            apt install -y "$package" > /dev/null 2>&1
            local exit_code=$?
            if [ $exit_code -eq 0 ]; then
                msg "✅ $package instalado correctamente" "SUCCESS"
                INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
            else
                msg "❌ Error instalando $package" "ERROR"
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        fi
    done

    # Resumen de instalación
    msg "📊 Resumen de instalación:" "INFO"
    echo -e "   ${BGreen}✅ Instalados: $INSTALLED_COUNT${Color_Off}"
    echo -e "   ${BYellow}📦 Ya instalados: $ALREADY_INSTALLED_COUNT${Color_Off}"
    echo -e "   ${BRed}❌ Fallidos: $FAILED_COUNT${Color_Off}"
}

# =============================================================================
# 📝 Función: fn_nvim_configuration
# ------------------------------------------------------------------------------
# ✅ Descripción: Configura Neovim completamente con plugins y temas
# 🔧 Parámetros: Ninguno
# =============================================================================
fn_nvim_configuration() {
    local target_user="${SUDO_USER:-$USER}"
    local user_home
    user_home=$(eval echo "~$target_user")
    msg ""
    msg "==========================================" "INFO"
    msg "=== CONFIGURACIÓN DE NVIM ===" "INFO"
    msg "==========================================" "INFO"
    msg ""

    # Verificar que Neovim esté instalado
    if ! command -v nvim &> /dev/null; then
        msg "❌ Neovim no está instalado. Saltando configuración." "ERROR"
        return 1
    fi

    # Configurar como editor predeterminado
    msg "⚙️  Configurando Neovim como editor predeterminado..." "INFO"
    update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60 > /dev/null 2>&1



    msg "📁 Creando estructura de directorios..."
    mkdir -p ~/.config/nvim
    mkdir -p ~/.config/nvim/colors
    mkdir -p ~/.local/share/nvim/swap
    mkdir -p ~/.local/bin
    touch ~/.config/nvim/init.vim

    # Descargar tema onedark
    msg "🎨 Descargando tema onedark..."
    curl -fLo ~/.config/nvim/colors/onedark.vim --create-dirs \
        https://raw.githubusercontent.com/joshdick/onedark.vim/main/colors/onedark.vim 2>/dev/null

    # Instalar vim-plug (administrador de plugins)
    msg "🔌 Instalando vim-plug..."
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>/dev/null

    # Crear configuración completa init.vim
    msg "📝 Creando configuración init.vim..."
    cat > ~/.config/nvim/init.vim << 'CONFIG_NVIM'
" init.vim - Archivo de configuración de Neovim

" -----------------------------------------
" -- Configuración de vim-plug para gestionar plugins
" -----------------------------------------
call plug#begin('~/.local/share/nvim/plugged')

" Esquema de color onedark
Plug 'joshdick/onedark.vim'

" Explorador de archivos NERDTree
Plug 'preservim/nerdtree'

" Fuzzy finder fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Barra de estado avanzada lightline
Plug 'itchyny/lightline.vim'

" Agregar íconos a NERDTree
Plug 'ryanoasis/vim-devicons'

" Sintaxis múltiple
Plug 'sheerun/vim-polyglot'

" Autocompletado de llaves, corchetes, etc.
Plug 'jiangmiao/auto-pairs'

" Encerrar palabras en paréntesis, corchetes, llaves, etc.
Plug 'tpope/vim-surround'

" Emmet para desarrollo web
Plug 'mattn/emmet-vim'

" Visualiza la indentación en el código
Plug 'Yggdroot/indentLine'

call plug#end()

" -----------------------------------------
" -- Configuración de tabulaciones y espacios
" -----------------------------------------
set expandtab           " Usa espacios en lugar de tabulaciones
set tabstop=4           " Número de espacios que una tabulación representa
set shiftwidth=4        " Tamaño de la indentación
set softtabstop=4       " Número de espacios al usar la tecla de tabulación

" -----------------------------------------
" -- Apariencia
" -----------------------------------------
set cursorline          " Resalta la línea actual
set number              " Muestra número de línea
set relativenumber      " Muestra números de línea relativos
syntax on               " Activa el resaltado de sintaxis
set background=dark     " Usa fondo oscuro
set termguicolors       " Habilita colores verdaderos
colorscheme onedark     " Configura el esquema de color onedark

" Usa una fuente monoespaciada (si la terminal lo soporta)
if has("gui_running")
    set guifont=Monospace\ 12
endif

" -----------------------------------------
" -- Configuración de búsqueda
" -----------------------------------------
set incsearch           " Búsqueda incremental
set hlsearch            " Resalta coincidencias
set ignorecase          " Ignora mayúsculas en la búsqueda
set smartcase           " No ignora mayúsculas si la búsqueda contiene mayúsculas

" -----------------------------------------
" -- Configuración del portapapeles y edición
" -----------------------------------------
set clipboard=unnamedplus   " Usa el portapapeles del sistema
set visualbell              " Desactiva la campana visual

" -----------------------------------------
" -- Autocomandos
" -----------------------------------------
" Restaurar la posición del cursor al abrir un archivo
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif

" -----------------------------------------
" -- Configuración de archivos de intercambio (swap)
" -----------------------------------------
set swapfile                             " Habilita archivos de intercambio
set directory=~/.local/share/nvim/swap// " Directorio para archivos de intercambio

" -----------------------------------------
" -- Mapas de teclas personalizados
" -----------------------------------------
let mapleader=" "          " Configura la tecla líder

" Guardar, salir y guardar y salir
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :wq<CR>

" Mover líneas de código hacia arriba y abajo
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Copiar y pegar desde/para el portapapeles del sistema
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG
vnoremap <leader>p "+p
nnoremap <leader>P gg"+p

" Abrir y cerrar el explorador de archivos NERDTree (espacio+e)
nnoremap <leader>e :NERDTreeToggle<CR>

" Mostrar archivos ocultos en NERDTree
let NERDTreeShowHidden=1

" Navegar entre buffers
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>

" Divisiones de ventana
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>
nnoremap <leader>sc :close<CR>

" Ajustar tamaño de ventanas
nnoremap <C-w><left> :vertical resize -2<CR>
nnoremap <C-w><right> :vertical resize +2<CR>
nnoremap <C-w><up> :resize +2<CR>
nnoremap <C-w><down> :resize -2<CR>

" -----------------------------------------
" -- Configuración de FZF
" -----------------------------------------

" Mapas de teclas para fzf

" Buscar archivos en el proyecto
nnoremap <leader>f :Files<CR>
" Buscar archivos en el repositorio Git
nnoremap <leader>g :GFiles<CR>
" Buscar buffers abiertos
nnoremap <leader>b :Buffers<CR>
" Buscar líneas en el archivo actual
nnoremap <leader>l :Lines<CR>
" Buscar en el historial de comandos
nnoremap <leader>h :History<CR>
" Buscar comandos de Neovim
nnoremap <leader>c :Commands<CR>

" Opciones de fzf
let g:fzf_layout = { 'down': '40%' }  " Muestra fzf en la parte inferior ocupando el 40% de la pantalla

" ------------------------------------
" Abrir en nueva pestaña
" Ctrl-t para abrir en nueva pestaña
" Ctrl-x para abrir en split horizontal
" Ctrl-v para abrir en split vertical
let g:fzf_action = {
    \ 'enter': 'tabedit',
    \ 'ctrl-t': 'tabedit',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit'
    \ }

" -----------------------------------------
" -- Configuración para Python 3
" -----------------------------------------
let g:python3_host_prog = '/usr/bin/python3'

" -----------------------------------------
" -- Otros ajustes
" -----------------------------------------
set showmode             " Muestra el modo actual en la barra de estado

" Configura el esquema de color
colorscheme onedark

" -----------------------------------------
" -- Configuración de lightline
" -----------------------------------------
let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename'
      \ },
      \ }

function! LightlineFilename()
    return expand('%:t')
endfunction

" Para darle la sintaxys a los  ficheros (.cnf, 50-server.cnf , my.cnf)
autocmd BufRead,BufNewFile *.cnf,*.cf,*.local,*.allow,*.deny set filetype=dosini

CONFIG_NVIM

    # Crear script auxiliar 'vi' para acceso rápido
    msg "🔗 Creando script auxiliar 'vi'..."
    cat > ~/.local/bin/vi << 'EOF'
        #!/bin/bash
        # Script auxiliar para acceso rápido a Neovim

        # Función para mostrar el uso del script
        mostrar_uso() {
          echo "Uso: vi [archivo]"
        }

        # Comprueba si se proporciona un argumento
        if [ $# -eq 0 ]; then
          nvim
        else
          if [ -e "$1" ]; then
            nvim "$1"
          else
            echo "Error: El archivo '$1' no existe."
            mostrar_uso
            exit 1
          fi
        fi
EOF

    chmod +x ~/.local/bin/vi

    # Agregar ~/.local/bin al PATH si no está
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        msg "📍 Se agregó ~/.local/bin al PATH en ~/.bashrc"
    fi



    # Cambiar propietario de los archivos creados
    chown -R "$target_user:$target_user" "$user_home/.config/nvim" 2>/dev/null || true
    chown -R "$target_user:$target_user" "$user_home/.local" 2>/dev/null || true

    msg "✅ Configuración completa de Neovim terminada" "SUCCESS"
    msg "📚 Para instalar plugins, ejecuta: nvim +PlugInstall +qall" "INFO"
    msg "🎯 Script 'vi' creado para acceso rápido a nvim" "INFO"
}


# =============================================================================
# 🚀 MAIN SCRIPT: UTIL TUNE UBUNTU
# =============================================================================

# =============================================================================
# 🕐 INICIAR MEDICIÓN DE TIEMPO
# =============================================================================
START_TIME=$(date +%s)
START_TIME_READABLE=$(date "+%Y-%m-%d %H:%M:%S")

# =============================================================================
# 🔧 CONFIGURACIÓN DE PARÁMETROS
# =============================================================================
# Parámetro para testing rápido (omitir instalaciones)
SKIP_PACKAGES=false
TEST_BASHRC_ONLY=false

if [[ "${1:-}" == "--skip-packages" ]]; then
    SKIP_PACKAGES=true
    msg "🚀 Modo testing: omitiendo instalación de paquetes" "WARNING"
elif [[ "${1:-}" == "--test-bashrc" ]]; then
    TEST_BASHRC_ONLY=true
    msg "🧪 Modo testing: solo configuración bashrc" "WARNING"
fi

# Verificar que se ejecuta como root o con sudo (excepto en modo test-bashrc)
if [[ $EUID -ne 0 && "$TEST_BASHRC_ONLY" != "true" ]]; then
   msg "Este script debe ejecutarse como root (sudo)" "ERROR"
   msg "Para testing de bashrc, usa: $0 --test-bashrc" "INFO"
   exit 1
fi

# =============================================================================
# 🚀 EJECUCIÓN PRINCIPAL
# =============================================================================

# 1. Mostrar información del servidor
fn_info_server

# 2. Modo testing de bashrc (salida temprana)
if [[ "$TEST_BASHRC_ONLY" == "true" ]]; then
    msg "🔧 Ejecutando solo configuración de bashrc..." "INFO"
    fn_tuner_bashrc
    msg "✅ Testing de bashrc completado" "SUCCESS"
    exit 0
fi

# 3. Actualizar sistema Ubuntu
fn_update_system

# 4. Instalar paquetes esenciales
if [[ "$SKIP_PACKAGES" == "false" ]]; then
    fn_install_paquetes
else
    msg "⏭️ Omitiendo instalación de paquetes (modo testing)" "WARNING"
fi

# 5. Configurar Neovim
msg "Configurando Neovim completamente..." "INFO"
fn_nvim_configuration



# =============================================================================
# 📊 VERIFICAR VERSIONES Y MOSTRAR INFORMACIÓN
# =============================================================================

# Verificar versiones de herramientas instaladas
msg "Verificando versiones de herramientas instaladas..." "INFO"
echo -e "\n${BBlue}=== VERSIONES INSTALADAS ===${Color_Off}"

check_version() {
    local cmd=$1
    local name=$2
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>/dev/null | head -n1 | sed 's/.*version //g' | sed 's/ .*//g')
        echo -e "${BGreen}✓${Color_Off} ${BWhite}$name${Color_Off}: $version"
    else
        echo -e "${BRed}✗${Color_Off} ${BWhite}$name${Color_Off}: No instalado"
    fi
}

check_version "git" "Git"
check_version "nvim" "Neovim"
check_version "curl" "Curl"
check_version "wget" "Wget"
check_version "vim" "Vim"
check_version "htop" "Htop"
check_version "tmux" "Tmux"
check_version "screen" "Screen"

# Información del sistema
msg "Mostrando información del sistema actualizado..." "INFO"
echo -e "\n${BBlue}=== INFORMACIÓN DEL SISTEMA ===${Color_Off}"
echo -e "${BWhite}Distribución:${Color_Off} $(lsb_release -d | cut -f2)"
echo -e "${BWhite}Kernel:${Color_Off} $(uname -r)"
echo -e "${BWhite}Arquitectura:${Color_Off} $(uname -m)"
echo -e "${BWhite}Usuario ejecutor:${Color_Off} $MY_INFO"
echo -e "${BWhite}Fecha actualización:${Color_Off} $DATE_HOUR_PE"

# =============================================================================
# 🧹 LIMPIEZA DEL SISTEMA
# =============================================================================
msg "Realizando limpieza del sistema..." "INFO"
INITIAL_SIZE=$(df / | tail -1 | awk '{print $3}')

if apt autoremove -y > /dev/null 2>&1; then
    msg "Paquetes obsoletos removidos" "SUCCESS"
else
    msg "Error removiendo paquetes obsoletos" "WARNING"
fi

if apt autoclean > /dev/null 2>&1; then
    msg "Cache de paquetes limpiado" "SUCCESS"
else
    msg "Error limpiando cache de paquetes" "WARNING"
fi

FINAL_SIZE=$(df / | tail -1 | awk '{print $3}')
SPACE_FREED=$((INITIAL_SIZE - FINAL_SIZE))

if [ $SPACE_FREED -gt 0 ]; then
    msg "Espacio liberado: ${BGreen}${SPACE_FREED}KB${Color_Off}" "SUCCESS"
fi

# Actualizar base de datos de locate si existe
if command -v updatedb &> /dev/null; then
    msg "Actualizando base de datos de locate..." "INFO"
    updatedb > /dev/null 2>&1
    msg "Base de datos actualizada" "SUCCESS"
fi

# =============================================================================
# 📋 RESUMEN FINAL
# =============================================================================
echo -e "\n${BGreen}╔═══════════════════════════════════════════════════════════════╗${Color_Off}"
echo -e "${BGreen}║                     ACTUALIZACIÓN COMPLETADA                 ║${Color_Off}"
echo -e "${BGreen}╚═══════════════════════════════════════════════════════════════╝${Color_Off}"

msg "📋 Resumen de lo realizado:" "SUCCESS"
echo "   ✅ Sistema Ubuntu actualizado completamente"
echo "   ✅ Repositorios oficiales actualizados"
echo "   ✅ Herramientas básicas instaladas:"
echo "      • Git (control de versiones)"
echo "      • Neovim (editor moderno)"
echo "      • Curl/Wget (descarga de archivos)"
echo "      • Htop (monitor de sistema)"
echo "      • Tmux/Screen (multiplexores)"
echo "      • Build-essential (herramientas de compilación)"
echo "   ✅ Neovim configurado completamente con plugins y temas"
echo "   ✅ Aliases útiles configurados"
echo "   ✅ Sistema limpio y optimizado"

msg "📝 PASOS SIGUIENTES:" "WARNING"
echo "   • Para instalar plugins, ejecuta: nvim +PlugInstall +qall"
echo "   • Configura Git con: git config --global user.name 'Tu Nombre'"
echo "   • Configura Git con: git config --global user.email 'tu@email.com'"
echo "   • El editor predeterminado ahora es Neovim (nvim)"
echo "   • Usa 'sysinfo' para ver información rápida del sistema"

# =============================================================================
# 🕐 CALCULAR TIEMPO TOTAL DE EJECUCIÓN
# =============================================================================
END_TIME=$(date +%s)
END_TIME_READABLE=$(date "+%Y-%m-%d %H:%M:%S")
DURATION=$((END_TIME - START_TIME))
HOURS=$((DURATION / 3600))
MINUTES=$(((DURATION % 3600) / 60))
SECONDS=$((DURATION % 60))

# Formatear tiempo de duración
if [ $HOURS -gt 0 ]; then
    DURATION_TEXT="${HOURS}h ${MINUTES}m ${SECONDS}s"
elif [ $MINUTES -gt 0 ]; then
    DURATION_TEXT="${MINUTES}m ${SECONDS}s"
else
    DURATION_TEXT="${SECONDS}s"
fi

msg "🎉 ¡Ubuntu actualizado y listo para usar!" "SUCCESS"
msg "Script ejecutado exitosamente: ${BGreen}${SCRIPT_NAME}${Color_Off}" "SUCCESS"
msg "⏱️  Tiempo de ejecución total: ${BGreen}${DURATION_TEXT}${Color_Off}" "INFO"
msg "🕐 Inicio: ${BWhite}${START_TIME_READABLE}${Color_Off}" "INFO"
msg "🕐 Final: ${BWhite}${END_TIME_READABLE}${Color_Off}" "INFO"

echo -e "\n${BCyan}╔═════════════════════════════════════════════════════════════╗${Color_Off}"
echo -e "${BCyan}║                   INFORMACIÓN DE CONTACTO                     ║${Color_Off}"
echo -e "${BCyan}╠═══════════════════════════════════════════════════════════════╣${Color_Off}"
echo -e "${BCyan}║              Ingeniero - Cesar Auris                          ║${Color_Off}"
echo -e "${BCyan}║              Teléfono: 937516027                              ║${Color_Off}"
echo -e "${BCyan}║              Website: https://solucionessystem.com            ║${Color_Off}"
echo -e "${BCyan}║                                                               ║${Color_Off}"
echo -e "${BCyan}║        Gracias por usar UTIL TUNE UBUNTU                      ║${Color_Off}"
echo -e "${BCyan}╚═══════════════════════════════════════════════════════════════╝${Color_Off}"
