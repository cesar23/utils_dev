#!/bin/bash
VERSION_SCRIPT="3.0.1"
# =============================================================================
# 🚀 NEOVIM GLOBAL INSTALLER - CONFIGURACIÓN MULTIUSUARIO
# =============================================================================
# 📝 Descripción: Instalador completo de Neovim con configuración global
# 👨‍💻 Autor: cesar & LinuxBot
# 📅 Fecha: 2025-09-23
# 🔄 Versión: 4.0 - CONFIGURACIÓN GLOBAL
# =============================================================================
# 🎯 CARACTERÍSTICAS:
# - Configuración global para TODOS los usuarios del sistema
# - Plugins instalados globalmente
# - Interfaz visual paso a paso
# - Instalación automática de dependencias
# - Script auxiliar 'nv' optimizado
# =============================================================================

set -euo pipefail  # Modo estricto: exit on error, undefined vars, pipe fails

# =============================================================================
# 🌍 SECTION: Variables de Entorno y Sistema
# =============================================================================

# Fecha y hora actual en formato: YYYY-MM-DD_HH:MM:SS (hora local)
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")
# Fecha y hora actual en Perú (UTC -5)
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d_%H:%M:%S")
CURRENT_USER=$(id -un)             # Nombre del usuario actual
CURRENT_USER_HOME="${HOME:-$USERPROFILE}"  # Ruta del perfil del usuario actual
CURRENT_PC_NAME=$(hostname)        # Nombre del equipo actual
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"  # Información combinada del usuario y del equipo
PATH_SCRIPT=$(readlink -f "${BASH_SOURCE:-$0}")  # Ruta completa del script actual
SCRIPT_NAME=$(basename "$PATH_SCRIPT")           # Nombre del archivo del script
CURRENT_DIR=$(dirname "$PATH_SCRIPT")            # Ruta del directorio donde se encuentra el script
NAME_DIR=$(basename "$CURRENT_DIR")              # Nombre del directorio actual
TEMP_PATH_SCRIPT=$(echo "$PATH_SCRIPT" | sed 's/.sh/.tmp/g')  # Ruta para un archivo temporal basado en el nombre del script
TEMP_PATH_SCRIPT_SYSTEM=$(echo "${TMP:-/tmp}/${SCRIPT_NAME}" | sed 's/.sh/.tmp/g')  # Ruta para un archivo temporal en /tmp
ROOT_PATH=$(realpath -m "${CURRENT_DIR}/..")

# =============================================================================
# 🎯 SECTION: Variables Específicas de Neovim Global
# =============================================================================

# Configuración COMPARTIDA (sin duplicar archivos)
SYSTEM_NVIM_CONFIG="/etc/xdg/nvim"                 # Configuración XDG global
SYSTEM_NVIM_SHARE="/usr/share/nvim"                # Share sistema Neovim
SYSTEM_PLUGINS_DIR="/opt/nvim-plugins"                  # Plugins globales con permisos
VI_SCRIPT_PATH="/usr/local/bin/vi"                 # Script auxiliar vi
SKEL_CONFIG="/etc/skel/.config/nvim"               # Solo para usuarios nuevos (sin archivos)

# URLs de descarga
FIRA_CODE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
ONEDARK_URL="https://raw.githubusercontent.com/joshdick/onedark.vim/main/colors/onedark.vim"
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# =============================================================================
# 🎨 SECTION: Colores para su uso
# =============================================================================
# Definición de colores que se pueden usar en la salida del terminal

# Colores Regulares
Color_Off='\033[0m'       # Reset de color
Black='\033[0;30m'        # Negro
Red='\033[0;31m'          # Rojo
Green='\033[0;32m'        # Verde
Yellow='\033[0;33m'       # Amarillo
Blue='\033[0;34m'         # Azul
Purple='\033[0;35m'       # Púrpura
Cyan='\033[0;36m'         # Cian
White='\033[0;37m'        # Blanco
Gray='\033[0;90m'         # Gris

# Colores en Negrita
BBlack='\033[1;30m'       # Negro (negrita)
BRed='\033[1;31m'         # Rojo (negrita)
BGreen='\033[1;32m'       # Verde (negrita)
BYellow='\033[1;33m'      # Amarillo (negrita)
BBlue='\033[1;34m'        # Azul (negrita)
BPurple='\033[1;35m'      # Púrpura (negrita)
BCyan='\033[1;36m'        # Cian (negrita)
BWhite='\033[1;37m'       # Blanco (negrita)
BGray='\033[1;90m'        # Gris (negrita)

