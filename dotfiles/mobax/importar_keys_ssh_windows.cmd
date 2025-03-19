
REM ejcutar como admin

REM :::::: eliminamos si hay ficheros
del  %USERPROFILE%\mobax\home\.ssh\id_rsa
del  %USERPROFILE%\mobax\home\.ssh\id_rsa.pub
del  %USERPROFILE%\mobax\home\.ssh\known_hosts

REM :::::: reaizamos el enlaze simbolico
REM mklink ruta  desdedonde 
mklink  %USERPROFILE%\mobax\home\.ssh\id_rsa  %USERPROFILE%\.ssh\id_rsa
mklink  %USERPROFILE%\mobax\home\.ssh\id_rsa.pub  %USERPROFILE%\.ssh\id_rsa.pub
mklink  %USERPROFILE%\mobax\home\.ssh\known_hosts  %USERPROFILE%\.ssh\known_hosts


~/.ssh/known_hosts  ~/mobax/home/.ssh/known_hosts
