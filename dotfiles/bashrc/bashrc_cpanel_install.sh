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

VERSION_BASHRC=4.5.1
VERSION_PLATFORM='(CPanel)'

# ::::::::::::: START CONSTANT ::::::::::::::
DATE_HOUR=$(date -u "+%Y-%m-%d %H:%M:%S") # Fecha y hora actual en formato: YYYY-MM-DD_HH:MM:SS (hora local)
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S") # Fecha y hora actual en Perú (UTC -5)
PATH_BASHRC='~/.bashrc'  # Ruta del archivo .bashrc
# ::::::::::::: END CONSTANT ::::::::::::::
# ==========================================================================
# VERSION: (CPanel)
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



# Prompt b谩sico con colores
export PS1='\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$ '

# Agregar información del branch Git al prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/(\1)/p'
}

# Funci贸n para mostrar solo los últimos 3 niveles del path
short_pwd() {

    local pwd_length=${#PWD}
    local max_length=60  # Ajusta este valor según tus preferencias

    if [ $pwd_length -gt $max_length ]; then
        local path_parts=(${PWD//\// })
        local num_parts=${#path_parts[@]}

        if [ $num_parts -gt 3 ]; then
            echo "../${path_parts[$((num_parts-3))]}/${path_parts[$((num_parts-2))]}/${path_parts[$((num_parts-1))]}"
        else
            echo "$PWD"
        fi
    else
        echo "$PWD"
    fi
}

# ========================================
# Configuraci贸n del Prompt
# example output: root@server1 /root/curso_vps (master)#
#export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\$(pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "
export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "



# Si la sesi贸n es SSH, cambia el color del prompt
if [ -n "$SSH_CONNECTION" ]; then
    # ========================================
    # Configuraci贸n del Prompt
    # example output: root@server1 (SSH) /root/curso_vps (master)#
    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h (SSH):\[\e[0m\] \[\e[34m\]\$(short_pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "
    # ::: para servidor Sociedad - spdtss
#    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h (SOCIEDAD):\[\e[0m\] \[\e[34m\]\$(pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "
fi


# ========================
# Sistema de Prompt Persistente
# ========================

# Archivo para guardar el prompt preferido
PROMPT_CONFIG_FILE="$HOME/.prompt_config"

# Función para guardar el prompt actual
save_prompt() {
    echo "$1" > "$PROMPT_CONFIG_FILE"
}

# Función para cargar el prompt guardado
load_saved_prompt() {
    if [ -f "$PROMPT_CONFIG_FILE" ]; then
        local saved_prompt=$(cat "$PROMPT_CONFIG_FILE")
        if [ -n "$saved_prompt" ]; then
            $saved_prompt
        fi
    fi
}

# Función para mostrar el prompt actual guardado
show_saved_prompt() {
    if [ -f "$PROMPT_CONFIG_FILE" ]; then
        local saved_prompt=$(cat "$PROMPT_CONFIG_FILE")
        if [ -n "$saved_prompt" ]; then
            echo -e "${BGreen}Prompt guardado: ${Yellow}$saved_prompt${Color_Off}"
        else
            echo -e "${BRed}No hay prompt guardado${Color_Off}"
        fi
    else
        echo -e "${BRed}No hay prompt guardado${Color_Off}"
    fi
}

# Función para eliminar el prompt guardado
clear_saved_prompt() {
    if [ -f "$PROMPT_CONFIG_FILE" ]; then
        rm "$PROMPT_CONFIG_FILE"
        echo -e "${BGreen}Prompt guardado eliminado${Color_Off}"
    else
        echo -e "${BRed}No hay prompt guardado para eliminar${Color_Off}"
    fi
}

# ========================
# Funciones para cambiar el prompt
# ========================

# p1 - Prompt completo con fecha, hora y información detallada
# Formato: [fecha hora] usuario@host ruta_acortada (git_branch) $
p1() {
    export PS1="\[\e[36m\][\D{%Y-%m-%d %H:%M:%S}]\[\e[0m\] \[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\$(short_pwd)\[\e[33m\] \$(parse_git_branch)\[\e[0m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '$' ) "
    save_prompt "p1"
}


# === p2 ESTILO HACKING - COLORES MEJORADOS ===

p2() {
     export PS1="\[\033[1;96m\]╭─\[\033[1;95m\]\u\[\033[1;96m\]@\[\033[1;95m\]\h\[\033[1;96m\]─[\[\033[1;93m\]\$(short_pwd)\[\033[1;92m\] \$(parse_git_branch)\[\033[1;96m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;96m\]]"$'\n'"╰─\[\033[1;95m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] "
    save_prompt "p2"
}

# p2 - Matrix Green (estilo Matrix clásico)
p2_matrix() {
    export PS1="\[\033[1;32m\]╭─\[\033[1;92m\]\u\[\033[1;32m\]@\[\033[1;92m\]\h\[\033[1;32m\]─[\[\033[1;96m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;32m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;32m\]]"$'\n'"╰─\[\033[1;92m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '⚡ ❯' )\[\033[0m\] "
    echo -e "${BGreen}Prompt Matrix Green activado${Color_Off}"
}

# p2 - Cyberpunk (cyan/magenta)
p2_cyberpunk() {
    export PS1="\[\033[1;96m\]╭─\[\033[1;95m\]\u\[\033[1;96m\]@\[\033[1;95m\]\h\[\033[1;96m\]─[\[\033[1;93m\]\$(short_pwd)\[\033[1;92m\] \$(parse_git_branch)\[\033[1;96m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;96m\]]"$'\n'"╰─\[\033[1;95m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '💀 ❯' )\[\033[0m\] "
    echo -e "${BCyan}Prompt Cyberpunk activado${Color_Off}"
}

# p2 - Neon Blue (azul neón)
p2_neon() {
    export PS1="\[\033[1;94m\]╭─\[\033[1;96m\]\u\[\033[1;94m\]@\[\033[1;96m\]\h\[\033[1;94m\]─[\[\033[1;97m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;94m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;94m\]]"$'\n'"╰─\[\033[1;96m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] "
    echo -e "${BBlue}Prompt Neon Blue activado${Color_Off}"
}

# p2 - Hacker Terminal (verde/negro intenso)
p2_terminal() {
    export PS1="\[\033[1;92m\]╭─\[\033[1;32m\]\u\[\033[1;92m\]@\[\033[1;32m\]\h\[\033[1;92m\]─[\[\033[1;97m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;92m\] [\[\033[1;33m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;92m\]]"$'\n'"╰─\[\033[1;32m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] "
    echo -e "${BGreen}Prompt Hacker Terminal activado${Color_Off}"
}

# p2 - Fire (rojo/naranja)
p2_fire() {
    export PS1="\[\033[1;91m\]╭─\[\033[1;93m\]\u\[\033[1;91m\]@\[\033[1;93m\]\h\[\033[1;91m\]─[\[\033[1;97m\]\$(short_pwd)\[\033[1;92m\] \$(parse_git_branch)\[\033[1;91m\] [\[\033[1;95m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;91m\]]"$'\n'"╰─\[\033[1;93m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] "
    echo -e "${BRed}Prompt Fire activado${Color_Off}"
}

# p2 - Rainbow Hacker (multicolor vibrante)
p2_rainbow() {
    export PS1="\[\033[1;95m\]╭─\[\033[1;96m\]\u\[\033[1;95m\]@\[\033[1;92m\]\h\[\033[1;95m\]─[\[\033[1;93m\]\$(short_pwd)\[\033[1;94m\] \$(parse_git_branch)\[\033[1;95m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;95m\]]"$'\n'"╰─\[\033[1;97m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] "
    echo -e "${BPurple}Prompt Rainbow Hacker activado${Color_Off}"
}

# p2 - Dark Mode Elite (gris/blanco)
p2_elite() {
    export PS1="\[\033[1;37m\]╭─\[\033[1;96m\]\u\[\033[1;37m\]@\[\033[1;96m\]\h\[\033[1;37m\]─[\[\033[1;92m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;37m\] [\[\033[1;91m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;37m\]]"$'\n'"╰─\[\033[1;96m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] "
    echo -e "${BWhite}Prompt Elite activado${Color_Off}"
}

# p2 - Retro Wave (magenta/cyan estilo 80s)
p2_retro() {
    export PS1="\[\033[1;95m\]╭─\[\033[1;96m\]\u\[\033[1;95m\]@\[\033[1;96m\]\h\[\033[1;95m\]─[\[\033[1;97m\]\$(short_pwd)\[\033[1;93m\] \$(parse_git_branch)\[\033[1;95m\] [\[\033[1;92m\]\D{%Y-%m-%d %H:%M:%S}\[\033[1;95m\]]"$'\n'"╰─\[\033[1;96m\]\$( [ \$(id -u) -eq 0 ] && echo '#' || echo '❯' )\[\033[0m\] "
    echo -e "${BPurple}Prompt Retro Wave activado${Color_Off}"
}


# p3 - Prompt Pure/Minimal (súper minimalista)
# Formato: directorio_actual (git_branch) ❯
p3() {
    export PS1="\[\e[34m\]\W\[\e[0m\]\[\e[1;33m\]\$(parse_git_branch)\[\e[0m\] ❯ "
    save_prompt "p3"
}

# p4 - Prompt Two-Line (dos líneas para mejor legibilidad)
# Línea 1: usuario@host ruta_completa
# Línea 2: ❯
p4() {
    export PS1="\[\e[35m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[0m\]\n\[\e[32m\]❯\[\e[0m\] "
    save_prompt "p4"
}

# p5 - Prompt Ultra Minimal (solo símbolo colorido)
# Formato: ❯
p5() {
    export PS1="\[\e[1;31m\]❯\[\e[0m\] "
    save_prompt "p5"
}

# p - Función de ayuda para mostrar todos los prompts disponibles
p() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "${BYellow}=== PROMPTS DISPONIBLES ===${Color_Off}"
        echo ""
        echo -e "${BGreen}p1${Color_Off} - ${Cyan}Prompt Completo${Color_Off}"
        echo -e "     Fecha y hora completa + usuario@host + directorio + Git + indicador root"
        echo -e "     ${Gray}Ejemplo: [2025-09-22 15:30:25] cesar@host /d/repos/curso_linux (master) \$${Color_Off}"
        echo ""
        echo -e "${BGreen}p2${Color_Off} - ${Cyan}Hacker Style (Cyberpunk)${Color_Off}"
        echo -e "     Estilo hacker con líneas elegantes y colores cyan/magenta"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─💀 ❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p2_matrix${Color_Off} - ${Cyan}Matrix Green${Color_Off}"
        echo -e "     Estilo Matrix clásico con colores verdes"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─⚡ ❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p2_cyberpunk${Color_Off} - ${Cyan}Cyberpunk${Color_Off}"
        echo -e "     Colores cyan/magenta estilo cyberpunk"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─💀 ❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p2_neon${Color_Off} - ${Cyan}Neon Blue${Color_Off}"
        echo -e "     Azul neón vibrante"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p2_terminal${Color_Off} - ${Cyan}Hacker Terminal${Color_Off}"
        echo -e "     Verde/negro intenso estilo terminal hacker"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p2_fire${Color_Off} - ${Cyan}Fire${Color_Off}"
        echo -e "     Colores rojo/naranja como fuego"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p2_rainbow${Color_Off} - ${Cyan}Rainbow Hacker${Color_Off}"
        echo -e "     Multicolor vibrante"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p2_elite${Color_Off} - ${Cyan}Dark Mode Elite${Color_Off}"
        echo -e "     Gris/blanco elegante"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p2_retro${Color_Off} - ${Cyan}Retro Wave${Color_Off}"
        echo -e "     Magenta/cyan estilo años 80"
        echo -e "     ${Gray}Ejemplo: ╭─ cesar@host─[/path] (branch) [15:30:25]${Color_Off}"
        echo -e "     ${Gray}         ╰─❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p3${Color_Off} - ${Cyan}Pure/Minimal${Color_Off}"
        echo -e "     Directorio actual + rama Git (si existe) + símbolo"
        echo -e "     ${Gray}Ejemplo: curso_linux${BYellow}(master)${Color_Off}${Gray} ❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p4${Color_Off} - ${Cyan}Two-Line${Color_Off}"
        echo -e "     Información completa en dos líneas"
        echo -e "     ${Gray}Ejemplo: cesar@host /d/repos/curso_linux${Color_Off}"
        echo -e "     ${Gray}         ❯${Color_Off}"
        echo ""
        echo -e "${BGreen}p5${Color_Off} - ${Cyan}Ultra Minimal${Color_Off}"
        echo -e "     Solo símbolo en rojo brillante"
        echo -e "     ${Gray}Ejemplo: ${BRed}❯${Color_Off}"
        echo ""
        echo -e "${BYellow}Uso:${Color_Off} Escribe ${Yellow}p1${Color_Off}, ${Yellow}p2${Color_Off}, ${Yellow}p2_matrix${Color_Off}, ${Yellow}p3${Color_Off}, etc. para activar cada prompt"
        echo -e "${BYellow}Ayuda:${Color_Off} ${Yellow}p -h${Color_Off} para mostrar este menú"
        echo ""
        echo -e "${BYellow}=== GESTIÓN DE PROMPT PERSISTENTE ===${Color_Off}"
        echo -e "${BGreen}show_saved_prompt${Color_Off} - ${Cyan}Mostrar el prompt actualmente guardado${Color_Off}"
        echo -e "${BGreen}clear_saved_prompt${Color_Off} - ${Cyan}Eliminar el prompt guardado${Color_Off}"
        echo -e "${BGreen}load_saved_prompt${Color_Off} - ${Cyan}Cargar el prompt guardado manualmente${Color_Off}"
        echo ""
        echo -e "${BCyan}Nota:${Color_Off} Los prompts se guardan automáticamente al activarlos y se cargan al iniciar sesión"
        echo ""
    else
        echo -e "${BRed}Uso:${Color_Off} p -h    ${Gray}(para ver todos los prompts disponibles)${Color_Off}"
        echo -e "${BRed}     ${Color_Off} p1, p2, p2_matrix, p3, p4, p5   ${Gray}(para activar un prompt específico)${Color_Off}"
    fi
}


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
alias update='sudo apt update && sudo apt upgrade -y' # Actualizar sistema
alias reload="source $PATH_BASHRC"           # Recargar configuraciones de Bash
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
# if [ -x /usr/bin/dircolors ]; then
#    test -r ~/.dircolors && eval "$(dircolors ~/.dircolors)" || eval "$(dircolors -b)"
#    alias ls='ls --color=auto'
#fi
if command -v dircolors &> /dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# ========================
# 6. Funciones personalizadas
# ========================


# Buscar texto en archivos con colores personalizados (ripgrep/grep)
st() {
    local pattern=""
    local directory="."
    local case_sensitive=false
    local file_filter=""
    local exclude_pattern=""
    local max_depth=""
    local show_line_numbers=true
    local context_lines=""
    local word_boundary=false
    local use_ripgrep=false
    local force_grep=false

    # Detectar inicialmente si ripgrep est谩 disponible
    if command -v rg >/dev/null 2>&1; then
        use_ripgrep=true
    fi

    # Funci贸n de ayuda
    show_help() {
        local tool_name
        if $use_ripgrep; then
            tool_name="${BGreen}ripgrep (rg)${Color_Off}"
        else
            tool_name="${Yellow}grep${Color_Off}"
        fi

        echo -e "${BYellow}Uso:${Color_Off} st [opciones] 'texto_a_buscar'"
        echo -e "${Gray}Usando: $tool_name${Color_Off}"
        echo ""
        echo -e "${BCyan}Opciones:${Color_Off}"
        echo -e "  ${Green}-d, --dir DIRECTORIO${Color_Off}    Buscar en directorio específico (por defecto: directorio actual)"
        echo -e "  ${Green}-i, --ignore-case${Color_Off}      B煤squeda sin distinguir mayúsculas/minúsculas"
        echo -e "  ${Green}-f, --files PATRÓN${Color_Off}     Buscar solo en archivos que coincidan con patrón (ej: '*.txt')"
        echo -e "  ${Green}-e, --exclude PATRÓN${Color_Off}   Excluir archivos que coincidan con patrón"
        echo -e "  ${Green}-m, --max-depth NUM${Color_Off}    Profundidad máxima de búsqueda"
        echo -e "  ${Green}-n, --no-line-numbers${Color_Off}  No mostrar números de línea"
        echo -e "  ${Green}-C, --context NUM${Color_Off}      Mostrar NUM líneas de contexto antes y despu茅s"
        echo -e "  ${Green}-w, --word${Color_Off}             Buscar palabras completas solamente"
        echo -e "  ${BYellow}-g, --force-grep${Color_Off}       ${BRed}Forzar el uso de grep${Color_Off} (incluso si ripgrep est谩 disponible)"
        echo -e "  ${Green}-h, --help${Color_Off}             Mostrar esta ayuda"
        echo ""
        echo -e "${BCyan}Ejemplos:${Color_Off}"
        echo -e "  ${Yellow}st 'function'${Color_Off}              # Buscar texto en todos los archivos"
        echo -e "  ${Yellow}st -i 'error'${Color_Off}              # B煤squeda insensitive a mayúsculas"
        echo -e "  ${Yellow}st -f '*.js' 'console'${Color_Off}     # Buscar solo en archivos .js"
        echo -e "  ${Yellow}st -C 3 'TODO'${Color_Off}             # Mostrar 3 líneas de contexto"
        echo -e "  ${Yellow}st -w 'test'${Color_Off}               # Buscar palabra completa 'test'"
        echo -e "  ${Yellow}st -d /home 'config'${Color_Off}       # Buscar en directorio específico"
        echo -e "  ${Yellow}st -e '*.log' 'error'${Color_Off}      # Excluir archivos .log"
        echo ""
        echo -e "${BYellow}Forzar herramienta espec铆fica:${Color_Off}"
        echo -e "  ${BYellow}st -g 'function'${Color_Off}           # ${BRed}Forzar uso de grep${Color_Off} (comparar con ripgrep)"
        return 0
    }

    # Procesar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                return 0
                ;;
            -d|--dir)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    directory="$2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --dir requiere un directorio" >&2
                    return 1
                fi
                ;;
            -i|--ignore-case)
                case_sensitive=true
                shift
                ;;
            -f|--files)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    file_filter="$2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --files requiere un patrón" >&2
                    return 1
                fi
                ;;
            -e|--exclude)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    exclude_pattern="$2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --exclude requiere un patrón" >&2
                    return 1
                fi
                ;;
            -m|--max-depth)
                if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                    max_depth="$2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --max-depth requiere un n煤mero" >&2
                    return 1
                fi
                ;;
            -n|--no-line-numbers)
                show_line_numbers=false
                shift
                ;;
            -C|--context)
                if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                    context_lines="$2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --context requiere un n煤mero" >&2
                    return 1
                fi
                ;;
            -w|--word)
                word_boundary=true
                shift
                ;;
            -g|--force-grep)
                force_grep=true
                use_ripgrep=false
                shift
                ;;
            -*)
                echo -e "${BRed}Error:${Color_Off} Opci贸n desconocida '$1'" >&2
                echo -e "Usa '${Yellow}st --help${Color_Off}' para ver las opciones disponibles"
                return 1
                ;;
            *)
                if [[ -z "$pattern" ]]; then
                    pattern="$1"
                    shift
                else
                    echo -e "${BRed}Error:${Color_Off} Solo se permite un patrón de búsqueda" >&2
                    return 1
                fi
                ;;
        esac
    done

    # Verificar que se proporcion贸 un patrón
    if [[ -z "$pattern" ]]; then
        echo -e "${BRed}Error:${Color_Off} Debes especificar un texto a buscar"
        echo -e "${BYellow}Uso:${Color_Off} st 'texto_a_buscar'"
        echo -e "Usa '${Yellow}st --help${Color_Off}' para más información"
        return 1
    fi

    # Verificar que el directorio existe
    if [[ ! -d "$directory" ]]; then
        echo -e "${BRed}Error:${Color_Off} El directorio '${Yellow}$directory${Color_Off}' no existe" >&2
        return 1
    fi

    # Mostrar información de búsqueda
    local tool_info
    if $use_ripgrep; then
        tool_info="${BGreen}ripgrep${Color_Off}"
    else
        tool_info="${Yellow}grep${Color_Off}"
    fi

    echo -e "${BCyan}[>] Buscando texto:${Color_Off} ${BYellow}'$pattern'${Color_Off} ${Gray}(usando $tool_info)${Color_Off}"
    echo -e "${BCyan}[DIR] En directorio:${Color_Off} ${BBlue}$(realpath "$directory")${Color_Off}"
    if [[ -n "$file_filter" ]]; then
        echo -e "${BCyan}[FILTER] Filtro de archivos:${Color_Off} ${Yellow}$file_filter${Color_Off}"
    fi
    if [[ -n "$exclude_pattern" ]]; then
        echo -e "${BCyan}[EXCLUDE] Excluir:${Color_Off} ${Yellow}$exclude_pattern${Color_Off}"
    fi
    echo ""

    # Ejecutar búsqueda según la herramienta disponible
    if $use_ripgrep; then
        # Usar ripgrep
        local rg_opts="--color=always --heading --with-filename"

        # Agregar opciones según par谩metros
        if $case_sensitive; then
            rg_opts="$rg_opts -i"
        fi

        if $show_line_numbers; then
            rg_opts="$rg_opts -n"
        else
            rg_opts="$rg_opts -N"
        fi

        if [[ -n "$context_lines" ]]; then
            rg_opts="$rg_opts -C $context_lines"
        fi

        if $word_boundary; then
            rg_opts="$rg_opts -w"
        fi

        if [[ -n "$max_depth" ]]; then
            rg_opts="$rg_opts --max-depth $max_depth"
        fi

        if [[ -n "$file_filter" ]]; then
            rg_opts="$rg_opts -g '$file_filter'"
        fi

        if [[ -n "$exclude_pattern" ]]; then
            rg_opts="$rg_opts -g '!$exclude_pattern'"
        fi

        # Ejecutar ripgrep y obtener estad铆sticas
        local results
        results=$(eval "rg $rg_opts '$pattern' '$directory'" 2>/dev/null)

        if [[ -z "$results" ]]; then
            echo -e "${BRed}[X] No se encontraron coincidencias para '${BYellow}$pattern${Color_Off}${BRed}'${Color_Off}"
            return 1
        else
            echo "$results"
            echo ""

            # Contar coincidencias de manera más precisa con ripgrep
            local match_count
            local file_count

            # Usar ripgrep con --count-matches para obtener estad铆sticas precisas
            local stats_opts="--count-matches"
            if $case_sensitive; then
                stats_opts="$stats_opts -i"
            fi
            if $word_boundary; then
                stats_opts="$stats_opts -w"
            fi
            if [[ -n "$max_depth" ]]; then
                stats_opts="$stats_opts --max-depth $max_depth"
            fi
            if [[ -n "$file_filter" ]]; then
                stats_opts="$stats_opts -g '$file_filter'"
            fi
            if [[ -n "$exclude_pattern" ]]; then
                stats_opts="$stats_opts -g '!$exclude_pattern'"
            fi

            # Obtener estad铆sticas
            local stats_result
            stats_result=$(eval "rg $stats_opts '$pattern' '$directory'" 2>/dev/null)

            if [[ -n "$stats_result" ]]; then
                file_count=$(echo "$stats_result" | wc -l)
                match_count=$(echo "$stats_result" | awk -F: '{sum += $2} END {print sum}' 2>/dev/null || echo "0")
                echo -e "${BGreen}[OK] Encontradas ${BWhite}$match_count${Color_Off}${BGreen} coincidencias en ${BWhite}$file_count${Color_Off}${BGreen} archivos${Color_Off}"
            else
                echo -e "${BGreen}[OK] B煤squeda completada con ripgrep${Color_Off}"
            fi
        fi

    else
        # Usar grep como fallback
        local grep_opts="-r --color=always"

        if $case_sensitive; then
            grep_opts="$grep_opts -i"
        fi

        if $show_line_numbers; then
            grep_opts="$grep_opts -n"
        fi

        if [[ -n "$context_lines" ]]; then
            grep_opts="$grep_opts -C $context_lines"
        fi

        if $word_boundary; then
            grep_opts="$grep_opts -w"
        fi

        # Construir comando find para filtros
        local find_cmd="find \"$directory\""

        if [[ -n "$max_depth" ]]; then
            find_cmd="$find_cmd -maxdepth $max_depth"
        fi

        find_cmd="$find_cmd -type f"

        # Excluir directorios comunes
        find_cmd="$find_cmd ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/.svn/*'"

        if [[ -n "$file_filter" ]]; then
            find_cmd="$find_cmd -name '$file_filter'"
        fi

        if [[ -n "$exclude_pattern" ]]; then
            find_cmd="$find_cmd ! -name '$exclude_pattern'"
        fi

        # Ejecutar búsqueda con grep
        local results=""
        local file_count=0
        local match_count=0

        while IFS= read -r -d '' file; do
            ((file_count++))
            local grep_result
            grep_result=$(eval "grep $grep_opts '$pattern' \"$file\"" 2>/dev/null)
            if [[ -n "$grep_result" ]]; then
                local file_matches=$(echo "$grep_result" | wc -l)
                ((match_count += file_matches))

                echo -e "${BPurple}[FILE] $file${Color_Off} ${Gray}($file_matches coincidencias)${Color_Off}"
                echo "$grep_result" | while IFS= read -r line; do
                    echo -e "  $line"
                done
                echo ""
            fi
        done < <(eval "$find_cmd -print0" 2>/dev/null)

        if [[ $match_count -eq 0 ]]; then
            echo -e "${BRed}[X] No se encontraron coincidencias para '${BYellow}$pattern${Color_Off}${BRed}' en $file_count archivos${Color_Off}"
            return 1
        else
            echo -e "${BGreen}[OK] Encontradas ${BWhite}$match_count${Color_Off}${BGreen} coincidencias en ${BWhite}$file_count${Color_Off}${BGreen} archivos revisados${Color_Off}"
        fi
    fi
}

