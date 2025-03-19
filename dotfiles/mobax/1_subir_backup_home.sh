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

# echo "scriptPathDir: $scriptPathDir"
# echo "scriptPathFile: $scriptPathFile"
# echo "scriptPathFileName: $scriptPathFileName"

# ::: entramo al directorio
cd $scriptPathDir
# :: eliminamos el anterio backup
echo " -- -------------------------------------"
echo " 1. Eliminamos el fichero: home.tar.gz"
echo ""
rm -rf home.tar.gz
sleep 2

echo " -- -------------------------------------"
echo " 2. Generamos el fichero: home.tar.gz"
echo ""
sleep 2

# find . -type f -not -path '\./debian/*'

tar -czvf home.tar.gz * \
 --exclude=".ssh" \
 --exclude=".bash_history" \
 --exclude="*.tar.gz" \
 --exclude="*.ssh"

echo " -- -------------------------------------"
echo " 2.1 Validamos existencia de Repositorio"
echo ""
sleep 2
# ------------- start :: validamos el repositorio para  subir nuestros cambios
DIR_REPO='/d/repos/utils_dev/dotfiles/mobax'
SHELL_MOBAX=0
if [ -n "$PUTTYHOME" ]; then
  SHELL_MOBAX=1
  DIR_REPO='/drives/d/repos/utils_dev/dotfiles/mobax'
else
  SHELL_MOBAX=0
fi

if [ -f "${DIR_REPO}" ]; then
  echo -en "No se encontro repositorio: [${BRed}${DIR_REPO}${Color_Off}] \n"
  exit
fi

# ------------- end :: validamos el repositorio para  subir nuestros cambios

echo " -- -------------------------------------"
echo " 3. Movemos el fichero: home.tar.gz, al repositorio utils_dev ubicado en: ${DIR_REPO}"
echo ""
cp home.tar.gz $DIR_REPO/home.tar.gz
cp 1_subir_backup_home.sh $DIR_REPO/1_subir_backup_home.sh
cp 2_descarga_home.sh $DIR_REPO/2_descarga_home.sh


echo " -- -------------------------------------"
echo " 4. Actualizamos el repositorio: ${DIR_REPO}"
echo ""
cd $DIR_REPO

# --------------------- gitUp
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo -en "Actualizando rama actual: [${BGreen}${CURRENT_BRANCH}${Color_Off}] \n" && sleep 3
echo ""
git pull origin $CURRENT_BRANCH
git add -A
git commit -m "${MY_INFO} se actualizo rama ${CURRENT_BRANCH} :${DATE_HOUR_GIT}"
git push origin $CURRENT_BRANCH
