#!/bin/bash
VERSION_SCRIPT="2.0.2"
# ==============================================================================
# 📦 Script: setup_nvim.sh
# 📝 Descripción: Instala y configura Neovim con plugins, fuentes y acceso rápido.
#                 Ejecución completamente desatendida (sin intervención del usuario).
# ==============================================================================

# set -euo pipefail   # -e: salir al primer error | -u: variables no definidas = error | -o pipefail: pipe falla si cualquier parte falla

# =============================================================================
# 🎨 SECTION: Colores
# =============================================================================
Color_Off='\033[0m'
Black='\033[0;30m';  Red='\033[0;31m';    Green='\033[0;32m'
Yellow='\033[0;33m'; Blue='\033[0;34m';   Purple='\033[0;35m'
Cyan='\033[0;36m';   White='\033[0;37m';  Gray='\033[0;90m'

BBlack='\033[1;30m'; BRed='\033[1;31m';   BGreen='\033[1;32m'
BYellow='\033[1;33m';BBlue='\033[1;34m';  BPurple='\033[1;35m'
BCyan='\033[1;36m';  BWhite='\033[1;37m'; BGray='\033[1;90m'
# ── Si no hay terminal interactiva (ej: Ansible), desactivar colores ──────────
if [ ! -t 1 ]; then
    Color_Off=''; Black='';   Red='';    Green=''
    Yellow='';    Blue='';    Purple=''; Cyan='';   White=''; Gray=''
    BBlack='';    BRed='';    BGreen=''
    BYellow='';   BBlue='';   BPurple=''
    BCyan='';     BWhite='';  BGray=''
fi


# =============================================================================
# ⚙️ SECTION: Variables del entorno
# =============================================================================
PATH_SCRIPT=$(readlink -f "${BASH_SOURCE:-$0}")
SCRIPT_NAME=$(basename "$PATH_SCRIPT")
CURRENT_DIR=$(dirname "$PATH_SCRIPT")
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(hostname)

NVIM_CONFIG_DIR="${HOME}/.config/nvim"
NVIM_COLORS_DIR="${NVIM_CONFIG_DIR}/colors"
NVIM_INIT="${NVIM_CONFIG_DIR}/init.vim"
NVIM_PLUG_DIR="${HOME}/.local/share/nvim/site/autoload/plug.vim"
NVIM_SWAP_DIR="${HOME}/.local/share/nvim/swap"
FONTS_DIR="${HOME}/.local/share/fonts"

FIRACODE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"
FIRACODE_ZIP="/tmp/FiraCode.zip"

# =============================================================================
# 📝 SECTION: Funciones de utilidad
# =============================================================================

# ------------------------------------------------------------------------------
# msg: Imprime mensajes con colores según el nivel
# Uso: msg "texto" "INFO|WARNING|ERROR|SUCCESS|DEBUG"
# ------------------------------------------------------------------------------
msg() {
  local message="$1"
  local level="${2:-OTHER}"
  local timestamp
  timestamp=$(date "+%H:%M:%S")

  case "$level" in
    INFO)    echo -e "${BBlue}[${timestamp}] ℹ  ${message}${Color_Off}" ;;
    WARNING) echo -e "${BYellow}[${timestamp}] ⚠  ${message}${Color_Off}" ;;
    DEBUG)   echo -e "${BPurple}[${timestamp}] 🔍 ${message}${Color_Off}" ;;
    ERROR)   echo -e "${BRed}[${timestamp}] ✗  ${message}${Color_Off}" >&2 ;;
    SUCCESS) echo -e "${BGreen}[${timestamp}] ✔  ${message}${Color_Off}" ;;
    STEP)    echo -e "\n${BCyan}[${timestamp}] ══ ${message} ══${Color_Off}" ;;
    *)       echo -e "${BGray}[${timestamp}]    ${message}${Color_Off}" ;;
  esac
}

# ------------------------------------------------------------------------------
# run_cmd: Muestra y ejecuta un comando. Retorna el exit code del comando.
# Uso: run_cmd apt-get install -y neovim
# ------------------------------------------------------------------------------
run_cmd() {
  echo -e "  ${BGray}›${Color_Off} ${BYellow}$*${Color_Off}"
  "$@"
  local exit_code=$?
  return $exit_code
}