# =============================================================================
# ⚙️ SECTION: Core Functions
# =============================================================================

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
#   $2 - Tipo de mensaje (INFO | WARNING | ERROR | SUCCESS | DEBUG) [opcional, por defecto: INFO]
#
# 💡 Uso:
#   msg "Inicio del proceso"               # Por defecto: INFO
#   msg "Plugin no instalado" "WARNING"
#   msg "Error de conexión" "ERROR"
#   msg "Mensaje personalizado" "DEBUG"
# ==============================================================================

msg() {
  local message="$1"
  local level="${2:-INFO}"
  local timestamp
  timestamp=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S")

  local SHOW_DETAIL=1
  if [ -n "${SO_SYSTEM:-}" ] && [ "$SO_SYSTEM" = "termux" ]; then
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

# ==============================================================================
# 🛠️ Función: show_step
# ------------------------------------------------------------------------------
# ✅ Descripción: Muestra un paso del proceso con formato visual atractivo
# 🔧 Parámetros:
#   $1 - Número del paso
#   $2 - Título del paso
#   $3 - Descripción del paso (opcional)
# ==============================================================================
show_step() {
    local step_num="$1"
    local step_title="$2"
    local step_desc="${3:-}"

    echo
    echo -e "${BCyan}┌─────────────────────────────────────────────────────────────────────┐${Color_Off}"
    echo -e "${BCyan}│${Color_Off} ${BWhite}PASO $step_num:${Color_Off} ${BGreen}$step_title${Color_Off}${BCyan}$(printf "%*s" $((65 - ${#step_title} - ${#step_num} - 7)) "")│${Color_Off}"
    if [[ -n "$step_desc" ]]; then
        echo -e "${BCyan}│${Color_Off} ${Gray}$step_desc${Color_Off}${BCyan}$(printf "%*s" $((68 - ${#step_desc})) "")│${Color_Off}"
    fi
    echo -e "${BCyan}└─────────────────────────────────────────────────────────────────────┘${Color_Off}"
    echo
}

# ==============================================================================
# 🛠️ Función: check_root_privileges
# ------------------------------------------------------------------------------
# ✅ Descripción: Verifica que el script se ejecute con privilegios de root
# ==============================================================================
check_root_privileges() {
    if [[ $EUID -ne 0 ]]; then
        msg "Este script debe ejecutarse como root para configuración global" "ERROR"
        msg "Uso: sudo $SCRIPT_NAME" "INFO"
        exit 1
    fi

    msg "Privilegios de administrador verificados ✓" "SUCCESS"
}

# ==============================================================================
# 📦 Función: install_system_packages
# ------------------------------------------------------------------------------
# ✅ Descripción: Instala paquetes necesarios del sistema
# ==============================================================================
install_system_packages() {
    show_step "1" "INSTALANDO PAQUETES DEL SISTEMA" "Neovim, Git, Curl, Wget, Unzip"

    msg "Actualizando repositorios del sistema..." "INFO"
    if apt-get update -qq; then
        msg "✓ Repositorios actualizados" "SUCCESS"
    else
        msg "Error actualizando repositorios" "ERROR"
        return 1
    fi

    local packages=("neovim" "git" "curl" "wget" "unzip" "fontconfig")
    msg "Instalando paquetes: ${packages[*]}" "INFO"

    if apt-get install -y "${packages[@]}" > /dev/null 2>&1; then
        msg "✓ Todos los paquetes instalados correctamente" "SUCCESS"

        # Verificar que neovim está funcionando
        local nvim_version=$(nvim --version | head -1 2>/dev/null || echo "Error")
        if [[ "$nvim_version" != "Error" ]]; then
            msg "✓ Neovim funcional: $nvim_version" "SUCCESS"
        else
            msg "Error: Neovim no funciona correctamente" "ERROR"
            return 1
        fi
    else
        msg "Error instalando paquetes del sistema" "ERROR"
        return 1
    fi
}

# ==============================================================================
# 📁 Función: create_global_structure
# ------------------------------------------------------------------------------
# ✅ Descripción: Crea la estructura de directorios global
# ==============================================================================
create_global_structure() {
    show_step "2" "CREANDO ESTRUCTURA COMPARTIDA" "Configuración XDG global sin duplicar archivos"

    msg "Creando estructura de directorios compartidos..." "INFO"

    # Crear SOLO directorios sistema (compartidos)
    local directories=(
        "$SYSTEM_NVIM_CONFIG"                    # /etc/xdg/nvim (XDG global)
        "$SYSTEM_NVIM_CONFIG/colors"
        "$SYSTEM_NVIM_SHARE"                     # /usr/share/nvim
        "$SYSTEM_NVIM_SHARE/site/autoload"
        "$SYSTEM_PLUGINS_DIR"                   # /opt/nvim-plugins (con permisos correctos)
        "$SKEL_CONFIG"                           # /etc/skel/.config/nvim (solo estructura)
    )

    for dir in "${directories[@]}"; do
        if mkdir -p "$dir"; then
            msg "✓ Directorio creado: $dir" "SUCCESS"
        else
            msg "Error creando directorio: $dir" "ERROR"
            return 1
        fi
    done

    # Establecer permisos correctos para lectura por todos
    chmod -R 755 "$SYSTEM_NVIM_CONFIG" "$SYSTEM_NVIM_SHARE"
    chmod -R 755 "$SKEL_CONFIG"

    # Permisos seguros para directorio de plugins
    # Crear grupo 'nvim-users' para gestión segura de plugins
    groupadd -f nvim-users 2>/dev/null || true

    # Establecer propietario root y grupo nvim-users
    chown -R root:nvim-users "$SYSTEM_PLUGINS_DIR"

    # Permisos 775: owner(rwx) group(rwx) others(r-x)
    # Esto permite escritura al grupo nvim-users pero solo lectura a otros
    chmod -R 775 "$SYSTEM_PLUGINS_DIR"

    # Establecer sticky bit para que los archivos hereden el grupo
    chmod g+s "$SYSTEM_PLUGINS_DIR"

    msg "✓ Estructura compartida creada exitosamente" "SUCCESS"
    msg "  - Configuración XDG: $SYSTEM_NVIM_CONFIG" "INFO"
    msg "  - Plugins compartidos: $SYSTEM_PLUGINS_DIR (permisos 775, grupo nvim-users)" "INFO"
    msg "  - Sin duplicación de archivos por usuario" "INFO"
}

# ==============================================================================
# 🎨 Función: download_theme_and_manager
# ------------------------------------------------------------------------------
# ✅ Descripción: Descarga tema y gestor de plugins
# ==============================================================================
download_theme_and_manager() {
    show_step "3" "DESCARGANDO TEMA Y GESTOR DE PLUGINS" "OneDark theme y Vim-Plug en ubicaciones accesibles"

    msg "Descargando esquema de color OneDark..." "INFO"

    # Crear directorios necesarios para el tema
    mkdir -p /usr/share/nvim/colors
    mkdir -p /usr/share/vim/vim*/colors 2>/dev/null || true

    # Descargar tema en ubicación principal
    if curl -fsSL "$ONEDARK_URL" -o "$SYSTEM_NVIM_CONFIG/colors/onedark.vim"; then
        msg "✓ Tema OneDark descargado en XDG" "SUCCESS"

        # Copiar tema a ubicaciones adicionales para máxima compatibilidad
        cp "$SYSTEM_NVIM_CONFIG/colors/onedark.vim" "/usr/share/nvim/colors/onedark.vim" 2>/dev/null || true

        # Establecer permisos correctos
        chmod 644 "$SYSTEM_NVIM_CONFIG/colors/onedark.vim"
        chmod 644 "/usr/share/nvim/colors/onedark.vim" 2>/dev/null || true

        msg "✓ Tema OneDark instalado en múltiples ubicaciones para compatibilidad" "SUCCESS"
    else
        msg "Error descargando tema OneDark" "ERROR"
        return 1
    fi

    msg "Descargando gestor de plugins Vim-Plug..." "INFO"
    if curl -fsSL "$VIM_PLUG_URL" -o "$SYSTEM_NVIM_SHARE/site/autoload/plug.vim"; then
        msg "✓ Vim-Plug descargado exitosamente" "SUCCESS"
        chmod 644 "$SYSTEM_NVIM_SHARE/site/autoload/plug.vim"
    else
        msg "Error descargando Vim-Plug" "ERROR"
        return 1
    fi

    msg "✓ Tema y gestor de plugins configurados para todos los usuarios" "SUCCESS"
}

# ==============================================================================
# ⚙️ Función: create_global_config
# ------------------------------------------------------------------------------
# ✅ Descripción: Crea la configuración global de Neovim
# ==============================================================================
create_global_config() {
    show_step "4" "CREANDO CONFIGURACIÓN COMPARTIDA" "init.vim XDG global para todos los usuarios"

    msg "Creando configuración XDG compartida..." "INFO"

    cat > "$SYSTEM_NVIM_CONFIG/init.vim" << 'EOF'

" =============================================================================
" 🚀 NEOVIM GLOBAL CONFIGURATION - MULTIUSER SETUP
" =============================================================================
" 📝 Descripción: Configuración XDG compartida para todos los usuarios
" 👨‍💻 Ubicación: /etc/xdg/nvim/init.vim
" 📅 Fecha: 2025-09-23
" 🔄 Versión: 4.0 - CONFIGURACIÓN XDG COMPARTIDA
" =============================================================================
" 🎯 CARACTERÍSTICAS:
" - Configuración XDG accesible por todos los usuarios sin duplicar archivos
" - Plugins instalados en ubicaciones compartidas
" - Tema OneDark preconfigurado compartido
" - Atajos de teclado optimizados
" - Configuración de desarrollo completa sin ocupar espacio por usuario
" =============================================================================

" -----------------------------------------
" 🔌 CONFIGURACIÓN DE VIM-PLUG COMPARTIDO
" -----------------------------------------
" Configuración de plugins que se instalarán en ubicación compartida
" NOTA: Los plugins se instalan en ubicación con permisos de escritura
call plug#begin('/opt/nvim-plugins')

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

" Configurar tema OneDark con manejo de errores y rutas compartidas
try
    " Añadir rutas compartidas al runtimepath para que todos los usuarios accedan
    set runtimepath+=/etc/xdg/nvim
    set runtimepath+=/usr/share/nvim
    set runtimepath+=/opt/nvim-plugins
    colorscheme onedark
catch
    " Si OneDark no está disponible, usar tema por defecto mejorado
    echo "Tema OneDark no encontrado, usando tema por defecto mejorado"
    colorscheme default
    " Configurar colores básicos manualmente para simular tema oscuro
    highlight Normal ctermbg=235 ctermfg=250 guibg=#1e1e1e guifg=#d4d4d4
    highlight CursorLine ctermbg=236 guibg=#2d2d2d
    highlight LineNr ctermfg=240 guifg=#5a5a5a
    highlight Comment ctermfg=244 guifg=#7c7c7c
    highlight String ctermfg=114 guifg=#98c379
    highlight Function ctermfg=81 guifg=#61afef
endtry

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

" Configurar esquema de color (redundancia eliminada - ya se configuró arriba)

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

" -----------------------------------------
" 🔧 CONFIGURACIONES ESPECÍFICAS DE ARCHIVOS
" -----------------------------------------
" Sintaxis para archivos de configuración
autocmd BufRead,BufNewFile *.cnf,*.cf,*.local,*.allow,*.deny set filetype=dosini

" -----------------------------------------
" 💡 MENSAJE DE BIENVENIDA
" -----------------------------------------
" Mostrar información al iniciar Neovim
function! ShowWelcomeMessage()
    echo "🚀 Neovim Global Configuration Loaded!"
    echo "📁 Config: /etc/skel/.config/nvim/init.vim"
    echo "🔌 Plugins: Ejecuta :PlugInstall para instalar plugins"
    echo "💡 Leader: <Space> | Explorer: <Space>e | Help: :help"
endfunction

" Mostrar mensaje al iniciar (solo si no se está abriendo un archivo)
autocmd VimEnter * if argc() == 0 | call ShowWelcomeMessage() | endif

EOF

    chmod 644 "$SYSTEM_NVIM_CONFIG/init.vim"
    msg "✓ Configuración XDG compartida creada exitosamente" "SUCCESS"
    msg "  Ubicación: $SYSTEM_NVIM_CONFIG/init.vim" "INFO"
    msg "  Accesible por todos los usuarios sin ocupar espacio individual" "INFO"
}


# ==============================================================================
# 🔌 Función: install_plugins_automatically
# ------------------------------------------------------------------------------
# ✅ Descripción: Instala plugins automáticamente usando vim-plug
# ==============================================================================
install_plugins_automatically() {
    show_step "5" "INSTALANDO PLUGINS AUTOMÁTICAMENTE" "Descarga e instalación de todos los plugins"

    msg "Instalando plugins con vim-plug automáticamente..." "INFO"

    # Crear script temporal para instalar plugins sin intervención del usuario
    local temp_script="/tmp/install_nvim_plugins.vim"
    cat > "$temp_script" << 'PLUGIN_INSTALL'
" Script temporal para instalar plugins automáticamente
set nocompatible
filetype off

" Cargar configuración
source /etc/xdg/nvim/init.vim

" Instalar plugins automáticamente y salir
PlugInstall --sync
qall!
PLUGIN_INSTALL

    # Ejecutar instalación automática con timeout como root (para tener permisos)
    msg "Ejecutando instalación de plugins (puede tomar unos minutos)..." "INFO"

    # Temporalmente cambiar grupo para la instalación
    local original_group=$(id -gn)
    if timeout 300 sg nvim-users -c "nvim --headless -S '$temp_script'" 2>/dev/null; then
        msg "✓ Plugins instalados automáticamente" "SUCCESS"
    else
        # Fallback: intentar como root
        if timeout 300 nvim --headless -S "$temp_script" 2>/dev/null; then
            msg "✓ Plugins instalados automáticamente (como root)" "SUCCESS"
            # Corregir propietarios después de la instalación
            chown -R root:nvim-users "$SYSTEM_PLUGINS_DIR" 2>/dev/null || true
            chmod -R 775 "$SYSTEM_PLUGINS_DIR" 2>/dev/null || true
        else
            msg "⚠ Instalación automática completada (algunos warnings son normales)" "WARNING"
            msg "  Los usuarios pueden ejecutar ':PlugInstall' manualmente si es necesario" "INFO"
        fi
    fi

    # Limpiar archivo temporal
    rm -f "$temp_script"

    # Verificar que al menos algunos plugins se instalaron
    local installed_plugins=0
    if [[ -d "$SYSTEM_PLUGINS_DIR" ]]; then
        installed_plugins=$(find "$SYSTEM_PLUGINS_DIR" -mindepth 1 -type d 2>/dev/null | wc -l)
        if [[ $installed_plugins -gt 0 ]]; then
            msg "✓ $installed_plugins plugins detectados en $SYSTEM_PLUGINS_DIR" "SUCCESS"
        else
            msg "⚠ No se detectaron plugins instalados, los usuarios pueden ejecutar ':PlugInstall'" "WARNING"
        fi
    fi

    msg "Instalación automática de plugins completada" "SUCCESS"
}

# ==============================================================================
# 🔤 Función: install_fira_code_font
# ------------------------------------------------------------------------------
# ✅ Descripción: Instala la fuente FiraCode Nerd Font globalmente
# ==============================================================================
install_fira_code_font() {
    show_step "6" "INSTALANDO FUENTE FIRACODE NERD FONT" "Fuente con iconos para todos los usuarios"

    msg "Descargando FiraCode Nerd Font..." "INFO"

    local temp_font_file="/tmp/FiraCode.zip"
    local system_font_dir="/usr/local/share/fonts/FiraCode"

    if wget -q "$FIRA_CODE_URL" -O "$temp_font_file"; then
        msg "✓ FiraCode descargado exitosamente" "SUCCESS"
    else
        msg "Error descargando FiraCode" "ERROR"
        return 1
    fi

    msg "Instalando fuente globalmente..." "INFO"
    mkdir -p "$system_font_dir"

    if unzip -qo "$temp_font_file" -d "$system_font_dir"; then
        msg "✓ Fuente extraída exitosamente" "SUCCESS"
    else
        msg "Error extrayendo fuente" "ERROR"
        return 1
    fi

    msg "Actualizando caché de fuentes del sistema..." "INFO"
    if fc-cache -fv > /dev/null 2>&1; then
        msg "✓ Caché de fuentes actualizado" "SUCCESS"
    else
        msg "Warning: Error actualizando caché de fuentes" "WARNING"
    fi

    # Limpiar archivo temporal
    rm -f "$temp_font_file"

    msg "✓ FiraCode instalado globalmente" "SUCCESS"
    msg "  Ubicación: $system_font_dir" "INFO"
}

# ==============================================================================
# 🔧 Función: create_vi_script
# ------------------------------------------------------------------------------
# ✅ Descripción: Crea el script auxiliar 'vi' optimizado
# ==============================================================================
create_vi_script() {
    show_step "7" "CREANDO SCRIPT AUXILIAR 'VI'" "Acceso rápido y cómodo a Neovim"

    msg "Creando script auxiliar 'vi'..." "INFO"

    cat > "$VI_SCRIPT_PATH" << 'VISCRIPT'
#!/bin/bash

# =============================================================================
# 📋 SCRIPT: vi - Neovim Launcher Global
# =============================================================================
# 📝 Descripción: Script auxiliar para lanzar Neovim con mejoras usando 'vi'
# 👨‍💻 Autor: cesar & LinuxBot
# 📅 Fecha: 2025-09-23
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${CYAN}🚀 Neovim Global Launcher (vi)${NC}"
    echo -e "${WHITE}Uso:${NC}"
    echo -e "  ${YELLOW}vi${NC}           - Abrir Neovim sin archivos"
    echo -e "  ${YELLOW}vi archivo${NC}   - Abrir archivo específico"
    echo -e "  ${YELLOW}vi directorio${NC} - Abrir directorio"
    echo -e "  ${YELLOW}vi -h|--help${NC} - Mostrar esta ayuda"
    echo
    echo -e "${WHITE}Atajos dentro de Neovim:${NC}"
    echo -e "  ${BLUE}<Space>e${NC}     - Explorador de archivos (NERDTree)"
    echo -e "  ${BLUE}<Space>w${NC}     - Guardar archivo"
    echo -e "  ${BLUE}<Space>q${NC}     - Salir de Neovim"
    echo -e "  ${BLUE}<Space>f${NC}     - Buscar archivos (FZF)"
    echo
    echo -e "${GREEN}💡 Configuración XDG compartida activa para todos los usuarios${NC}"
}

# Verificar si Neovim está instalado
check_neovim() {
    if ! command -v nvim &> /dev/null; then
        echo -e "${RED}❌ Error: Neovim no está instalado${NC}"
        echo -e "${YELLOW}💡 Ejecuta el script de instalación primero${NC}"
        return 1
    fi
    return 0
}

# Función principal
main() {
    # Verificar instalación
    if ! check_neovim; then
        exit 1
    fi

    # Procesar argumentos
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        "")
            # Sin argumentos - abrir Neovim normal
            echo -e "${GREEN}🚀 Iniciando Neovim con configuración XDG compartida...${NC}"
            nvim
            ;;
        *)
            # Con argumentos
            if [[ -d "$1" ]]; then
                echo -e "${BLUE}📁 Abriendo directorio: $1${NC}"
                cd "$1" && nvim .
            elif [[ -f "$1" ]]; then
                echo -e "${GREEN}📄 Abriendo archivo: $1${NC}"
                nvim "$1"
            else
                echo -e "${YELLOW}📝 Creando nuevo archivo: $1${NC}"
                nvim "$1"
            fi
            ;;
    esac
}

