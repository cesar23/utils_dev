scriptPathDir=$(dirname $0)
scriptPathFile=$(realpath $0)
scriptPathFileName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
# echo "scriptPathDir: $scriptPathDir"
# echo "scriptPathFile: $scriptPathFile"
# echo "scriptPathFileName: $scriptPathFileName"

# ::: entramo al directorio
cd $scriptPathDir
# :: eliminamos el anterio backup
rm -rf home.tar.gz



tar -czvf home.tar.gz * \
 --exclude=".ssh" \
 --exclude=".bash_history" \
 --exclude="*.tar.gz" \
 --exclude="*.ssh"
