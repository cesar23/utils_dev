#!/usr/bin/env bash
export LC_ALL="es_ES.UTF-8"
DATE_HOUR_GIT="`date +%Y`-`date +%m`-`date +%d`_`date +%H`:`date +%M`:`date +%S`"
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(exec /usr/bin/hostname)
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"
PATH_SCRIPT=`readlink -f "${BASH_SOURCE:-$0}"`
CURRENT_DIR=`dirname $PATH_SCRIPT`
NAME_DIR=$(basename $CURRENT_DIR) # nombre del Directorio actual

scriptPathDir=$(dirname $0)
scriptPathFile=$(realpath $0)
scriptPathFileName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")" # gitup.sh
scriptPathFileTemp=$(echo "$scriptPathFileName" | sed 's/.sh/.tmp/g') #  ${scriptPathDir}/gitup.tmp
scriptPathFileTemp_system=$(echo "${TMP}/${scriptPathFileName}" | sed 's/.sh/.tmp/g') # /tmp/gitup.tmp



cd $CURRENT_DIR
echo "############################################################"
echo "####### Copiando ficheros de configuracion espanso #########"
echo "############################################################"
echo ""

# Solo en mi pc por que la carpeta home es diferente del nmombre de usuario
USERNAME='cesarPc'

DIR_OUTPUT="/c/Users/$USERNAME/AppData/Roaming/espanso"
mkdir -p $DIR_OUTPUT  # Crea la carpeta destino si no existe

if [ -d $DIR_OUTPUT ]; then
    echo "Limpiando .... ${DIR_OUTPUT}"
    rm -rf "${DIR_OUTPUT}/*"
    echo "Copiando ....  ${DIR_OUTPUT}"
    cp -r * $DIR_OUTPUT  # Copia el contenido
else
    echo "El directorio no existe :${DIR_OUTPUT}"
fi

# :::: corremos el ejecutable
ESPANSO_PATH="/c/Users/$USERNAME/AppData/Local/Programs/Espanso"
ESPANSO_EXE='espansod.exe'
cd $ESPANSO_PATH && start $ESPANSO_EXE

