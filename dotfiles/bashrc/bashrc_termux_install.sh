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
VERSION_BASHRC=5.0.0
VERSION_PLATFORM='(TERMUX)'

# ::::::::::::: START CONSTANT ::::::::::::::
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")                       # hora local del sistema
DATE_HOUR_PE=$(TZ="America/Lima" date "+%Y-%m-%d_%H:%M:%S")  # hora Perú (UTC-5)
PATH_BASHRC='~/.bash_profile'  # Ruta del archivo .bashrc
# ::::::::::::: END CONSTANT ::::::::::::::
# ==========================================================================
# VERSION: TERMUX
# START ~/.bash_profile - Configuración de Bash por César (version: 1.0.3)
# ==========================================================================
#
# IMPORTANTE (solo Termux): Termux abre bash como shell de LOGIN. Un shell
# de login lee ~/.bash_profile automáticamente -- NO lee ~/.bashrc a menos
# que ~/.bash_profile haga "source ~/.bashrc". Este archivo debe guardarse
# como ~/.bash_profile (no como ~/.bashrc), o Termux nunca lo va a cargar
# solo con abrir una sesión nueva.
#
# ==========================================================================

# 🧯 Desactiva el cierre automático de la sesión Bash por inactividad.
export TMOUT=0

# ========================
# 1. Personalización del prompt (PS1)
# ========================

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



# Underline
UBlack='\e[4;30m'       # Black  (Underline)
URed='\e[4;31m'         # Red  (Underline)
UGreen='\e[4;32m'       # Green  (Underline)
UYellow='\e[4;33m'      # Yellow  (Underline)
UBlue='\e[4;34m'        # Blue  (Underline)
UPurple='\e[4;35m'      # Purple  (Underline)
UCyan='\e[4;36m'        # Cyan  (Underline)
UWhite='\e[4;37m'       # White  (Underline)

# Background
On_Black='\e[40m'       # Black (BackGropund)
On_Red='\e[41m'         # Red (BackGropund)
On_Green='\e[42m'       # Green (BackGropund)
On_Yellow='\e[43m'      # Yellow (BackGropund)
On_Blue='\e[44m'        # Blue (BackGropund)
On_Purple='\e[45m'      # Purple (BackGropund)
On_Cyan='\e[46m'        # Cyan (BackGropund)
On_White='\e[47m'       # White (BackGropund)

# High Intensity
IBlack='\e[0;90m'       # Black (Intensitive)
IRed='\e[0;91m'         # Red (Intensitive)
IGreen='\e[0;92m'       # Green (Intensitive)
IYellow='\e[0;93m'      # Yellow (Intensitive)
IBlue='\e[0;94m'        # Blue (Intensitive)
IPurple='\e[0;95m'      # Purple (Intensitive)
ICyan='\e[0;96m'        # Cyan (Intensitive)
IWhite='\e[0;97m'       # White (Intensitive)

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

Code_background='\e[7;90;47m'

# Prompt básico con colores
export PS1='\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$ '

# Configuración del Prompt (por defecto)
export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '$' ) "

# Si la sesión es SSH, cambia el color del prompt
if [ -n "$SSH_CONNECTION" ]; then
    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h (SSH):\[\e[0m\] \[\e[34m\]\$(short_pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '$' ) "
fi

# Archivo donde se guarda el prompt preferido (funciones p1/p2/../p5)
PROMPT_CONFIG_FILE="$HOME/.prompt_config"

# ========================
# 2. Alias útiles
# ========================

alias ll='ls -lh --color=auto'
alias la='ls -lha --color=auto'
alias cls='clear'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -m'
alias h='history'

alias search='find . -iname'
alias bigfiles='du -ah . | sort -rh | head -n 10'
alias newestfile='ls -Art | tail -n 1'
# NOTA: netstat viene del paquete "net-tools" (pkg install net-tools).
alias ports='netstat -tulnp | grep LISTEN'
# FIX TERMUX: Termux no tiene sudo ni apt; usa "pkg", sin root.
alias update='pkg update -y && pkg upgrade -y'
alias reload="source $PATH_BASHRC"
alias reload_cat="cat $PATH_BASHRC | less"
alias mm='cmatrix'   # necesita: pkg install cmatrix

# ========================
# 3. Historial mejorado
# ========================
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoredups:ignorespace

# ========================
# 4. Variables de entorno
# ========================
# FIX TERMUX: /opt/mis-scripts no existe en Termux (se quitó; no aportaba nada ahí).

if command -v nvim &> /dev/null; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

# ========================
# 5. Colores para comandos comunes
# ========================
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# FIX TERMUX: "/usr/bin/dircolors" no existe -- el prefix real de Termux es
# /data/data/com.termux/files/usr, así que esa ruta absoluta jamás existe
# ahí. "command -v" lo encuentra sin importar dónde viva el binario.
if command -v dircolors &> /dev/null; then
    test -r ~/.dircolors && eval "$(dircolors ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Termux reporta $OSTYPE="linux-android", así que esto siempre se ejecuta
# ahí; 2>/dev/null por si Android limita el máximo permitido.
if [[ "$OSTYPE" == linux* ]]; then
    ulimit -n 4096 2>/dev/null
fi

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 8. Cargar librerías de libs_shell (init.sh) + func_generales.sh
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::

scriptPath2=${0%/*}
# FIX TERMUX/PERF: $HOSTNAME ya viene calculado por bash mismo (sin forks).
# Se usa como valor por defecto antes de intentar forkear "hostname", que
# en una instalación mínima de Termux puede no estar instalado.
: "${CURRENT_USER:=$(id -un)}"
: "${CURRENT_PC_NAME:=${HOSTNAME:-$(hostname 2>/dev/null || uname -n)}}"
INFO_PC="${CURRENT_USER}@${CURRENT_PC_NAME}"


parse_git_branch ()
{
    local dir="$PWD" gitdir="";
    while [ -n "$dir" ]; do
        if [ -f "$dir/.git" ]; then
            gitdir=$(< "$dir/.git");
            gitdir="${gitdir#gitdir: }";
            [[ "$gitdir" != /* ]] && gitdir="$dir/$gitdir";
            break;
        else
            if [ -d "$dir/.git" ]; then
                gitdir="$dir/.git";
                break;
            fi;
        fi;
        [ "$dir" = "/" ] && break;
        dir="${dir%/*}";
        [ -z "$dir" ] && dir="/";
    done;
    [ -z "$gitdir" ] || [ ! -f "$gitdir/HEAD" ] && return;
    local head;
    head=$(< "$gitdir/HEAD") 2> /dev/null;
    case "$head" in
        ref:*)
            echo "(${head##*/})"
        ;;
        "")
        ;;
        *)
            echo "(${head:0:7})"
        ;;
    esac
}

