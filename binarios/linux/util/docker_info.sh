#!/usr/bin/env bash


# :::::: comando para ejecutar
#     curl -sSL https://raw.githubusercontent.com/cesar23/utils_dev/master/binarios/linux/util/docker_info.sh | bash




# =============================================================================
# 🎬 CONFIGURACIÓN INICIAL
# =============================================================================
export LC_ALL="es_ES.UTF-8"
DATE_HOUR=$(date "+%Y-%m-%d %H:%M:%S")
DATE_HOUR_PE=$(date -u -d "-5 hours" "+%Y-%m-%d %H:%M:%S")
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(hostname)
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"

# =============================================================================
# 🎨 COLORES
# =============================================================================
Color_Off='\e[0m'
Black='\e[0;30m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[1;33m'
Blue='\e[1;34m'
Purple='\e[0;35m'
Cyan='\e[1;36m'
White='\e[1;37m'
Gray='\e[0;90m'

# =============================================================================
# 🐳 COMANDOS DOCKER
# =============================================================================
clear
echo -e "${Cyan}╔══════════════════════════════════════════════════════╗${Color_Off}"
echo -e "${Cyan}║${Green}         🐳 COMANDOS BÁSICOS DE DOCKER               ${Cyan}║${Color_Off}"
echo -e "${Cyan}╚══════════════════════════════════════════════════════╝${Color_Off}"
echo -e "${Gray}🕒 Fecha: ${DATE_HOUR} | Usuario: ${MY_INFO}${Color_Off}\n"

# Información general
echo -e "${Yellow}🔹 Información general${Color_Off}"
echo -e "  ${Blue}docker version${Color_Off}      ${White}# Ver versión de Docker${Color_Off}"
echo -e "  ${Blue}docker info${Color_Off}         ${White}# Info del sistema Docker${Color_Off}"
echo ""

# Imágenes
echo -e "${Yellow}🔹 Imágenes${Color_Off}"
echo -e "  ${Blue}docker images${Color_Off}       ${White}# Listar imágenes locales${Color_Off}"
echo -e "  ${Blue}docker pull <imagen>${Color_Off} ${White}# Descargar imagen${Color_Off}"
echo -e "  ${Blue}docker rmi <imagen>${Color_Off}  ${White}# Eliminar imagen local${Color_Off}"
echo ""

# Contenedores
echo -e "${Yellow}🔹 Contenedores${Color_Off}"
echo -e "  ${Blue}docker ps${Color_Off}           ${White}# Contenedores en ejecución${Color_Off}"
echo -e "  ${Blue}docker ps -a${Color_Off}        ${White}# Todos los contenedores${Color_Off}"
echo -e "  ${Blue}docker run -it <imagen>${Color_Off} ${White}# Crear y ejecutar contenedor interactivo${Color_Off}"
echo -e "  ${Blue}docker start <id>${Color_Off}   ${White}# Iniciar contenedor detenido${Color_Off}"
echo -e "  ${Blue}docker stop <id>${Color_Off}    ${White}# Detener contenedor${Color_Off}"
echo -e "  ${Blue}docker rm <id>${Color_Off}      ${White}# Eliminar contenedor${Color_Off}"
echo -e "  ${Blue}docker stop \$(docker ps -a -q) && docker rm \$(docker ps -a -q)${Color_Off} ${White}# Detener y eliminar TODOS los contenedores${Color_Off}"
echo -e "      ${Gray}# ⚠️ Usar con precaución. Esto borra todos los contenedores.${Color_Off}"
echo ""

# Interacción y monitoreo
echo -e "${Yellow}🔹 Interacción y monitoreo${Color_Off}"
echo -e "  ${Blue}docker logs <id>${Color_Off}               ${White}# Ver logs del contenedor${Color_Off}"
echo -e "  ${Blue}docker exec -it <id> bash${Color_Off}       ${White}# Acceder a bash dentro del contenedor${Color_Off}"
echo -e "      ${Gray}# Ejecutar comando dentro del contenedor:${Color_Off}"
echo -e "      ${Blue}docker exec <id> /bin/bash -c '<comando>'${Color_Off}"
echo -e "      ${Gray}# Ejecutar comando en un directorio específico (ej. /var):${Color_Off}"
echo -e "      ${Blue}docker exec -w /var <id> /bin/bash -c 'ls -l'${Color_Off}"
echo -e "  ${Blue}docker inspect <id>${Color_Off}            ${White}# Info detallada JSON${Color_Off}"
echo -e "  ${Blue}docker top <id>${Color_Off}                ${White}# Procesos dentro del contenedor${Color_Off}"
echo ""


# Volúmenes
echo -e "${Yellow}🔹 Volúmenes${Color_Off}"
echo -e "  ${Blue}docker volume ls${Color_Off}                ${White}# Listar volúmenes${Color_Off}"
echo -e "  ${Blue}docker volume create <nombre>${Color_Off}   ${White}# Crear volumen${Color_Off}"
echo -e "      ${Gray}# Ejemplo:${Color_Off} ${Blue}docker volume create mi_datos${Color_Off}"
echo -e "  ${Blue}docker volume inspect <nombre>${Color_Off}  ${White}# Info de volumen${Color_Off}"
echo -e "  ${Blue}docker volume rm <nombre>${Color_Off}       ${White}# Eliminar volumen${Color_Off}"
echo -e "  ${Blue}docker volume prune${Color_Off}             ${White}# Limpiar volúmenes no usados${Color_Off}"
echo ""

# Redes
echo -e "${Yellow}🔹 Redes (network)${Color_Off}"
echo -e "  ${Blue}docker network ls${Color_Off}                 ${White}# Listar redes disponibles${Color_Off}"
echo -e "  ${Blue}docker network inspect <nombre>${Color_Off}   ${White}# Ver detalles de una red${Color_Off}"
echo -e "  ${Blue}docker network create <nombre>${Color_Off}    ${White}# Crear red personalizada (por defecto bridge)${Color_Off}"
echo -e "      ${Gray}# Ejemplo:${Color_Off} ${Blue}docker network create mi_red${Color_Off}"
echo -e "  ${Blue}docker network rm <nombre>${Color_Off}        ${White}# Eliminar una red${Color_Off}"
echo -e "  ${Blue}docker network connect <red> <contenedor>${Color_Off} ${White}# Conectar contenedor a red${Color_Off}"
echo -e "  ${Blue}docker network disconnect <red> <contenedor>${Color_Off} ${White}# Desconectar contenedor de red${Color_Off}"
echo -e "  ${Blue}docker run --network <red> ...${Color_Off}     ${White}# Usar red personalizada al crear contenedor${Color_Off}"
echo ""

# Montar volúmenes
echo -e "${Yellow}🔹 Montar volumen en contenedor${Color_Off}"
echo -e "  ${Blue}docker run -d -v mi_vol:/app imagen${Color_Off} ${White}# Montar volumen${Color_Off}"
echo -e "  ${Blue}docker run -it --name ubuntu_vol -v mi_datos:/datos ubuntu:24.04 bash${Color_Off} ${White}# Montar volumen en contenedor Ubuntu 24.04${Color_Off}"
echo ""

# Limpieza
echo -e "${Yellow}🔹 Limpieza general${Color_Off}"
echo -e "  ${Blue}docker system prune${Color_Off} ${White}# Limpiar contenedores, imágenes y volúmenes sin uso${Color_Off}"
echo ""

echo -e "${Green}✅ Fin del resumen de comandos Docker.${Color_Off}"
