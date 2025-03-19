@echo off
::  ------------- Ver variables locales globales de entorno
set path_file=%1
rem :::::::: recoger todos los parametros
set path_file2=%*

echo  ::::::::::::::::::::::::::::::::::::::::::::::::::
echo  :::::::::::::: Propiedades Script ::::::::::::::::
echo  ::::::::::::::::::::::::::::::::::::::::::::::::::
echo.
echo         Current file: %~nx0
echo   Carpeta del script: %~dp0
echo      Path del script: %~dpnx0
echo.
echo  ::::::::::::::::::::::::::::::::::::::::::::::::::
echo  :::::::::::::: Propiedades Script ::::::::::::::::
echo  ::::::::::::::::::::::::::::::::::::::::::::::::::
echo.
echo  - parametro donde recibimos el fichero: %1
echo  - todos los parametros: %*
pause