save_prompt ()
{
    echo "$1" > "$PROMPT_CONFIG_FILE"
}

short_pwd ()
{
    local pwd_length=${#PWD};
    local max_length=60;
    if [ $pwd_length -gt $max_length ]; then
        local path_parts=(${PWD//\// });
        local num_parts=${#path_parts[@]};
        if [ $num_parts -gt 3 ]; then
            echo "../${path_parts[$((num_parts-3))]}/${path_parts[$((num_parts-2))]}/${path_parts[$((num_parts-1))]}";
        else
            echo "$PWD";
        fi;
    else
        echo "$PWD";
    fi
}


p1 ()
{
    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\$(short_pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '$' ) ";
    save_prompt "p1"
}

p2 ()
{
    export PS1="\[\033[1;96m\]╭─\[\033[1;95m\]\u\[\033[1;96m\]@\[\033[1;95m\]\h\[\033[1;96m\]─[\[\033[1;93m\]\$(short_pwd)\[\033[1;92m\] \$(parse_git_branch)\[\033[1;96m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;96m\]]"'
'"╰─\[\033[1;95m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] ";
    save_prompt "p2"
}

p2_cyberpunk ()
{
    export PS1="\[\033[1;96m\]╭─\[\033[1;95m\]\u\[\033[1;96m\]@\[\033[1;95m\]\h\[\033[1;96m\]─[\[\033[1;93m\]\$(short_pwd)\[\033[1;92m\] \$(parse_git_branch)\[\033[1;96m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;96m\]]"'
'"╰─\[\033[1;95m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '💀 ❯' )\[\033[0m\] ";
    echo -e "${BCyan}Prompt Cyberpunk activado${Color_Off}"
}

p2_elite ()
{
    export PS1="\[\033[1;37m\]╭─\[\033[1;96m\]\u\[\033[1;37m\]@\[\033[1;96m\]\h\[\033[1;37m\]─[\[\033[1;92m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;37m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;37m\]]"'
'"╰─\[\033[1;96m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] ";
    echo -e "${BWhite}Prompt Elite activado${Color_Off}"
}

p2_fire ()
{
    export PS1="\[\033[1;91m\]╭─\[\033[1;93m\]\u\[\033[1;91m\]@\[\033[1;93m\]\h\[\033[1;91m\]─[\[\033[1;97m\]\$(short_pwd)\[\033[1;92m\] \$(parse_git_branch)\[\033[1;91m\] [\[\033[1;95m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;91m\]]"'
'"╰─\[\033[1;93m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] ";
    echo -e "${BRed}Prompt Fire activado${Color_Off}"
}

p2_matrix ()
{
    export PS1="\[\033[1;32m\]╭─\[\033[1;92m\]\u\[\033[1;32m\]@\[\033[1;92m\]\h\[\033[1;32m\]─[\[\033[1;96m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;32m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;32m\]]"'
'"╰─\[\033[1;92m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '⚡ ❯' )\[\033[0m\] ";
    echo -e "${BGreen}Prompt Matrix Green activado${Color_Off}"
}

p2_neon ()
{
    export PS1="\[\033[1;94m\]╭─\[\033[1;96m\]\u\[\033[1;94m\]@\[\033[1;96m\]\h\[\033[1;94m\]─[\[\033[1;97m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;94m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;94m\]]"'
'"╰─\[\033[1;96m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] ";
    echo -e "${BBlue}Prompt Neon Blue activado${Color_Off}"
}

p2_rainbow ()
{
    export PS1="\[\033[1;95m\]╭─\[\033[1;96m\]\u\[\033[1;95m\]@\[\033[1;92m\]\h\[\033[1;95m\]─[\[\033[1;93m\]\$(short_pwd)\[\033[1;94m\] \$(parse_git_branch)\[\033[1;95m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;95m\]]"'
'"╰─\[\033[1;97m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] ";
    echo -e "${BPurple}Prompt Rainbow Hacker activado${Color_Off}"
}

p2_retro ()
{
    export PS1="\[\033[1;95m\]╭─\[\033[1;96m\]\u\[\033[1;95m\]@\[\033[1;96m\]\h\[\033[1;95m\]─[\[\033[1;97m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;95m\] [\[\033[1;92m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;95m\]]"'
'"╰─\[\033[1;96m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] ";
    echo -e "${BPurple}Prompt Retro Wave activado${Color_Off}"
}

p2_terminal ()
{
    export PS1="\[\033[1;92m\]╭─\[\033[1;32m\]\u\[\033[1;92m\]@\[\033[1;32m\]\h\[\033[1;92m\]─[\[\033[1;97m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;92m\] [\[\033[1;33m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;92m\]]"'
'"╰─\[\033[1;32m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] ";
    echo -e "${BGreen}Prompt Hacker Terminal activado${Color_Off}"
}

p3 ()
{
    export PS1="\[\e[34m\]\W\[\e[0m\]\[\e[1;33m\]\$(parse_git_branch)\[\e[0m\] ❯ ";
    save_prompt "p3"
}

p4 ()
{
    export PS1="\[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[0m\]\n\[\e[32m\]❯\[\e[0m\] ";
    save_prompt "p4"
}

p5 ()
{
    export PS1="\[\e[1;31m\]❯\[\e[0m\] ";
    save_prompt "p5"
}

load_saved_prompt() {
    if [ -f "$PROMPT_CONFIG_FILE" ]; then
        local saved_prompt=$(cat "$PROMPT_CONFIG_FILE")
        if [ -n "$saved_prompt" ]; then
            $saved_prompt
        fi
    fi
}

menu(){
 menu_system
}

# FIX: "vi" llamaba a "mostrar_uso" pero nunca estaba definida en este
# archivo (se rompía con "mostrar_uso: command not found" al abrir un
# archivo que no existe). Se agrega aquí, sin depender de libs_shell.
mostrar_uso() {
  echo "Uso: vi [archivo]"
}

vi ()
{
    if [ -f "$1" ]; then
        if command -v nvim &> /dev/null; then
            nvim "$1";
        else
            vim "$1";
        fi;
    else
        echo -en "--- ${Red}Error: El archivo '$1' no existe.${Color_Off} \n";
        mostrar_uso;
        return 1;
    fi
}


# :::::::: Importamos las librerías (define $CURRENT_TERMINAL_SCRIPTS)
if [ -f "${HOME}/libs_shell/init.sh" ]; then
  source "${HOME}/libs_shell/init.sh"
fi

# FIX TERMUX: se quitó "alias bat=batcat". En Termux el paquete "bat"
# instala el binario "bat" tal cual (no "batcat" -- eso solo pasa en
# Debian/Ubuntu por un choque de nombres con otro paquete). Con este alias
# activo, "bat" quedaba roto en Termux. Instala con: pkg install bat

# ================================================
# ====================== docker ==================
# ================================================
# FIX TERMUX: Android no soporta Docker de forma nativa (sin namespaces de
# kernel accesibles sin root). Se dejan comentados para que "d", "dc",
# etc. no aparezcan como comandos que en realidad nunca van a funcionar.
# Si usas una proot-distro con Docker, descoméntalos.
# alias d="docker"
# alias dps='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Ports}}" | grep --color=auto "NAMES\|Up\|Exited"'
# alias di="docker images"
# alias drm="docker rm -f"
# alias drmi="docker rmi"
# alias dlog="docker logs -f"
# alias dc="docker compose"
# alias dcu="docker compose up -d"
# alias dcd="docker compose down"
# alias dcb="docker compose build"
# alias dcr="docker compose restart"

# ==========================================================================
# Cargar prompt guardado al iniciar sesión (solo si no es SSH)
# ==========================================================================
#if [ -z "$SSH_CONNECTION" ]; then
#    load_saved_prompt
#fi
load_saved_prompt
# ==========================================================================
# END ~/.bash_profile - Configuración de Bash por César
# ==========================================================================

EOF

echo "✅ Configuración aplicada en $BASHRC_PATH"
source "$BASHRC_PATH"