# ------------------------------------------------------------------------------
# run_cmd_silent: Ejecuta el comando suprimiendo stdout (stderr visible).
# Uso: run_cmd_silent fc-cache -fv
# ------------------------------------------------------------------------------
run_cmd_silent() {
  echo -e "  ${BGray}›${Color_Off} ${BYellow}$*${Color_Off} ${BGray}(silencioso)${Color_Off}"
  "$@" > /dev/null
  local exit_code=$?
  return $exit_code
}

# ------------------------------------------------------------------------------
# check_cmd: Verifica si un comando existe en el PATH
# Uso: check_cmd nvim || exit 1
# ------------------------------------------------------------------------------
check_cmd() {
  if command -v "$1" &>/dev/null; then
    msg "'$1' encontrado: $(command -v "$1")" "DEBUG"
    return 0
  else
    msg "'$1' no encontrado en PATH." "WARNING"
    return 1
  fi
}

# =============================================================================
# 🛡️ SECTION: Manejador Global de Errores
# =============================================================================

handle_error() {
  local exit_code=$1
  local line_number=$2
  msg "=================================================" "ERROR"
  msg "💥 ERROR CRÍTICO NO MANEJADO" "ERROR"
  msg "=================================================" "ERROR"
  msg "Código de salida : ${exit_code}" "ERROR"
  msg "Línea del error  : ${line_number}" "ERROR"
  msg "Comando          : ${BASH_COMMAND:-N/A}" "ERROR"
  msg "Script           : ${PATH_SCRIPT}" "ERROR"
  msg "Función          : ${FUNCNAME[1]:-main}" "ERROR"
  msg "Usuario          : ${CURRENT_USER}@${CURRENT_PC_NAME}" "ERROR"
  msg "=================================================" "ERROR"
  exit "${exit_code}"
}

cleanup_on_exit() {
  local exit_code=$?
  [[ -f "${FIRACODE_ZIP}" ]] && rm -f "${FIRACODE_ZIP}" 2>/dev/null || true
  if [[ $exit_code -ne 0 ]]; then
    msg "Script finalizado con errores (código: ${exit_code})." "ERROR"
  fi
}

trap 'handle_error $? $LINENO' ERR
trap 'cleanup_on_exit'          EXIT

# =============================================================================
# 🚦 SECTION: Validaciones previas
# =============================================================================

msg "Iniciando configuración de Neovim — Usuario: ${CURRENT_USER}@${CURRENT_PC_NAME}" "STEP"





# =============================================================================
# 🔥 SECTION: Main Code
# =============================================================================

msg "=======================================================" "INFO"
msg "Ejecutando script para la configuración de Neovim..." "INFO"
msg "    Version: ${VERSION_SCRIPT}" "INFO"
msg "=======================================================" "INFO"
sleep 3



# Verificar que nvim quedó disponible
#if ! check_cmd nvim; then
#  msg "nvim no está disponible tras la instalación. Verifica los repositorios." "ERROR"
#  exit 1
#fi
#msg "Neovim versión: $(nvim --version | head -1)" "SUCCESS"

# =============================================================================
# 📁 PASO 2: Crear estructura de directorios
# =============================================================================

msg "PASO 2/5 — Creando directorios de configuración" "STEP"

for dir in "${NVIM_CONFIG_DIR}" "${NVIM_SWAP_DIR}" "${FONTS_DIR}"; do
  if run_cmd mkdir -p "${dir}"; then
    msg "Directorio listo: ${dir}" "DEBUG"
  else
    msg "No se pudo crear: ${dir}" "ERROR"
    exit 1
  fi
done
msg "Estructura de directorios creada." "SUCCESS"

# =============================================================================
# 🔌 PASO 3: Instalar vim-plug
# =============================================================================
# NOTA: onedark.vim NO se descarga manualmente aquí.
# vim-plug clona el plugin completo (incluyendo autoload/) durante :PlugInstall.
# Descargarlo manualmente solo instala colors/onedark.vim sin las funciones
# autoload/onedark.vim#GetColors(), lo que provoca errores E117/E121.

msg "PASO 3/5 — Instalando 'vim-plug'" "STEP"

VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