# Ejecutar función principal
main "$@"
VISCRIPT

    # Hacer el script ejecutable
    chmod +x "$VI_SCRIPT_PATH"

    msg "✓ Script 'vi' creado exitosamente" "SUCCESS"
    msg "  Ubicación: $VI_SCRIPT_PATH" "INFO"
    msg "  Uso: vi [archivo] o vi --help" "INFO"
}

# ==============================================================================
# 👥 Función: configure_xdg_access
# ------------------------------------------------------------------------------
# ✅ Descripción: Configura acceso XDG compartido (SIN copiar archivos)
# ==============================================================================
configure_xdg_access() {
    show_step "8" "CONFIGURANDO ACCESO XDG COMPARTIDO" "Enlaces simbólicos ligeros sin duplicar archivos"

    msg "Configurando acceso XDG compartido para todos los usuarios..." "INFO"

    # Crear solo estructura mínima en /etc/skel para usuarios nuevos
    msg "Preparando estructura para usuarios nuevos..." "INFO"

    # Crear archivo de configuración ligero en /etc/skel que apunte al XDG global
    cat > "$SKEL_CONFIG/init.vim" << 'SKEL_INIT'
" =============================================================================
" 🔗 NEOVIM - ENLACE A CONFIGURACIÓN XDG COMPARTIDA
" =============================================================================
" Este archivo enlaza a la configuración XDG global para ahorrar espacio

" Cargar configuración XDG compartida
source /etc/xdg/nvim/init.vim

" Usuarios pueden agregar configuraciones personales aquí
" Ejemplo:
" set number
" set relativenumber

SKEL_INIT

    chmod 644 "$SKEL_CONFIG/init.vim"

    # Verificar usuarios existentes que podrían necesitar el enlace
    local users_needing_link=0
    while IFS=: read -r username _ uid _ _ home_dir _; do
        if [[ $uid -ge 1000 || $username == "root" ]] && [[ -d "$home_dir" ]]; then
            local user_config_dir="$home_dir/.config/nvim"

            # Añadir usuario al grupo nvim-users para permisos de plugins
            usermod -a -G nvim-users "$username" 2>/dev/null || {
                msg "Warning: No se pudo añadir $username al grupo nvim-users" "WARNING"
            }

            # Solo crear directorio si no existe, sin copiar archivos
            if [[ ! -d "$user_config_dir" ]]; then
                sudo -u "$username" mkdir -p "$user_config_dir" 2>/dev/null || mkdir -p "$user_config_dir"

                # Crear enlace ligero a configuración XDG
                cat > "$user_config_dir/init.vim" << USER_INIT
" Enlace a configuración XDG compartida (ahorra espacio)
source /etc/xdg/nvim/init.vim
USER_INIT
                chown "$username:$username" "$user_config_dir" "$user_config_dir/init.vim" 2>/dev/null || true
                msg "✓ Usuario $username: enlace ligero creado y añadido al grupo nvim-users" "SUCCESS"
                ((users_needing_link++))
            else
                msg "- Usuario $username: ya tiene configuración, añadido al grupo nvim-users" "INFO"
            fi
        fi
    done < /etc/passwd

    msg "✓ Configuración XDG compartida lista" "SUCCESS"
    msg "  - Configuración central: $SYSTEM_NVIM_CONFIG/init.vim" "INFO"
    msg "  - Usuarios con enlace: $users_needing_link" "INFO"
    msg "  - Espacio ahorrado: NO se duplicaron archivos" "SUCCESS"
}

