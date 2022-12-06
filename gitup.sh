#!/usr/bin/env bash
DATE_HOUR_GIT="`date +%Y`-`date +%m`-`date +%d`_`date +%H`:`date +%M`:`date +%S`"
CURRENT_USER=$(id -un)
CURRENT_PC_NAME=$(exec /usr/bin/hostname)
MY_INFO="${CURRENT_USER}@${CURRENT_PC_NAME}"
scriptPathDir=$(dirname $0)
scriptPathFile=$(realpath $0)
scriptPathFileName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

function upgit() {
	git pull
    git add -A
    git commit -m "${MY_INFO} se actualizo :${DATE_HOUR_GIT}"
    git push -u origin master
}

function gitup() {
    # git pull
    git pull origin master
	git add -A
    git commit -m "${MY_INFO} se actualizo :${DATE_HOUR_GIT}"
    #git push origin master && git push origin2 master # por que  github no acepta  archivos  pesados
    git push origin master
}

function gitup2() {
    git pull
	  git add -A
    git commit -m "${MY_INFO} se actualizo :${DATE_HOUR_GIT}"
    git push
}
clear
cd $scriptPathDir
pwd
gitup

echo ""
echo "  ██████  ██   ██                ██████ ███████ ███████  █████  ██████  "
echo " ██    ██ ██  ██                ██      ██      ██      ██   ██ ██   ██ "
echo " ██    ██ █████       █████     ██      █████   ███████ ███████ ██████  "
echo " ██    ██ ██  ██                ██      ██           ██ ██   ██ ██   ██ "
echo "  ██████  ██   ██                ██████ ███████ ███████ ██   ██ ██   ██ "
echo ""
echo ""
sleep 4