if run_cmd curl -fsSL "${VIM_PLUG_URL}" -o "${NVIM_PLUG_DIR}" --create-dirs; then
  msg "vim-plug instalado en: ${NVIM_PLUG_DIR}" "SUCCESS"
else
  msg "Fallo al instalar vim-plug." "ERROR"
  exit 1
fi

# =============================================================================
# ⚙️ PASO 5: Escribir init.vim
# =============================================================================

msg "PASO 4/5 — Escribiendo configuración init.vim" "STEP"

cat > "${NVIM_INIT}" << 'VIMEOF'
" init.vim — Configuración de Neovim

" -----------------------------------------
" vim-plug: gestión de plugins
" -----------------------------------------
call plug#begin('~/.local/share/nvim/plugged')

Plug 'joshdick/onedark.vim'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'sheerun/vim-polyglot'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim'
Plug 'Yggdroot/indentLine'

call plug#end()

" -----------------------------------------
" Tabulaciones y espacios
" -----------------------------------------
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" -----------------------------------------
" Apariencia
" -----------------------------------------
set cursorline
set number
set relativenumber
syntax on
set background=dark
set termguicolors
silent! colorscheme onedark     " silent!: evita errores si el plugin aún no está instalado

if has("gui_running")
    set guifont=FiraCode\ Nerd\ Font\ Mono\ 12
endif

" -----------------------------------------
" Búsqueda
" -----------------------------------------
set incsearch
set hlsearch
set ignorecase
set smartcase

" -----------------------------------------
" Portapapeles y edición
" -----------------------------------------
set clipboard=unnamedplus
set visualbell

" -----------------------------------------
" Autocomandos
" -----------------------------------------
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif

" -----------------------------------------
" Swap files
" -----------------------------------------
set swapfile
set directory=~/.local/share/nvim/swap//

" -----------------------------------------
" Mapas de teclas
" -----------------------------------------
let mapleader=" "

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :wq<CR>

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG
vnoremap <leader>p "+p
nnoremap <leader>P gg"+p

nnoremap <leader>e :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>

nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>
nnoremap <leader>sc :close<CR>

nnoremap <C-w><left>  :vertical resize -2<CR>
nnoremap <C-w><right> :vertical resize +2<CR>
nnoremap <C-w><up>    :resize +2<CR>
nnoremap <C-w><down>  :resize -2<CR>

" -----------------------------------------
" FZF
" -----------------------------------------
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :GFiles<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>l :Lines<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>c :Commands<CR>

let g:fzf_layout = { 'down': '40%' }
let g:fzf_action = {
    \ 'enter':  'tabedit',
    \ 'ctrl-t': 'tabedit',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit'
    \ }

" -----------------------------------------
" Python 3
" -----------------------------------------
let g:python3_host_prog = '/usr/bin/python3'

" -----------------------------------------
" lightline
" -----------------------------------------
set showmode

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

" Sintaxis para archivos de configuración
autocmd BufRead,BufNewFile *.cnf,*.cf,*.local,*.allow,*.deny set filetype=dosini
VIMEOF

msg "init.vim escrito correctamente: ${NVIM_INIT}" "SUCCESS"

# =============================================================================
# 🔌 PASO 6a: Instalar plugins con :PlugInstall (modo headless)
# =============================================================================

msg "PASO 5a/5 — Ejecutando :PlugInstall en modo headless" "STEP"
msg "Esto puede tardar unos minutos mientras se clonan los plugins..." "INFO"

# --headless: sin UI  |  +PlugInstall: instala plugins  |  +qa!: cierra al terminar
PLUG_OUTPUT=$(nvim --headless +PlugInstall +qa! 2>&1) || {
  msg ":PlugInstall falló. Revisa tu conexión a internet o la configuración de init.vim." "ERROR"
  echo "${PLUG_OUTPUT}"
  exit 1
}

# Mostrar output de PlugInstall para visibilidad
echo "${PLUG_OUTPUT}"

# Detectar errores vim críticos en la salida (E117 ya no debería aparecer)
if echo "${PLUG_OUTPUT}" | grep -qE "^E[0-9]+:"; then
  VIM_ERRORS=$(echo "${PLUG_OUTPUT}" | grep -E "^E[0-9]+:" | head -5)
  msg "Advertencias de Vim durante PlugInstall (no críticas):" "WARNING"
  echo "${VIM_ERRORS}"
