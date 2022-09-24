# mobax configuraciones

### configuracion de mobax

<img width="50%" src="https://i.imgur.com/ZAUUHeq.png" alt="My cool logo"/>


### Creacion de profile
crear un archivo con el nombre `.bash_profile` en el home

<img width="50%" src="https://i.imgur.com/lSUwtsU.png" alt="My cool logo"/>

```shell
DATE_HOUR="`date +%d`/`date +%m`/`date +%Y` - `date +%H`:`date +%M`:`date +%S`"
# DATE_HOUR_GIT="`date +%d`/`date +%m`/`date +%Y`_`date +%H``date +%M``date +%S`"
DATE_HOUR_GIT="`date +%Y`-`date +%m`-`date +%d`_`date +%H`:`date +%M`:`date +%S`"
# CURRENT_DIR=$(dirname $0)
CMDER_ROOT="/home/mobaxterm"
scriptPath2=${0%/*}
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(exec /usr/bin/hostname)
INFO_PC="${CURRENT_USER}@${CURRENT_PC_NAME}"
	
# :::::::: importamos los  colores
if [ -f "${CMDER_ROOT}/libs/colors.sh" ]; then
 source "${CMDER_ROOT}/libs/colors.sh"
fi
# --------------
# --------- Includes Core ----------------------
source "${CMDER_ROOT}/libs/conf_funciones.sh"
# --------- require  fzf


function reload_config(){
  source "${CMDER_ROOT}/libs/conf_funciones_level_1.sh"
  source "${CMDER_ROOT}/libs/conf_funciones_level_2.sh"
  source "${CMDER_ROOT}/libs/conf_alias_level_1.sh"
  source "${CMDER_ROOT}/libs/conf_funciones_ides.sh"
  source "${CMDER_ROOT}/libs/conf_extras.sh"
  source "${CMDER_ROOT}/libs/conf_menu.sh"
}
#--------cargar funciones
reload_config

slepp_m=0.000000002s

echo "${Green_full}"

CONTADOR=1
while [ $CONTADOR -lt 5 ]
do
#echo "El contador vale ${CONTADOR} y es menor que 10."

echo -n "手 き き 手 大 手 き                  き 大 手 き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 手 き 手 き き 大 手 き 手 き き 手 大 手 き き 手                手 き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 手 き 手 き き 大 手 き 手"
# sleep $slepp_m
echo -n "き 手 き { 手 手 手                  き 手 き ñ き 手 き き 手 大 手 き 手 き ! き き 手 大 手 き 手 手 手 大 手 き 手 き ! き き 手 手 { 手 大 手 き 手 き                ñ き 手 き き 手 大 手 き 手 き ! き き 手 大 手 き 手 き き 手 大 手 き き き 大 手 き O"
# sleep $slepp_m
echo -n "手 き き 手 大 手 き                  き 手 ^ き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 手 き 手 x き 大 手 き 手 き き 手 大 手 き き 手                き 手 き き 手 大 手 き き き 手 き 手 き き 手 大 手 き 手 き 手 き 手 x き 大 手 き 手 き"
# sleep $slepp_m
echo -n "手 き き 手 大 手 き                  き 手 % き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 手 き 手 x き 大 手 き 手 き き 手 大 手 き き 手                % き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 手 き 手 x き 大 手 き 手"
# sleep $slepp_m
echo -n "き 手 き { 手 手 手                  き 手 き ñ き 手 き き 手 大 手 き 手 き ! き き 手 大 手 き 手 き き 手 大 手 き き き 大 手 き 手 き { 手 大 手 き 手                き ñ き 手 き き 手 大 手 き 手 き ! き き 手 手 手 % K [ 4 き 手 き 5 手 ? g A き"
# sleep $slepp_m
echo -n "手 き き 手 大 手 き                  き 手 ^ き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 手 き 手 x き 大 手 き 手 き き 手 大 手 き き 手                ^ き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 手 き 手 x き 大 手 き 手"
# sleep $slepp_m
echo -n "手 き き 手 大 手 き                  き 手 % き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 手 き 手 x き 大 手 き 手 き き 手 大 手 き き 手                % き き 手 き 手 き き 手 き 大 手 き 手 き き 手 大 手 き 手 き 1 き 1 x き 1 1 き 1"


# echo -n "1 き き 1 1 1 き                  き 1 1 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 0 0 1 1 0 1 0 0 1 1 1 0 0 1                1 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 0 0 1 1 0 1"
# sleep $slepp_m
# echo -n "0 1 0 { 1 1 1                  0 1 0 ñ 0 1 0 0 1 1 1 0 1 0 ! 0 0 1 1 1 0 1 1 1 1 1 0 1 0 ! 0 0 1 1 { 1 1 1 0 1 0                ñ 0 1 0 0 1 1 1 0 1 0 ! 0 0 1 1 1 0 1 0 0 1 1 1 0 0 0 1 1 0 O"
# sleep $slepp_m
# echo -n "1 0 0 1 1 1 0                  0 1 ^ 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 x 0 1 1 0 1 0 0 1 1 1 0 0 1                0 1 0 0 1 1 1 0 0 0 1 0 1 0 0 1 1 1 0 1 0 1 0 1 x 0 1 1 0 1 0"
# sleep $slepp_m
# echo -n "1 0 0 1 1 1 0                  0 1 % 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 x 0 1 1 0 1 0 0 1 1 1 0 0 1                % 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 x 0 1 1 0 1"
# sleep $slepp_m
# echo -n "0 1 0 { 1 1 1                  0 1 0 ñ 0 1 0 0 1 1 1 0 1 0 ! 0 0 1 1 1 0 1 0 0 1 1 1 0 0 0 1 1 0 1 0 { 1 1 1 0 1                0 ñ 0 1 0 0 1 1 1 0 1 0 ! 0 0 1 1 1 % K [ 4 0 1 0 5 1 ? g A 0"
# sleep $slepp_m
# echo -n "1 0 0 1 1 1 0                  0 1 ^ 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 x 0 1 1 0 1 0 0 1 1 1 0 0 1                ^ 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 x 0 1 1 0 1"
# sleep $slepp_m
# echo -n "1 0 0 1 1 1 0                  0 1 % 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 x 0 1 1 0 1 0 0 1 1 1 0 0 1                % 0 0 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 x 0 1 1 0 1"



let CONTADOR++
done
echo "${Color_Off}" #pintado normal
clear

echo "${Purple_full}" #pintado morado
echo ""
echo ""
echo "  ██████╗███████╗███████╗ █████╗ ██████╗      █████╗ ██╗   ██╗██████╗ ██╗███████╗"
echo " ██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗    ██╔══██╗██║   ██║██╔══██╗██║██╔════╝"
echo " ██║     █████╗  ███████╗███████║██████╔╝    ███████║██║   ██║██████╔╝██║███████╗"
echo " ██║     ██╔══╝  ╚════██║██╔══██║██╔══██╗    ██╔══██║██║   ██║██╔══██╗██║╚════██║"
echo " ╚██████╗███████╗███████║██║  ██║██║  ██║    ██║  ██║╚██████╔╝██║  ██║██║███████║"
echo "  ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝"
echo "  _______  _______  _______  _______  _______  _______  _______  _______  _______  "
echo " /______/\/______/\/______/\/______/\/______/\/______/\/______/\/______/\/______/\ "
echo " \__::::\/\__::::\/\__::::\/\__::::\/\__::::\/\__::::\/\__::::\/\__::::\/\__::::\/ "
echo "                                                                                   "
echo "${BIRed_full} "
echo "               ███▄ ▄███▓ ▄▄▄        ██████ ▄▄▄█████▓▓█████  ██▀███                 "
echo "              ▓██▒▀█▀ ██▒▒████▄    ▒██    ▒ ▓  ██▒ ▓▒▓█   ▀ ▓██ ▒ ██▒               "
echo "              ▓██    ▓██░▒██  ▀█▄  ░ ▓██▄   ▒ ▓██░ ▒░▒███   ▓██ ░▄█ ▒               "
echo "              ▒██    ▒██ ░██▄▄▄▄██   ▒   ██▒░ ▓██▓ ░ ▒▓█  ▄ ▒██▀▀█▄                 "
echo "              ▒██▒   ░██▒ ▓█   ▓██▒▒██████▒▒  ▒██▒ ░ ░▒████▒░██▓ ▒██▒               "
echo "              ░ ▒░   ░  ░ ▒▒   ▓▒█░▒ ▒▓▒ ▒ ░  ▒ ░░   ░░ ▒░ ░░ ▒▓ ░▒▓░               "
echo "              ░  ░      ░  ▒   ▒▒ ░░ ░▒  ░ ░    ░     ░ ░  ░  ░▒ ░ ▒░               "
echo "              ░      ░     ░   ▒   ░  ░  ░    ░         ░     ░░   ░                "
echo "                     ░         ░  ░      ░              ░  ░   ░                    "
echo "                          "
echo "                          "

echo "${Color_Reset_full}"
#PS1='\[$BLUE\]\u@\h \[$BLUE\]\w/\[$GREEN\] \$\[$WHITE\] '
echo -en "   "
echo -en "${Red}██${BRed}██${IRed}██${BIRed}██"
echo -en "${Green}██${BGreen}██${IGreen}██${BIGreen}██"
echo -en "${Yellow}██${BYellow}██${IYellow}██${BIYellow}██"
echo -en "${Blue}██${BBlue}██${IBlue}██${BIBlue}██"
echo -en "${Purple}██${BPurple}██${IPurple}██${BIPurple}██"
echo -en "${Cyan}██${BCyan}██${ICyan}██${BICyan}██ \n"


#--------------------------------------------------------------------
#---------------------------- Start Menu personalizado-------------
menu
# PS1=$'\[\e]0;$PWD\007\]$(_gp 1)
#\[\e[44m\e[30m\] \[\xEE\]\x83\xA8 \D{%d/%m/%Y} \[\e[42m\e[34m\]\[\xEE\x82\]\xB0\[\e[30m\] \[\xEE\]\x83\xA9 \D{%H:%M.%S} \[\e[0m\e[32m\]$(_gp 2)\[\xEE\x82\]\xB0\[\e[0m\] '
function ps_cesar (){
PS1=$'\[\e]0;$PWD\007\]$(_gp 1)
\[\e[44m\e[30m\] \[\xEE\]\x83\xA8 \D{%d/%m/%Y} \[\e[0m\e[32m\]$(_gp 2)\[\xEE\x82\]\xB0\[\e[0m\] \n
\[\e[42m\e[30m\]\[\xEE\x82\]\xB0\[\e[30m\] \[\xEE\]\x83\xA9 \D{%H:%M.%S} \[\e[0m\e[32m\]\[\xEE\x82\]\xB0\[\e[0m\] '
}
function ps_reset (){
PS1=$'\[\e]0;$PWD\007\]$(_gp 1)
\[\e[44m\e[30m\] \[\xEE\]\x83\xA8 \D{%d/%m/%Y} \[\e[42m\e[34m\]\[\xEE\x82\]\xB0\[\e[30m\] \[\xEE\]\x83\xA9 \D{%H:%M.%S} \[\e[0m\e[32m\]$(_gp 2)\[\xEE\x82\]\xB0\[\e[0m\] '
}
ps_cesar
# ZSH_THEME="robbyrussell"
```
