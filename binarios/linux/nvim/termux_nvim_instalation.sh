
set -e  # Detiene el script si ocurre un error
clear

# :::::::::: Colores
Color_Off='\e[0m'       # Reset
Green='\e[0;32m'        # Verde
Cyan='\e[0;36m'         # Cian
Red='\e[0;31m'          # Rojo
Gray='\e[1;30m'         # Gris
Yellow='\e[0;33m'       # Amarillo

# :::::::::: Paso 1: Verificar e instalar paquetes necesarios
echo -e "${Cyan}Verificando e instalando paquetes necesarios...${Color_Off}"

# Verifica si Neovim ya está instalado antes de instalarlo
if ! command -v nvim &> /dev/null; then
    pkg update -y && pkg upgrade -y
    pkg install -y neovim git curl unzip
else
    echo -e "${Green}Neovim ya está instalado.${Color_Off}"
fi

# :::::::::: Paso 2: Crear directorios de configuración
echo -e "${Cyan}Creando directorios de configuración...${Color_Off}"
mkdir -p ~/.config/nvim/colors

# :::::::::: Paso 3: Descargar esquema de color
if [ ! -f ~/.config/nvim/colors/onedark.vim ]; then
    echo -e "${Cyan}Descargando esquema de color 'onedark.vim'...${Color_Off}"
    curl -fLo ~/.config/nvim/colors/onedark.vim --create-dirs \
        https://raw.githubusercontent.com/joshdick/onedark.vim/main/colors/onedark.vim
else
    echo -e "${Green}Esquema de color 'onedark.vim' ya está instalado.${Color_Off}"
fi

# :::::::::: Paso 4: Instalar vim-plug
if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    echo -e "${Cyan}Instalando 'vim-plug' para la gestión de plugins...${Color_Off}"
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo -e "${Green}vim-plug ya está instalado.${Color_Off}"
fi

# :::::::::: Paso 5: Configurar init.vim
echo -e "${Cyan}Agregando configuración inicial a 'init.vim'...${Color_Off}"
cat > ~/.config/nvim/init.vim << 'EOF'
" init.vim - Configuración para Neovim en Termux

call plug#begin('~/.local/share/nvim/plugged')

" Plugins esenciales
Plug 'joshdick/onedark.vim'
Plug 'preservim/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'

call plug#end()

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set number
set relativenumber
syntax on
set background=dark
set termguicolors
colorscheme onedark

" Restaurar posición del cursor
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Mapas de teclas personalizados
let mapleader=" "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :wq<CR>

" NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

" FZF
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>l :Lines<CR>
let g:fzf_layout = { 'down': '40%' }

" Python en Termux
let g:python3_host_prog = '/data/data/com.termux/files/usr/bin/python3'
EOF

# :::::::::: Paso 6: Crear alias de acceso rápido a Neovim
#-----------------------------------------------------------
#------ Creando fichero 'vi' para acceso rápido a Neovim
#-----------------------------------------------------------
echo -e "${Cyan}Creando el script auxiliar 'vi' para un acceso rápido a Neovim...${Color_Off}"

# Asegurar que la carpeta bin existe en Termux
mkdir -p $PREFIX/bin

# Verificar si ya existe el binario 'vi' en Termux
if [ ! -f "$PREFIX/bin/vi" ]; then
    # Crear el script en la ubicación correcta
    cat > $PREFIX/bin/vi << 'EOF'
#!/usr/bin/env bash
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
    echo "--- Error: El archivo '$1' no existe."
    mostrar_uso
    exit 1
  fi
fi
EOF

    # Dar permisos de ejecución
    chmod +x $PREFIX/bin/vi
    echo -e "${Green}Script 'vi' creado correctamente.${Color_Off}"
else
    echo -e "${Yellow}El script 'vi' ya existe. No se sobrescribió.${Color_Off}"
fi

echo "================================================================"
echo -e "${Green}Configuración completada.${Color_Off}"
echo -e "${Gray}- Usa el comando 'vi' o 'vim' para abrir Neovim.${Color_Off}"
echo -e "${Yellow}- Abre Neovim y ejecuta ':PlugInstall' para instalar los plugins.${Color_Off}"