fi

msg ":PlugInstall completado." "SUCCESS"

# Verificar que al menos un plugin fue instalado
if [[ -d "${HOME}/.local/share/nvim/plugged" ]] && \
   [[ $(ls -1 "${HOME}/.local/share/nvim/plugged" 2>/dev/null | wc -l) -gt 0 ]]; then
  PLUGIN_COUNT=$(ls -1 "${HOME}/.local/share/nvim/plugged" | wc -l)
  msg "${PLUGIN_COUNT} plugin(s) instalados en ~/.local/share/nvim/plugged" "SUCCESS"
else
  msg "No se encontraron plugins instalados. Verifica la salida de :PlugInstall." "WARNING"
fi

# =============================================================================
# 🔤 PASO 6b: Instalar fuente FiraCode Nerd Font
# =============================================================================

msg "PASO 5b/5 — Descargando FiraCode Nerd Font" "STEP"

if run_cmd wget -q "${FIRACODE_URL}" -O "${FIRACODE_ZIP}"; then
  msg "Fuente descargada: ${FIRACODE_ZIP}" "DEBUG"
else
  msg "Fallo al descargar FiraCode. Continuando sin instalar la fuente." "WARNING"
  # No hacemos exit 1 aquí porque la fuente no es crítica para Neovim
fi

if [[ -f "${FIRACODE_ZIP}" ]]; then
  if run_cmd unzip -qo "${FIRACODE_ZIP}" -d "${FONTS_DIR}"; then
    msg "Fuente descomprimida en: ${FONTS_DIR}" "DEBUG"
  else
    msg "Fallo al descomprimir FiraCode.zip" "WARNING"
  fi

  msg "Actualizando caché de fuentes..." "INFO"
  if check_cmd fc-cache; then
    run_cmd_silent fc-cache -fv
    msg "Caché de fuentes actualizado." "SUCCESS"
  else
    msg "fc-cache no disponible. Instala 'fontconfig': sudo apt install fontconfig" "WARNING"
  fi

  rm -f "${FIRACODE_ZIP}"
fi

# =============================================================================
# 🚀 PASO 6c: Crear alias 'nv' para acceso rápido a Neovim
# =============================================================================

msg "PASO 5c/5 — Creando script auxiliar 'nv'" "STEP"

NV_SCRIPT_PATH="/usr/local/bin/nv"

sudo tee "${NV_SCRIPT_PATH}" > /dev/null << 'NVEOF'
#!/bin/bash
# nv — Acceso rápido a Neovim con validación de archivo

Red='\033[0;31m'
Color_Off='\033[0m'

mostrar_uso() {
  echo "Uso: nv [archivo]"
  echo "     nv          → abre Neovim sin archivo"
  echo "     nv archivo  → abre Neovim con el archivo indicado"
}

if [[ $# -eq 0 ]]; then
  exec nvim
elif [[ $# -eq 1 ]]; then
  if [[ -e "$1" ]]; then
    exec nvim "$1"
  else
    echo -e "${Red}Error: El archivo '$1' no existe.${Color_Off}"
    mostrar_uso
    exit 1
  fi
else
  # Múltiples archivos
  exec nvim "$@"
fi
NVEOF

run_cmd sudo chmod +x "${NV_SCRIPT_PATH}"
msg "Script 'nv' instalado en ${NV_SCRIPT_PATH}" "SUCCESS"

# =============================================================================
# ✅ Resumen final
# =============================================================================

echo ""
echo -e "${BGreen}╔══════════════════════════════════════════════════╗${Color_Off}"
echo -e "${BGreen}║       ✔  Configuración completada con éxito      ║${Color_Off}"
echo -e "${BGreen}╚══════════════════════════════════════════════════╝${Color_Off}"
echo ""
msg "Neovim       : $(nvim --version | head -1)" "SUCCESS"
msg "Config       : ${NVIM_INIT}" "SUCCESS"
msg "Plugins dir  : ${HOME}/.local/share/nvim/plugged" "SUCCESS"
msg "Acceso rápido: nv  o  nv <archivo>" "SUCCESS"
echo ""
msg "Para actualizar plugins en el futuro: nvim --headless +PlugUpdate +qa!" "INFO"
echo ""

exit 0