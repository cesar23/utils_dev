# ----------------------------------------
#  export DEBIAN_FRONTEND=noninteractive
#  sudo apt-get -y install curl && curl -sL https://gitlab.com/perucaos/utils_dev/raw/master/scripts/ubuntu/util_linux.sh | bash /dev/stdin

# ----------------------------------------



export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y update
sudo apt -y  dist-upgrade
#Ahora instalamos el paquete que nos instala paquetes esenciales:
sudo apt-get install -y build-essential


#instalar utilidades
sudo apt-get -y install util-linux
sudo apt-get -y install tree
sudo apt-get -y install vim neovim

#descargara y ejecutar curl
sudo apt-get -y install curl
#nos da comandos basicos d como ifconfig
sudo apt-get -y install net-tools telnet
#una mejor herramienta de top de linux paar ver procesoss
sudo apt-get -y install htop
#iftop, vigila el consumo de ancho de banda de tu red en tiempo real
sudo apt-get -y install iftop
sudo apt-get -y install nmap
sudo apt-get -y install mlocate
sudo apt-get -y install iotop


sudo apt install openssh-server -y


#-----------------------------------------------
#------------------ NVIM -----------------------
#-----------------------------------------------

# para la configuracion
mkdir -p ~/.config/nvim && touch ~/.config/nvim/init.vim

# configuracion plugin
mkdir -p ~/.vim/plugged
# Crear carpeta
mkdir -p ~/.config/nvim/autoload
# descargar desde el repositorio de github y guardarlo el archivo de condiguracion
#curl -A 'Mozilla/3.0 (Win95; I)' -L -o "${HOME}/.config/nvim/autoload/plug.vim"  "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
curl -A 'Mozilla/3.0 (Win95; I)' -L -o ~/.config/nvim/autoload/plug.vim  "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"


# ------------- NVIM ------------
# :: fichero de configuracion  Linux
FILE_CONFIGURACION=~/.config/nvim/init.vim

# ------------- VIM ------------
# :: fichero de configuracion Linux
#FILE_CONFIGURACION=~/.vimrc
# :: fichero de configuracion windows
#FILE_CONFIGURACION=~/_vimrc

