DATE_HOUR_GIT="`date +%Y`-`date +%m`-`date +%d`_`date +%H`:`date +%M`:`date +%S`"
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(exec /usr/bin/hostname)
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"

PATH_SCRIPT=`readlink -f "${BASH_SOURCE:-$0}"`
CURRENT_DIR=`dirname $PATH_SCRIPT`

scriptPathDir=$(dirname $0)
scriptPathFile=$(realpath $0)
scriptPathFileTemp=$(echo "$scriptPathFile" | sed 's/.sh/.tmp/g')
scriptPathFileName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
# cargamos los colores
if [ -f "${CURRENT_DIR}/libs_shell/mobax/colors.sh" ]; then
  source "${CURRENT_DIR}/libs_shell/mobax/colors.sh"
fi

# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------
# -------------------- Abrirlo con Mobax para qeu funcione tar --------------------
# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------

# ::: entramo al directorio
cd $scriptPathDir
echo " --------------------------------------------"
echo -en " --- ${BGreen}Descargar backup del repo DEV${Color_Off}]  ---------- \n"
echo " --------------------------------------------"
sleep 2

# :: eliminamos el anterio backup
printf " %s" "- Eliminamos el anterio backup" && sleep 3
rm -rf home.tar.gz
printf " ✓\n"

# :: descargamos
printf " %s" "- Descargando... home.tar.gz" && sleep 3
curl -A 'Mozilla/3.0 (Win95; I)'  \
	-L -o "./home.tar.gz" "https://gitlab.com/perucaos/utils_dev/-/raw/master/dotfiles/mobax/home.tar.gz" >/dev/null 2>&1
printf " ✓\n"

# :: descomprimimos
printf " %s" "- Descomprimiendo" && sleep 3
tar -xzvf home.tar.gz >/dev/null 2>&1
printf " ✓\n"


echo "OK"
sleep 5
