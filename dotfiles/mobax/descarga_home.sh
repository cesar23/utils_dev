scriptPathDir=$(dirname $0)
scriptPathFile=$(realpath $0)
scriptPathFileName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
# echo "scriptPathDir: $scriptPathDir"
# echo "scriptPathFile: $scriptPathFile"
# echo "scriptPathFileName: $scriptPathFileName"

# ::: entramo al directorio
cd $scriptPathDir
echo " --------------------------------------------"
echo " --- Descargar backup del repo DEV ----------"
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
