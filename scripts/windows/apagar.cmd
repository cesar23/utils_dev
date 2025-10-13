@ECHO OFF
:: Script de Apagado Programado de Windows
:: Desarrollado por César Auris
:: Página web: www.solucionessystem.com
::-------------------------------------------------

:: IMPORTANTE: Cambia la codificación a UTF-8 para mostrar acentos y la 'ñ' correctamente.
CHCP 65001 >NUL

:: Establecer el color de fondo y el texto.
:: 0B = Fondo Negro (0), Texto Azul Claro/Aqua (B)
COLOR 0B

TITLE Apagado Programado del Sistema

ECHO =========================================================
ECHO.
ECHO              [!!!] APAGADO PROGRAMADO DE WINDOWS [!!!]
ECHO.
ECHO =========================================================
ECHO.
ECHO  [ OK ] Script realizado por: César Auris
ECHO  (WEB) Web: www.solucionessystem.com
ECHO.
ECHO ---------------------------------------------------------
ECHO.

:: Definir el tiempo de espera antes del apagado (en segundos)
SET TIEMPO=60


ECHO.
ECHO  [AVISO] El sistema se apagará en %TIEMPO% segundos...
ECHO  (Guarde su trabajo AHORA)
ECHO.

:: Ejecutar el comando shutdown
shutdown /s /t %TIEMPO% /f /c "¡Apagado en %TIEMPO% segundos! Script desarrollado por César Auris."

ECHO.
ECHO  Presione cualquier tecla para salir del script...
PAUSE >NUL

:: Restaura el color de la consola a la configuración predeterminada al salir
COLOR 07 

EXIT