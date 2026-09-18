#!/bin/bash

# Ruta del archivo .bashrc
BASHRC_PATH="$HOME/.bashrc"

# Respaldo del archivo original si existe
if [ -f "$BASHRC_PATH" ]; then
    cp "$BASHRC_PATH" "$BASHRC_PATH.bak"
    echo "Se ha creado un respaldo en $BASHRC_PATH.bak"
fi

echo "" > $BASHRC_PATH

# Escribir el nuevo contenido en .bashrc
cat > "$BASHRC_PATH" << 'EOF'
VERSION_BASHRC=5.0.0
VERSION_PLATFORM='(linux, gitbash)'

# ::::::::::::: START CONSTANT ::::::::::::::
# PERF: antes DATE_HOUR_PE probaba "date -d ..." y si fallaba forkeaba un
# "TZ=... date" adicional (hasta 2 procesos solo para esta línea). Con
# TZ=America/Lima directo es siempre 1 solo fork, sin cadenas de fallback.
DATE_HOUR=$(date "+%Y-%m-%d_%H:%M:%S")                       # hora local del sistema
DATE_HOUR_PE=$(TZ="America/Lima" date "+%Y-%m-%d_%H:%M:%S")  # hora Perú (UTC-5)
PATH_BASHRC='~/.bashrc'  # Ruta del archivo .bashrc
# ::::::::::::: END CONSTANT ::::::::::::::

# ==========================================================================
# ~/.bashrc - Configuración de Bash por César (version: 1.0.3)
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

# Fondo gris oscuro,fondo gris claro
Code_background='\e[7;90;47m'   # Black

# Prompt básico con colores
export PS1='\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$ '

# ========================================
# Configuracion del Prompt
# example output: root@server1 /root/curso_vps (master)#
#export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\$(pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '$' ) "
export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '$' ) "

# Si la sesión es SSH, cambia el color del prompt
if [ -n "$SSH_CONNECTION" ]; then
    # ========================================
    # Configuración del Prompt
    # example output: root@server1 (SSH) /root/curso_vps (master)#
    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h (SSH):\[\e[0m\] \[\e[34m\]\$(short_pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '$' ) "
    # ::: para servidor Sociedad - spdtss
#    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h (SOCIEDAD):\[\e[0m\] \[\e[34m\]\$(pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$EUID -eq 0 ] && echo '#' || echo '$' ) "
fi

# Archivo donde se guarda el prompt preferido (funciones p1/p2/../p5 en func_generales.sh)
PROMPT_CONFIG_FILE="$HOME/.prompt_config"

# ========================
# 2. Alias útiles
# ========================

# Alias básicos
alias ll='ls -lh --color=auto'        # Lista archivos con tamaños legibles
alias la='ls -lha --color=auto'       # Lista todos los archivos, incluidos ocultos
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
alias update='sudo apt update && sudo apt upgrade -y' # Actualizar sistema
alias reload="source $PATH_BASHRC"             # Recargar configuraciones de Bash
alias reload_cat="cat $PATH_BASHRC | less"           #
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


# Verificar si el sistema operativo es Linux
# PERF: $OSTYPE es una variable nativa de bash (sin forkear "uname").
if [[ "$OSTYPE" == linux* ]]; then
    ulimit -n 4096
fi

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 8. Cargar librerías de libs_shell (init.sh) + func_generales.sh
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::

scriptPath2=${0%/*}
# PERF: usa ": ${VAR:=...}" por si este bloque se re-ejecuta (p.ej. al
# hacer "source ~/.bashrc" a mano) — evita relanzar id/hostname si ya
# estaban calculados. init.sh (más abajo) hace lo mismo, así que entre
# los dos solo se paga el costo una vez por sesión.
: "${CURRENT_USER:=$(id -un)}"
: "${CURRENT_PC_NAME:=$(hostname)}"
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


# ================== Aliases ==================
# Alias para usar 'batcat' como 'bat' en lugar de 'batcat'
alias bat="batcat"

# ================================================
# ====================== docker ==================
# ================================================
alias d="docker"              # Abreviatura para Docker
alias dps='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Ports}}" | grep --color=auto "NAMES\|Up\|Exited"'
alias di="docker images"      # Listar imagenes
alias drm="docker rm -f"      # Eliminar contenedor forzadamente
alias drmi="docker rmi"       # Eliminar imagen
alias dlog="docker logs -f"   # Ver logs en tiempo real

# Alias basicos para Docker Compose
alias dc="docker compose"     # Abreviatura para Docker Compose
alias dcu="docker compose up -d"   # Iniciar servicios en segundo plano
alias dcd="docker compose down"    # Detener y eliminar servicios
alias dcb="docker compose build"   # Construir servicios
alias dcr="docker compose restart" # Reiniciar servicios

# ==========================================================================
# Cargar prompt guardado al iniciar sesión (solo si no es SSH)
# ==========================================================================
#if [ -z "$SSH_CONNECTION" ]; then
#    load_saved_prompt
#fi
load_saved_prompt
# ==========================================================================
# END ~/.bashrc - Configuración de Bash por César
# ==========================================================================

EOF

echo "✅ Configuración aplicada en $BASHRC_PATH"
source "$BASHRC_PATH"