# Buscar archivos por nombre con colores personalizados
sf2() {
    local pattern=""
    local directory="."
    local case_sensitive=false
    local type_filter=""
    local max_depth=""

    # Funci贸n de ayuda
    show_help() {
        echo -e "${BYellow}Uso:${Color_Off} sf2 [opciones] 'patrón_de_archivo'"
        echo ""
        echo -e "${BCyan}Opciones:${Color_Off}"
        echo -e "  ${Green}-d, --dir DIRECTORIO${Color_Off}    Buscar en directorio específico (por defecto: directorio actual)"
        echo -e "  ${Green}-i, --ignore-case${Color_Off}      B煤squeda sin distinguir mayúsculas/minúsculas"
        echo -e "  ${Green}-f, --files-only${Color_Off}       Buscar solo archivos regulares"
        echo -e "  ${Green}-D, --dirs-only${Color_Off}        Buscar solo directorios"
        echo -e "  ${Green}-m, --max-depth NUM${Color_Off}    Profundidad máxima de búsqueda"
        echo -e "  ${Green}-h, --help${Color_Off}             Mostrar esta ayuda"
        echo ""
        echo -e "${BCyan}Ejemplos:${Color_Off}"
        echo -e "  ${Yellow}sf2 ejemplo.sh${Color_Off}          # Buscar archivo exacto"
        echo -e "  ${Yellow}sf2 'ejemplo*'${Color_Off}          # Buscar con wildcards"
        echo -e "  ${Yellow}sf2 plo${Color_Off}                 # Buscar archivos que contengan 'plo'"
        echo -e "  ${Yellow}sf2 -i '*.PDF'${Color_Off}          # Buscar PDFs sin importar mayúsculas"
        echo -e "  ${Yellow}sf2 -f -d /home script${Color_Off}  # Buscar solo archivos que contengan 'script' en /home"
        echo -e "  ${Yellow}sf2 -D config${Color_Off}           # Buscar solo directorios que contengan 'config'"
        return 0
    }

    # Procesar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                return 0
                ;;
            -d|--dir)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    directory="$2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --dir requiere un directorio" >&2
                    return 1
                fi
                ;;
            -i|--ignore-case)
                case_sensitive=true
                shift
                ;;
            -f|--files-only)
                type_filter="-type f"
                shift
                ;;
            -D|--dirs-only)
                type_filter="-type d"
                shift
                ;;
            -m|--max-depth)
                if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                    max_depth="-maxdepth $2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --max-depth requiere un n煤mero" >&2
                    return 1
                fi
                ;;
            -*)
                echo -e "${BRed}Error:${Color_Off} Opci贸n desconocida '$1'" >&2
                echo -e "Usa '${Yellow}sf2 --help${Color_Off}' para ver las opciones disponibles"
                return 1
                ;;
            *)
                if [[ -z "$pattern" ]]; then
                    pattern="$1"
                    shift
                else
                    echo -e "${BRed}Error:${Color_Off} Solo se permite un patrón de búsqueda" >&2
                    return 1
                fi
                ;;
        esac
    done

    # Verificar que se proporcion贸 un patrón
    if [[ -z "$pattern" ]]; then
        echo -e "${BRed}Error:${Color_Off} Debes especificar un patrón de búsqueda"
        echo -e "${BYellow}Uso:${Color_Off} sf2 'patrón_de_archivo'"
        echo -e "Usa '${Yellow}sf2 --help${Color_Off}' para más información"
        return 1
    fi

    # Verificar que el directorio existe
    if [[ ! -d "$directory" ]]; then
        echo -e "${BRed}Error:${Color_Off} El directorio '${Yellow}$directory${Color_Off}' no existe" >&2
        return 1
    fi

    # Construir el comando find
    local find_cmd="find \"$directory\" $max_depth $type_filter"

    # Determinar el tipo de búsqueda y agregar opciones de case sensitivity
    if $case_sensitive; then
        find_cmd="$find_cmd -iname"
    else
        find_cmd="$find_cmd -name"
    fi

    # Si el patrón no contiene wildcards, buscar como substring
    if [[ "$pattern" != *"*"* && "$pattern" != *"?"* && "$pattern" != *"["* ]]; then
        pattern="*${pattern}*"
    fi

    # Mostrar información de búsqueda
    echo -e "${BCyan}[>] Buscando archivos que coincidan con:${Color_Off} ${BYellow}$pattern${Color_Off}"
    echo -e "${BCyan}[DIR] En directorio:${Color_Off} ${BBlue}$(realpath "$directory")${Color_Off}"
    echo ""

    # Ejecutar la búsqueda
    local results
    results=$(eval "$find_cmd \"$pattern\" 2>/dev/null | sort")

    if [[ -z "$results" ]]; then
        echo -e "${BRed}[X] No se encontraron archivos que coincidan con el patrón '${BYellow}$pattern${Color_Off}${BRed}'${Color_Off}"
        return 1
    else
        # Mostrar resultados con colores personalizados
        echo "$results" | while IFS= read -r file; do
            if [[ -d "$file" ]]; then
                # Es un directorio
                echo -e "${BBlue}[DIR] $file${Color_Off}"
            elif [[ -x "$file" ]]; then
                # Es un archivo ejecutable
                echo -e "${BGreen}[EXE] $file${Color_Off}"
            elif [[ "$file" == *.sh || "$file" == *.py || "$file" == *.pl || "$file" == *.rb ]]; then
                # Es un script
                echo -e "${BPurple}[SCR] $file${Color_Off}"
            elif [[ "$file" == *.txt || "$file" == *.md || "$file" == *.doc* ]]; then
                # Es un documento de texto
                echo -e "${BCyan}[DOC] $file${Color_Off}"
            elif [[ "$file" == *.jpg || "$file" == *.png || "$file" == *.gif || "$file" == *.jpeg ]]; then
                # Es una imagen
                echo -e "${BYellow}[IMG] $file${Color_Off}"
            elif [[ "$file" == *.zip || "$file" == *.tar || "$file" == *.gz || "$file" == *.rar ]]; then
                # Es un archivo comprimido
                echo -e "${Purple}[ZIP] $file${Color_Off}"
            else
                # Archivo regular
                echo -e "${Green}[FILE] $file${Color_Off}"
            fi
        done

        # Mostrar contador de resultados
        local count=$(echo "$results" | wc -l)
        echo ""
        echo -e "${BGreen}[OK] Encontrados ${BWhite}$count${Color_Off}${BGreen} resultado(s)${Color_Off}"
    fi
}