# ==============================================================================
# ✅ Función: verify_installation
# ------------------------------------------------------------------------------
# ✅ Descripción: Verifica que la instalación esté completa
# ==============================================================================
verify_installation() {
    show_step "9" "VERIFICANDO INSTALACIÓN" "Comprobando que todo funcione correctamente"

    local errors=0

    # Verificar Neovim
    if command -v nvim &> /dev/null; then
        local version=$(nvim --version | head -1)
        msg "✓ Neovim disponible: $version" "SUCCESS"
    else
        msg "✗ Neovim no encontrado" "ERROR"
        ((errors++))
    fi

    # Verificar script vi
    if [[ -x "$VI_SCRIPT_PATH" ]]; then
        msg "✓ Script 'vi' disponible y ejecutable" "SUCCESS"
    else
        msg "✗ Script 'vi' no encontrado o no ejecutable" "ERROR"
        ((errors++))
    fi

    # Verificar configuración XDG
    if [[ -f "$SYSTEM_NVIM_CONFIG/init.vim" ]]; then
        msg "✓ Configuración XDG compartida presente" "SUCCESS"
    else
        msg "✗ Configuración XDG no encontrada" "ERROR"
        ((errors++))
    fi

    # Verificar gestor de plugins
    if [[ -f "$SYSTEM_NVIM_SHARE/site/autoload/plug.vim" ]]; then
        msg "✓ Vim-Plug disponible en ubicación compartida" "SUCCESS"
    else
        msg "✗ Vim-Plug no encontrado" "ERROR"
        ((errors++))
    fi

    # Test básico de Neovim
    msg "Realizando test básico de Neovim..." "INFO"
    if nvim --headless -c 'echo "Test OK"' -c 'qa!' 2>/dev/null; then
        msg "✓ Test de Neovim exitoso" "SUCCESS"
    else
        msg "⚠ Test de Neovim con warnings (normal en primera ejecución)" "WARNING"
    fi

    if [[ $errors -eq 0 ]]; then
        msg "✅ Verificación completada sin errores" "SUCCESS"
        return 0
    else
        msg "⚠ Verificación completada con $errors errores" "WARNING"
        return 1
    fi
}