echo '' > $FILE_CONFIGURACION
echo '" TABLE OF CONTENTS:' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '" 1. Generic settings' >> $FILE_CONFIGURACION
echo '" 2. File settings' >> $FILE_CONFIGURACION
echo '" 3. UI' >> $FILE_CONFIGURACION
echo '" 4. Maps and functions' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '"-----------------------------------------' >> $FILE_CONFIGURACION
echo '" 1. GENERIC SETTINGS' >> $FILE_CONFIGURACION
echo '"-----------------------------------------' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set nocompatible " disable vi compatibility mode' >> $FILE_CONFIGURACION
echo 'set history=1000 " increase history size' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '"-----------------------------------------' >> $FILE_CONFIGURACION
echo '" 2. FILE SETTINGS' >> $FILE_CONFIGURACION
echo '"-----------------------------------------' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '" :::::: Stop creating backup files, please use Git for backups' >> $FILE_CONFIGURACION
echo 'set nobackup' >> $FILE_CONFIGURACION
echo 'set nowritebackup' >> $FILE_CONFIGURACION
echo 'set noswapfile' >> $FILE_CONFIGURACION
echo 'set backspace=indent,eol,start' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '" :::::: Modify indenting settings' >> $FILE_CONFIGURACION
echo 'set autoindent " autoindent always ON.' >> $FILE_CONFIGURACION
echo 'set expandtab " expand tabs' >> $FILE_CONFIGURACION
echo 'set shiftwidth=2 " spaces for autoindenting' >> $FILE_CONFIGURACION
echo 'set softtabstop=2 " remove a full pseudo-TAB when i press <BS>' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '" :::::: Modificar algunas otras configuraciones sobre archivos' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set hidden' >> $FILE_CONFIGURACION
echo 'set ignorecase' >> $FILE_CONFIGURACION
echo 'set scrolloff=8 " Keep at least 8 lines below cursor' >> $FILE_CONFIGURACION
echo 'set foldmethod=manual " To avoid performance issues, I never fold anything so...' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '"-----------------------------------------' >> $FILE_CONFIGURACION
echo '" 3. UI' >> $FILE_CONFIGURACION
echo '"-----------------------------------------' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set fillchars+=vert:\ " Retire las tuberías desagradables de las divisiones verticales.' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '" - Sauce on this: http://stackoverflow.com/a/9001540' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set wildmenu " enable visual wildmenu' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set nohlsearch' >> $FILE_CONFIGURACION
echo 'set lazyredraw' >> $FILE_CONFIGURACION
echo 'set ttyfast' >> $FILE_CONFIGURACION
echo 'set hidden' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set showcmd				" mostrar los comandos que se ejecuta en barra (show the comand that are executed in bar)' >> $FILE_CONFIGURACION
echo 'set number 				" mostrar numero de lineas (show line numbers)' >> $FILE_CONFIGURACION
echo 'syntax enable       	" sintaxis de codigo resaltado de color (color highligth code syntax)' >> $FILE_CONFIGURACION
echo 'set clipboard=unnamedplus   " habilitar copiar al movernos con el mouse (enable copy on mouse move)' >> $FILE_CONFIGURACION
echo 'set mouse=a     		" poder mover el mouse y arrastrar selecionar (begin able to move the mouse and drag select)' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set relativenumber   	" mostrar numeracion arriba y abajo (show top and botton numbering)' >> $FILE_CONFIGURACION
echo 'set laststatus=2        " mostrar barrita status  de abajo en vim  (show bar status botton)' >> $FILE_CONFIGURACION
echo '" set noshowmode        " No mostrar barrita de status insert o visual (show bar status insert or visual)' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set showmatch 			" resaltar paréntesis y corchetes coincidentes (highligth matching parentheses and brackets)' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'set hidden              " para ocultar la advertencia al abrir archivos (to hide warning when opening files)' >> $FILE_CONFIGURACION
echo '" set scrolloff=8         " Mantenga al menos 8 líneas debajo del cursor' >> $FILE_CONFIGURACION
echo 'set encoding=UTF-8 		" codificacion de archivos siempre al guardar (file encoding always on save)' >> $FILE_CONFIGURACION
echo 'set shiftwidth=2    	" Tab por espacios, indentado de 2 espacios (2 space indent)' >> $FILE_CONFIGURACION
echo 'set incsearch			"Mientras busca en un archivo, resalte de forma incremental los caracteres coincidentes a medida que escribe.' >> $FILE_CONFIGURACION
echo '" :::::::::::: IU' >> $FILE_CONFIGURACION
echo "let &t_ut=''  			\"VIM: Para representar adecuadamente el fondo de la combinación de colores" >> $FILE_CONFIGURACION
echo 'set ruler 				" habilitar en barra linea y posicion (enable in bar line and position)' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '"-----------------------------------------' >> $FILE_CONFIGURACION
echo '" 4. PLUGINS' >> $FILE_CONFIGURACION
echo '"-----------------------------------------' >> $FILE_CONFIGURACION
echo 'let mapleader =" "' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo "if has('nvim')" >> $FILE_CONFIGURACION
echo '    set background=dark' >> $FILE_CONFIGURACION
echo 'else' >> $FILE_CONFIGURACION
echo '	set background=dark' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo 'end' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '' >> $FILE_CONFIGURACION
echo '" para  guardar arhcivos' >> $FILE_CONFIGURACION
echo 'nmap <leader>so :source $HOME\_vimrc<CR>' >> $FILE_CONFIGURACION
echo 'nmap <leader>w :w <CR>' >> $FILE_CONFIGURACION
echo 'nmap <leader>x :x <CR>' >> $FILE_CONFIGURACION
echo 'nmap <leader>q :q <CR>' >> $FILE_CONFIGURACION
echo '"# Panel Navegador de Archivos (LEX) uso: Ctrl+b' >> $FILE_CONFIGURACION
echo 'nnoremap <c-b> <Esc>:Lex<cr>:vertical resize 30<cr>   " minim' >> $FILE_CONFIGURACION
echo 'inoremap <c-b> <Esc>:Lex<cr>:vertical resize 30<cr>' >> $FILE_CONFIGURACION
echo '" ------------------------------------------------' >> $FILE_CONFIGURACION
