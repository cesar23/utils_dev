DATE_HOUR_GIT="`date +%Y`-`date +%m`-`date +%d`_`date +%H`:`date +%M`:`date +%S`"
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(exec /usr/bin/hostname)
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"



scriptPathDir=$(dirname $0)
scriptPathFile=$(realpath $0)
scriptPathFileName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
# echo "scriptPathDir: $scriptPathDir"
# echo "scriptPathFile: $scriptPathFile"
# echo "scriptPathFileName: $scriptPathFileName"

# ::: entramo al directorio
cd $scriptPathDir
# :: eliminamos el anterio backup
echo " -- -------------------------------------"
echo " 1. Eliminamos el fichero: home.tar.gz"
rm -rf home.tar.gz
sleep 2

echo " -- -------------------------------------"
echo " 2. Generamos el fichero: home.tar.gz"
sleep 2

tar -czvf home.tar.gz * \
 --exclude=".ssh" \
 --exclude=".bash_history" \
 --exclude="*.tar.gz" \
 --exclude="*.ssh"


DIR_REPO='/d/repos/utils_dev/dotfiles/mobax'
SHELL_MOBAX=0
if [ -n "$PUTTYHOME" ]; then
  SHELL_MOBAX=1
  DIR_REPO='/drives/d/repos/utils_dev/dotfiles/mobax'
else
  SHELL_MOBAX=0
fi


echo " -- -------------------------------------"
echo " 3. Movemos el fichero: home.tar.gz, al repositorio utils_dev ubicado en: ${DIR_REPO}"
cp home.tar.gz $DIR_REPO/home.tar.gz
cp backup_home.sh $DIR_REPO/backup_home.sh
cp descarga_home.sh $DIR_REPO/descarga_home.sh


echo " -- -------------------------------------"
echo " 4. Actualizamos el repositorio: ${DIR_REPO}"
cd $DIR_REPO
git add . && git commit  -m "${MY_INFO} se actualizo :${DATE_HOUR_GIT}" && git push origin master

sleep 6