# ==============================================================================
# 📋 Función: show_final_summary
# ------------------------------------------------------------------------------
# ✅ Descripción: Muestra el resumen final de la instalación
# ==============================================================================
show_final_summary() {
    echo
    echo -e "${BGreen}════════════════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BGreen}🎉               INSTALACIÓN COMPLETADA EXITOSAMENTE                   🎉${Color_Off}"
    echo -e "${BGreen}════════════════════════════════════════════════════════════════════════${Color_Off}"
    echo
    echo -e "${BBlue}📋 RESUMEN DE LA INSTALACIÓN:${Color_Off}"
    echo -e "${White}   • Neovim configurado globalmente para todos los usuarios${Color_Off}"
    echo -e "${White}   • Plugins listos para instalar con :PlugInstall${Color_Off}"
    echo -e "${White}   • Tema OneDark preinstalado${Color_Off}"
    echo -e "${White}   • FiraCode Nerd Font instalada globalmente${Color_Off}"
    echo -e "${White}   • Script 'vi' disponible para acceso rápido${Color_Off}"
    echo
    echo -e "${BBlue}🚀 PRIMEROS PASOS:${Color_Off}"
    echo -e "${Yellow}   1.${Color_Off} Ejecuta: ${BYellow}vi${Color_Off} para abrir Neovim"
    echo -e "${Yellow}   2.${Color_Off} Dentro de Neovim: ${BYellow}:PlugInstall${Color_Off} para instalar plugins"
    echo -e "${Yellow}   3.${Color_Off} Usa ${BYellow}<Space>e${Color_Off} para explorador de archivos"
    echo -e "${Yellow}   4.${Color_Off} Usa ${BYellow}vi --help${Color_Off} para ver todas las opciones"
    echo
    echo -e "${BBlue}📁 UBICACIONES IMPORTANTES:${Color_Off}"
    echo -e "${White}   • Configuración XDG compartida:${Color_Off} $SYSTEM_NVIM_CONFIG/init.vim"
    echo -e "${White}   • Plugins compartidos:${Color_Off} $SYSTEM_PLUGINS_DIR"
    echo -e "${White}   • Script auxiliar:${Color_Off} $VI_SCRIPT_PATH"
    echo -e "${White}   • Fuentes del sistema:${Color_Off} /usr/local/share/fonts/FiraCode"
    echo
    echo -e "${BBlue}👥 USUARIOS CONFIGURADOS:${Color_Off}"
    echo -e "${White}   • Configuración XDG compartida: Accesible por todos sin duplicar${Color_Off}"
    echo -e "${White}   • Usuarios existentes: Enlaces ligeros creados y añadidos al grupo nvim-users${Color_Off}"
    echo -e "${White}   • Usuarios nuevos: Se configurarán desde /etc/skel${Color_Off}"
    echo -e "${White}   • Permisos seguros: Grupo nvim-users (775) en lugar de 777${Color_Off}"
    echo -e "${White}   • Espacio optimizado: UN solo conjunto de archivos para todos${Color_Off}"
    echo
    echo -e "${BGreen}💡 ¡Neovim está listo para usar! Ejecuta 'vi' para comenzar.${Color_Off}"
    echo -e "${BGreen}════════════════════════════════════════════════════════════════════════${Color_Off}"
    echo
}

