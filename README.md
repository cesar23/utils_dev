
# repositorio curso_linux

### descargar por primera vez el repositorio

```shell
git config --local user.name "Cesar HL"
git config --local user.email "perucaos@gmail.com"
```

```shell

# 1. clonamos el repositorio de gitlab
git clone git@gitlab.com:perucaos/utils_dev.git
cd utils_dev 

git switch --create master
# 2. agregamos el repositorio de github
git remote add origin git@gitlab.com:perucaos/utils_dev.git
git remote add origin2 git@github.com:cesar23/utils_dev.git
# 3. descargar si ahy algun cambio
git pull origin master
```

### para actualizar repos con los cambios correr

```shell
./gitup.sh
```