# Buscar directorios por nombre con colores personalizados
sd2() {
    local pattern=""
    local directory="."
    local case_sensitive=false
    local max_depth=""

    # Funci贸n de ayuda
    show_help() {
        echo -e "${BYellow}Uso:${Color_Off} sd2 [opciones] 'patrón_de_directorio'"
        echo ""
        echo -e "${BCyan}Opciones:${Color_Off}"
        echo -e "  ${Green}-d, --dir DIRECTORIO${Color_Off}    Buscar en directorio específico (por defecto: directorio actual)"
        echo -e "  ${Green}-i, --ignore-case${Color_Off}      B煤squeda sin distinguir mayúsculas/minúsculas"
        echo -e "  ${Green}-m, --max-depth NUM${Color_Off}    Profundidad máxima de búsqueda"
        echo -e "  ${Green}-a, --all${Color_Off}              Incluir directorios ocultos (que empiecen con .)"
        echo -e "  ${Green}-h, --help${Color_Off}             Mostrar esta ayuda"
        echo ""
        echo -e "${BCyan}Ejemplos:${Color_Off}"
        echo -e "  ${Yellow}sd2 config${Color_Off}              # Buscar directorios que contengan 'config'"
        echo -e "  ${Yellow}sd2 'src*'${Color_Off}              # Buscar directorios que empiecen con 'src'"
        echo -e "  ${Yellow}sd2 node${Color_Off}                # Buscar directorios que contengan 'node'"
        echo -e "  ${Yellow}sd2 -i 'TEST'${Color_Off}           # Buscar sin importar mayúsculas"
        echo -e "  ${Yellow}sd2 -d /home backup${Color_Off}     # Buscar directorios con 'backup' en /home"
        echo -e "  ${Yellow}sd2 -a '.git'${Color_Off}           # Buscar directorios .git (incluye ocultos)"
        echo -e "  ${Yellow}sd2 -m 2 temp${Color_Off}           # Buscar solo hasta 2 niveles de profundidad"
        return 0
    }

    # Procesar argumentos
    local include_hidden=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                return 0
                ;;
            -d|--dir)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    directory="$2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --dir requiere un directorio" >&2
                    return 1
                fi
                ;;
            -i|--ignore-case)
                case_sensitive=true
                shift
                ;;
            -a|--all)
                include_hidden=true
                shift
                ;;
            -m|--max-depth)
                if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                    max_depth="-maxdepth $2"
                    shift 2
                else
                    echo -e "${BRed}Error:${Color_Off} --max-depth requiere un n煤mero" >&2
                    return 1
                fi
                ;;
            -*)
                echo -e "${BRed}Error:${Color_Off} Opci贸n desconocida '$1'" >&2
                echo -e "Usa '${Yellow}sd2 --help${Color_Off}' para ver las opciones disponibles"
                return 1
                ;;
            *)
                if [[ -z "$pattern" ]]; then
                    pattern="$1"
                    shift
                else
                    echo -e "${BRed}Error:${Color_Off} Solo se permite un patrón de búsqueda" >&2
                    return 1
                fi
                ;;
        esac
    done

    # Verificar que se proporcion贸 un patrón
    if [[ -z "$pattern" ]]; then
        echo -e "${BRed}Error:${Color_Off} Debes especificar un patrón de búsqueda"
        echo -e "${BYellow}Uso:${Color_Off} sd2 'patrón_de_directorio'"
        echo -e "Usa '${Yellow}sd2 --help${Color_Off}' para más información"
        return 1
    fi

    # Verificar que el directorio existe
    if [[ ! -d "$directory" ]]; then
        echo -e "${BRed}Error:${Color_Off} El directorio '${Yellow}$directory${Color_Off}' no existe" >&2
        return 1
    fi

    # Construir el comando find (solo directorios)
    local find_cmd="find \"$directory\" $max_depth -type d"

    # Excluir directorios ocultos si no se especifica -a
    if ! $include_hidden; then
        find_cmd="$find_cmd ! -path '*/.*'"
    fi

    # Determinar el tipo de búsqueda y agregar opciones de case sensitivity
    if $case_sensitive; then
        find_cmd="$find_cmd -iname"
    else
        find_cmd="$find_cmd -name"
    fi

    # Si el patrón no contiene wildcards, buscar como substring
    if [[ "$pattern" != *"*"* && "$pattern" != *"?"* && "$pattern" != *"["* ]]; then
        pattern="*${pattern}*"
    fi

    # Mostrar información de búsqueda
    echo -e "${BCyan}[>] Buscando directorios que coincidan con:${Color_Off} ${BYellow}$pattern${Color_Off}"
    echo -e "${BCyan}[DIR] En directorio:${Color_Off} ${BBlue}$(realpath "$directory")${Color_Off}"
    if ! $include_hidden; then
        echo -e "${BCyan}[INFO] Excluyendo directorios ocultos${Color_Off} ${Gray}(usa -a para incluirlos)${Color_Off}"
    fi
    echo ""

    # Ejecutar la búsqueda
    local results
    results=$(eval "$find_cmd \"$pattern\" 2>/dev/null | sort")

    if [[ -z "$results" ]]; then
        echo -e "${BRed}[X] No se encontraron directorios que coincidan con el patrón '${BYellow}$pattern${Color_Off}${BRed}'${Color_Off}"
        return 1
    else
        # Mostrar resultados con colores personalizados para directorios
        echo "$results" | while IFS= read -r dir; do
            # Determinar el tipo de directorio y asignar color
            local dir_name=$(basename "$dir")

            if [[ "$dir_name" =~ ^\. ]]; then
                # Directorio oculto
                echo -e "${Gray}[HIDDEN] $dir${Color_Off}"
            elif [[ "$dir_name" =~ ^(src|source|lib|library)$ ]]; then
                # Directorio de c贸digo fuente
                echo -e "${BPurple}[SRC] $dir${Color_Off}"
            elif [[ "$dir_name" =~ ^(test|tests|spec|specs)$ ]]; then
                # Directorio de tests
                echo -e "${BYellow}[TEST] $dir${Color_Off}"
            elif [[ "$dir_name" =~ ^(config|conf|cfg|settings)$ ]]; then
                # Directorio de configuración
                echo -e "${BCyan}[CONF] $dir${Color_Off}"
            elif [[ "$dir_name" =~ ^(doc|docs|documentation)$ ]]; then
                # Directorio de documentación
                echo -e "${BWhite}[DOCS] $dir${Color_Off}"
            elif [[ "$dir_name" =~ ^(bin|binary|exe)$ ]]; then
                # Directorio de binarios
                echo -e "${BGreen}[BIN] $dir${Color_Off}"
            elif [[ "$dir_name" =~ ^(backup|bak|old|archive)$ ]]; then
                # Directorio de respaldo
                echo -e "${Purple}[BAK] $dir${Color_Off}"
            elif [[ "$dir_name" =~ ^(temp|tmp|cache)$ ]]; then
                # Directorio temporal
                echo -e "${Yellow}[TEMP] $dir${Color_Off}"
            elif [[ "$dir_name" =~ (node_modules|\.git|\.svn|build|dist|target)$ ]]; then
                # Directorios de sistema/build
                echo -e "${Red}[SYS] $dir${Color_Off}"
            else
                # Directorio regular
                echo -e "${BBlue}[DIR] $dir${Color_Off}"
            fi
        done

        # Mostrar contador de resultados
        local count=$(echo "$results" | wc -l)
        echo ""
        echo -e "${BGreen}[OK] Encontrados ${BWhite}$count${Color_Off}${BGreen} directorio(s)${Color_Off}"
    fi
}
# Crear directorio y navegar a él
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Mostrar tamaño de directorios
dirsize() {
    du -sh "${1:-.}"/* 2>/dev/null | sort -rh
}

# Información rápida del sistema
sysinfo() {
    echo "=== INFORMACIÓN DEL SISTEMA ==="
    echo "Hostname: $(hostname)"
    echo "Usuario: $USER"
    echo "Sistema: $(lsb_release -d 2>/dev/null | cut -f2 || uname -s)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "Memoria: $(free -h | grep '^Mem:' | awk '{print $3"/"$2}')"
    echo "Disco: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}')"
    echo "IP: $(hostname -I | awk '{print $1}' 2>/dev/null || echo 'N/A')"
}
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

# ================================================
# funcion requiere lnav
# ================================================
log() {
    # 1) Requiere al menos un argumento
    if [ $# -eq 0 ]; then
        echo -e "--- ${Yellow}Advertencia:${Color_Off} no se proporcionaron rutas."
        echo -e "Uso: log <archivo|directorio> [más_rutas...]"
        echo -e "Ej.:  log /var/log/mail.log /var/log/lfd.log /var/log"
        return 2
    fi

    # 2) Verificar que lnav esté disponible
    if ! command -v lnav >/dev/null 2>&1; then
        echo -e "--- ${Red}Error:${Color_Off} 'lnav' no está instalado o no está en el PATH."
        echo -e "     Instálalo con: ${Green}sudo snap install lnav${Color_Off} (o tu método preferido)"
        return 127
    fi

    # 3) Filtrar rutas existentes y avisar de las inexistentes
    local found=()
    local missing=0
    for path in "$@"; do
        if [ -e "$path" ]; then
            found+=("$path")
        else
            echo -e "--- ${Yellow}Aviso:${Color_Off} la ruta '${path}' no existe (omitida)."
            missing=$((missing+1))
        fi
    done

    # 4) Si no quedó ninguna ruta válida, salir con error
    if [ ${#found[@]} -eq 0 ]; then
        echo -e "--- ${Red}Error:${Color_Off} no hay rutas válidas para abrir."
        echo -e "Uso: log <archivo|directorio> [más_rutas...]"
          echo -e "Ej.:  log /var/log/mail.log /var/log/lfd.log /var/log"
        return 1
    fi

    # 5) Ejecutar lnav en zona horaria America/Lima
    #    Nota: no modifica archivos; solo cambia la visualización.
    TZ=America/Lima lnav "${found[@]}"
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
# check_and_install fzf fzf
# check_and_install tree tree

# ========================
# 7. Menú interactivo
# ========================

alias ls='ls --color=auto'

#if [ -x /usr/bin/dircolors ]; then
#    test -r ~/.dircolors && eval "$(dircolors ~/.dircolors)" || eval "$(dircolors -b)"
#    alias ls='ls --color=auto'
#fi
if command -v dircolors &> /dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
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
  echo -e "${Gray}9) Prompts${Color_Off}"
  echo -e "${Gray}x) Salir${Color_Off}"
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
    9) p -h ;;
    x|X) return ;;
    "") return ;;  # Si se presiona Enter sin escribir nada, salir
  *) echo -e "${Red}Opción inválida${Color_Off}" ; menu ;;
  esac
}

submenu_generales(){
  cls
  echo -e "${Yellow}Submenú Opciones disponibles:${Color_Off}"

  echo -e "${Gray}   - create_file : ${Cyan}Crear un fichero de manera manual${Color_Off}"
  echo -e "${Gray}   - sf2 : ${Cyan} realiza busquedas de archivos (sf2 -h  para ayuda y ejemplos)${Color_Off}"
  echo -e "${Gray}   - sd2 : ${Cyan} realiza busquedas de directorios (sd2 -h  para ayuda y ejemplos)${Color_Off}"
  echo -e "${Gray}   - st : ${Cyan} realiza busqueda de texto en directorio actual (st -h  para ayuda y ejemplos)${Color_Off}"
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


#--------------------------------------------

#    ./conf_funciones_level_2.sh
#    ./conf_funciones_level_2.sh 9090
#    ./conf_funciones_level_2.sh 9090 /E/deysi^

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 8. (Optional)Cargar Script si queremos poner adicionales
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
# Cargar prompt guardado al iniciar sesión
# ==========================================================================
# Cargar automáticamente el prompt guardado (solo si no es SSH)
if [ -z "$SSH_CONNECTION" ]; then
    load_saved_prompt
fi


# ==========================================================================
# END ~/.bashrc - Configuración de Bash por César
# ==========================================================================
EOF

echo "✅ Configuración aplicada en $BASHRC_PATH"
source "$BASHRC_PATH"