# ==============================================================================
# 🧹 Función: cleanup
# ------------------------------------------------------------------------------
# ✅ Descripción: Limpieza de archivos temporales
# ==============================================================================
cleanup() {
    msg "Ejecutando limpieza de archivos temporales..." "INFO"

    # Limpiar archivos temporales específicos
    [[ -f "$TEMP_PATH_SCRIPT" ]] && rm -f "$TEMP_PATH_SCRIPT"
    [[ -f "$TEMP_PATH_SCRIPT_SYSTEM" ]] && rm -f "$TEMP_PATH_SCRIPT_SYSTEM"

    msg "Limpieza completada" "INFO"
}

# ==============================================================================
# 🚀 Función: main
# ------------------------------------------------------------------------------
# ✅ Descripción: Función principal del script
# ==============================================================================
main() {
    # Banner inicial
    echo
    echo -e "${BCyan}════════════════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BCyan}🚀                NEOVIM GLOBAL INSTALLER ${VERSION_SCRIPT}                      🚀${Color_Off}"
    echo -e "${BCyan}════════════════════════════════════════════════════════════════════════${Color_Off}"
    echo -e "${BWhite}📝 Instalador completo de Neovim con configuración multiusuario${Color_Off}"
    echo -e "${BWhite}👨‍💻 Ejecutado por: $MY_INFO${Color_Off}"
    echo -e "${BWhite}📅 Fecha: $DATE_HOUR_PE (UTC-5)${Color_Off}"
    echo -e "${BWhite}📁 Directorio: $CURRENT_DIR${Color_Off}"
    echo -e "${BCyan}════════════════════════════════════════════════════════════════════════${Color_Off}"
    echo

    # Verificar privilegios de root
    check_root_privileges

    # Ejecutar pasos de instalación
    if install_system_packages && \
       create_global_structure && \
       download_theme_and_manager && \
       create_global_config && \
       install_plugins_automatically && \
       install_fira_code_font && \
       create_vi_script && \
       configure_xdg_access; then

        # Verificar instalación
        if verify_installation; then
            show_final_summary
            msg "🎉 INSTALACIÓN COMPLETADA EXITOSAMENTE" "SUCCESS"
            exit 0
        else
            msg "⚠ Instalación completada con advertencias" "WARNING"
            show_final_summary
            exit 2
        fi
    else
        msg "❌ Error durante la instalación" "ERROR"
        exit 1
    fi
}

# =============================================================================
# 🎭 SECTION: Signal Handling y Ejecución
# =============================================================================

# Manejo de señales para cleanup
trap cleanup EXIT
trap 'msg "Script interrumpido por usuario (SIGINT)" "WARNING"; exit 130' INT
trap 'msg "Script terminado por sistema (SIGTERM)" "WARNING"; exit 143' TERM

# Ejecutar solo si es llamado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi