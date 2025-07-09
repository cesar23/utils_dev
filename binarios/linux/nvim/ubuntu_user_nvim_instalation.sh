#!/bin/bash
VERSION_SCRIPT="1.0.3"

set -e  # Detiene el script si ocurre un error

#:::::::::: colores
Color_Off='\e[0m'       # Text Reset
# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red #a9222a
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White
Gray='\e[1;30m'         # Gray

echo -e "${Gray}=======================================================${Color_Off}"
echo -e "${Gray}Ejecutando script para la configuración de Neovim...${Color_Off}"
echo -e "${Gray}    Version: ${VERSION_SCRIPT}${Color_Off}"
echo -e "${Gray}=======================================================${Color_Off}"
sleep 3


# Verificar dependencias
for cmd in nvim git curl unzip; do
  error=0
  if ! command -v $cmd >/dev/null 2>&1; then
    echo -e "${Red}Error:${Color_Off} El comando '$cmd' no está instalado. Instálalo antes de continuar."
    error=1
  fi

  if [ $error -eq 1 ]; then
    exit 1

  fi

done

# Paso 2: Crear directorios de configuración de Neovim
echo -e "${Cyan}Creando directorios de configuración...${Color_Off}"
mkdir -p ~/.config/nvim
mkdir -p ~/.config/nvim/colors


# Paso 3: Instalar el esquema de color onedark.vim
echo -e "${Cyan}Descargando esquema de color 'onedark.vim'...${Color_Off}"
curl -fLo ~/.config/nvim/colors/onedark.vim --create-dirs \
    https://raw.githubusercontent.com/joshdick/onedark.vim/main/colors/onedark.vim

# Paso 4: Instalar y configurar vim-plug
echo -e "${Cyan}Instalando 'vim-plug' para la gestión de plugins...${Color_Off}"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim



# Paso 5: Configurar init.vim
echo -e "${Cyan}Agregando configuración inicial a 'init.vim'...${Color_Off}"
cat > ~/.config/nvim/init.vim << 'EOF'
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
autocmd BufRead,BufNewFile *.cnf,*.local,*.allow,*.deny set filetype=dosini

EOF


echo -e "${Cyan}Descargando e instalando la fuente FiraCode Nerd Font...${Color_Off}"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip -O /tmp/FiraCode.zip
unzip -qo /tmp/FiraCode.zip -d ~/.local/share/fonts
echo -e "${Green}Actualizando caché de fuentes...${Color_Off}"
rm /tmp/FiraCode.zip




#-----------------------------------------------------------
#------ creando fichero  nv para acceso rápido de nvim
#-----------------------------------------------------------
# Crear el directorio si no existe
mkdir -p ~/.local/bin
echo -e "${Cyan}Creando el script auxiliar 'vi' para un acceso rápido a Neovim...${Color_Off}"

# Crear el script auxiliar 'vi' en ~/.local/bin
cat > ~/.local/bin/vi << 'EOF'
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

# Mensaje para recordar agregar ~/.local/bin al PATH si no está
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  echo "Se agregó ~/.local/bin al PATH en ~/.bashrc. Reinicia la terminal para aplicar los cambios."
fi

# Mensaje final
echo "================================================================"
echo -e "${Green}Configuración completada.${Color_Off}"
echo -e "${Gray}- Puedes usar el comando vi para usar noevim.${Color_Off}"
echo -e "${Yellow}- Abre Neovim y ejecuta ':PlugInstall' para instalar los plugins.${Color_Off}"