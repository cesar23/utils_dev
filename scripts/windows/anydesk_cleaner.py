#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import getpass
import socket
import subprocess
import winreg
import ctypes
import shutil
import time
import traceback
from datetime import datetime, timezone, timedelta
from pathlib import Path


# =============================================================================
# 🛠️ Activar soporte ANSI en Windows (para colores al hacer doble clic)
# =============================================================================
def enable_ansi_support():
    """Activa los códigos ANSI en la consola de Windows."""
    if os.name != 'nt':
        return True  # Solo necesario en Windows

    try:
        # Habilitar modo virtual en la consola actual
        kernel32 = ctypes.windll.kernel32
        stdout_handle = kernel32.GetStdHandle(-11)  # STD_OUTPUT_HANDLE
        mode = ctypes.c_ulong()
        kernel32.GetConsoleMode(stdout_handle, ctypes.byref(mode))
        kernel32.SetConsoleMode(stdout_handle,
                                mode.value | 4)  # ENABLE_VIRTUAL_TERMINAL_PROCESSING
        return True
    except Exception:
        return False


# =============================================================================
# 🎨 Configuración de Ventana (Tamaño, Título, Centrado)
# =============================================================================
def setup_console_window():
    """Configura el título, tamaño y posición de la ventana de consola."""
    try:
        # Establecer título de la ventana
        os.system('title AnyDesk Cleaner Pro - Limpieza Total del Sistema')

        # Establecer tamaño de la ventana (columnas x líneas)
        os.system('mode con: cols=110 lines=35')

        # Centrar la ventana en la pantalla
        if os.name == 'nt':
            try:
                user32 = ctypes.windll.user32
                kernel32 = ctypes.windll.kernel32

                # Obtener handle de la ventana de consola
                hwnd = kernel32.GetConsoleWindow()

                if hwnd:
                    # Obtener dimensiones de la pantalla
                    screen_width = user32.GetSystemMetrics(0)
                    screen_height = user32.GetSystemMetrics(1)

                    # Dimensiones de la ventana (aproximadas)
                    window_width = 850
                    window_height = 650

                    # Calcular posición centrada
                    x = (screen_width - window_width) // 2
                    y = (screen_height - window_height) // 2

                    # Mover y redimensionar la ventana
                    user32.MoveWindow(hwnd, x, y, window_width, window_height,
                                      True)
            except Exception:
                pass  # Si falla el centrado, continuar sin problema

    except Exception:
        pass  # Si falla la configuración, continuar


# Detectar si se está ejecutando con doble clic (sin terminal interactiva)
RUNNING_FROM_DOUBLE_CLICK = not sys.stdout.isatty()

# Siempre activar ANSI en Windows (mejora compatibilidad)
ANSI_SUPPORTED = enable_ansi_support()

# Configurar ventana al inicio
setup_console_window()

# Si no se pudo activar ANSI, desactivar colores
if not ANSI_SUPPORTED:
    class Colors:
        RED = '';
        GREEN = '';
        YELLOW = '';
        BLUE = '';
        PURPLE = ''
        CYAN = '';
        GRAY = '';
        BRED = '';
        BGREEN = '';
        BYELLOW = ''
        BBLUE = '';
        BPURPLE = '';
        BCYAN = '';
        BGRAY = '';
        RESET = ''
else:
    class Colors:
        RED = '\033[0;31m'
        GREEN = '\033[0;32m'
        YELLOW = '\033[0;33m'
        BLUE = '\033[0;34m'
        PURPLE = '\033[0;35m'
        CYAN = '\033[0;36m'
        GRAY = '\033[0;90m'
        BRED = '\033[1;31m'
        BGREEN = '\033[1;32m'
        BYELLOW = '\033[1;33m'
        BBLUE = '\033[1;34m'
        BPURPLE = '\033[1;35m'
        BCYAN = '\033[1;36m'
        BGRAY = '\033[1;90m'
        RESET = '\033[0m'


# =============================================================================
# 🛑 Al final del script, pausar si se ejecutó con doble clic
# =============================================================================
def pause_on_exit():
    """Pausa al final si se ejecutó con doble clic."""
    if RUNNING_FROM_DOUBLE_CLICK:
        try:
            input(
                f"\n{Colors.BGRAY}✅ Script finalizado. Presiona ENTER para cerrar.{Colors.RESET}")
        except:
            pass  # Ignorar errores en input


# =============================================================================
# 🎨 Banner y Presentación Visual
# =============================================================================
def show_banner():
    """Muestra un banner artístico al inicio del programa."""
    os.system('cls' if os.name == 'nt' else 'clear')

    banner = f"""
{Colors.BRED}
        ╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗
        ║                                                                                                   ║
        ║             █████╗ ███╗   ██╗██╗   ██╗██████╗ ███████╗███████╗██╗  ██╗                            ║
        ║            ██╔══██╗████╗  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝██║ ██╔╝                            ║
        ║            ███████║██╔██╗ ██║ ╚████╔╝ ██║  ██║█████╗  ███████╗█████╔╝                             ║
        ║            ██╔══██║██║╚██╗██║  ╚██╔╝  ██║  ██║██╔══╝  ╚════██║██╔═██╗                             ║
        ║            ██║  ██║██║ ╚████║   ██║   ██████╔╝███████╗███████║██║  ██╗                            ║
        ║            ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝                            ║
        ║                                                                                                   ║
        ║                       ██████╗██╗     ███████╗ █████╗ ███╗   ██╗███████╗██████╗                    ║
        ║                      ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██╔════╝██╔══██╗                   ║
        ║                      ██║     ██║     █████╗  ███████║██╔██╗ ██║█████╗  ██████╔╝                   ║
        ║                      ██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║██╔══╝  ██╔══██╗                   ║
        ║                      ╚██████╗███████╗███████╗██║  ██║██║ ╚████║███████╗██║  ██║                   ║
        ║                       ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝                   ║
        ║                                                                                                   ║
        ║                                    {Colors.BGREEN}🔥 PRO VERSION 2.0 🔥{Colors.BRED}                                          ║
        ║                                                                                                   ║
        ║                               {Colors.BCYAN}Eliminación Completa y Total de AnyDesk{Colors.BRED}                             ║
        ║                               {Colors.BYELLOW}Desarrollado por:{Colors.BCYAN} Cesar Auris{Colors.BRED}                                       ║
        ║                               {Colors.BYELLOW}Website: www.solucionessystem.com{Colors.BRED}                                   ║
        ║                                                                                                   ║
        ╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝
{Colors.RESET}
"""
    print(banner)
    time.sleep(1.2)


def print_separator(char="═", length=103, color=Colors.BCYAN):
    """Imprime un separador decorativo."""
    print(f"{color}{char * length}{Colors.RESET}")


def print_step_header(step_num, description):
    """Imprime el encabezado de cada paso con estilo."""
    print(f"\n{Colors.BGREEN}╔{'═' * 101}╗{Colors.RESET}")
    print(
        f"{Colors.BGREEN}║{Colors.RESET} {Colors.BYELLOW}PASO {step_num}{Colors.RESET}: {Colors.BCYAN}{description}{' ' * (92 - len(description) - len(str(step_num)))}{Colors.BGREEN}║{Colors.RESET}")
    print(f"{Colors.BGREEN}╚{'═' * 101}╝{Colors.RESET}")


# =============================================================================
# 🏆 SECTION: Configuración Inicial
# =============================================================================

PERU_TZ = timezone(timedelta(hours=-5))


def now_pe():
    return datetime.now(PERU_TZ)


DATE_HOUR_PE = now_pe().strftime("%Y-%m-%d_%H:%M:%S")
CURRENT_USER = getpass.getuser()
CURRENT_PC_NAME = socket.gethostname()
MY_INFO = f"{CURRENT_USER}@{CURRENT_PC_NAME}"

SCRIPT_PATH = Path(__file__).resolve()
SCRIPT_NAME = SCRIPT_PATH.name
CURRENT_DIR = SCRIPT_PATH.parent


# =============================================================================
# ⚙️ SECTION: Core Functions
# =============================================================================

def detect_system() -> str:
    if os.path.exists("/data/data/com.termux/files/usr/bin/pkg"):
        return "termux"
    try:
        with open("/proc/version", "r") as f:
            if "microsoft" in f.read().lower():
                return "wsl"
    except (FileNotFoundError, PermissionError):
        pass
    if os.getenv("MSYSTEM"):
        return "gitbash"
    if os.path.exists("/etc/os-release"):
        try:
            with open("/etc/os-release", "r", encoding="utf-8") as f:
                for line in f:
                    if line.startswith("ID="):
                        distro_id = line.split("=", 1)[1].strip().strip(
                            '"').lower()
                        if distro_id in ("ubuntu", "debian"):
                            return "ubuntu"
                        elif distro_id in (
                            "rhel", "centos", "fedora", "rocky", "almalinux"):
                            return "redhat"
                        break
        except Exception:
            pass
    return "unknown"


SO_SYSTEM = detect_system()


def msg(message: str, level: str = "INFO") -> None:
    """Mostrar mensaje con color y timestamp"""
    try:
        timestamp = now_pe().strftime("%Y-%m-%d %H:%M:%S")
        show_detail = SO_SYSTEM != "termux"

        color_map = {
            "INFO": Colors.BBLUE,
            "WARNING": Colors.BYELLOW,
            "ERROR": Colors.BRED,
            "DEBUG": Colors.BPURPLE,
            "SUCCESS": Colors.BGREEN,
        }

        prefix = f"{timestamp} - [{level}]" if show_detail else f"[{level}]"
        color = color_map.get(level, Colors.BGRAY)

        if level == "SUCCESS":
            print(f"{Colors.BGREEN}{prefix}{Colors.RESET} {message}")
        else:
            print(f"{color}{prefix}{Colors.RESET} {message}")
    except Exception as e:
        # Si falla el mensaje formateado, mostrar mensaje simple
        print(f"[{level}] {message}")
        print(f"[DEBUG] Error en función msg: {e}")


def pause_continue(message: str = "") -> None:
    """Pausar para que el usuario pueda ver los resultados"""
    if SO_SYSTEM == "termux":
        return  # No pausar en Termux
    if message:
        prompt = f"📹 {message}. Presiona [ENTER] para continuar..."
    else:
        prompt = "✅ Operación completada. Presiona [ENTER] para continuar..."
    try:
        input(f"{Colors.GRAY}{prompt}{Colors.RESET}")
    except KeyboardInterrupt:
        print(
            f"\n{Colors.BRED}Ejecución interrumpida por el usuario.{Colors.RESET}")
        pause_on_exit()
        sys.exit(1)
    except Exception as e:
        msg(f"Error en pause_continue: {e}", "DEBUG")


def is_admin():
    """Verificar si el script se ejecuta como administrador"""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception as e:
        msg(f"Error al verificar permisos de administrador: {e}", "ERROR")
        return False


def run_as_admin():
    """Reiniciar el script con permisos de administrador"""
    try:
        if not is_admin():
            msg("⚠️ Reiniciando con permisos de administrador...", "WARNING")
            ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable,
                                                " ".join(sys.argv), None, 1)
            sys.exit(0)
    except Exception as e:
        msg(f"Error al intentar obtener permisos de administrador: {e}",
            "ERROR")
        msg("Por favor, ejecuta el script manualmente como administrador",
            "WARNING")
        pause_on_exit()
        sys.exit(1)


def delete_registry_tree(hkey, subkey):
    """Eliminar clave de registro recursivamente con manejo de errores mejorado"""
    try:
        with winreg.OpenKey(hkey, subkey, 0,
                            winreg.KEY_READ | winreg.KEY_WOW64_64KEY) as key:
            i = 0
            while True:
                try:
                    subkey_name = winreg.EnumKey(key, i)
                    delete_registry_tree(hkey, f"{subkey}\\{subkey_name}")
                    i += 1
                except OSError:
                    break
        parent_path = "\\".join(subkey.split("\\")[:-1]) or ""
        key_name = subkey.split("\\")[-1]
        with winreg.OpenKey(hkey, parent_path, 0,
                            winreg.KEY_WRITE | winreg.KEY_WOW64_64KEY) as parent:
            winreg.DeleteKey(parent, key_name)
        msg(f"Clave del registro eliminada: {subkey}", "SUCCESS")
        return True
    except FileNotFoundError:
        msg(f"Clave no encontrada (ya eliminada): {subkey}", "DEBUG")
        return False
    except PermissionError:
        msg(f"Sin permisos para eliminar: {subkey}", "WARNING")
        return False
    except Exception as e:
        msg(f"Error al eliminar registro {subkey}: {e}", "ERROR")
        msg(f"Tipo de error: {type(e).__name__}", "DEBUG")
        return False


def safe_remove_path(path):
    """Eliminar archivo o carpeta con múltiples métodos y manejo de errores"""
    if not os.path.exists(path):
        msg(f"No existe (ya eliminado): {path}", "DEBUG")
        return True

    msg(f"Intentando eliminar: {path}", "INFO")

    try:
        if os.path.isfile(path):
            os.remove(path)
        else:
            shutil.rmtree(path)
        msg(f"Eliminado: {path}", "SUCCESS")
        return True
    except Exception as e1:
        msg(f"Método 1 (Python) falló: {type(e1).__name__} - {e1}", "DEBUG")
        try:
            cmd = f'rmdir /s /q "{path}"' if os.path.isdir(
                path) else f'del /f /q "{path}"'
            result = subprocess.run(cmd, shell=True, capture_output=True,
                                    text=True, timeout=30)
            if result.returncode != 0:
                msg(f"Salida del comando: {result.stderr}", "DEBUG")
            if not os.path.exists(path):
                msg(f"Eliminado (cmd): {path}", "SUCCESS")
                return True
            else:
                msg(f"CMD no pudo eliminar: {path}", "WARNING")
                return False
        except Exception as e2:
            msg(f"Método 2 (CMD) falló: {type(e2).__name__} - {e2}", "ERROR")
            return False


def kill_process(proc_name):
    """Finalizar proceso con manejo de errores mejorado"""
    try:
        result = subprocess.run(["taskkill", "/F", "/IM", proc_name],
                                capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            msg(f"Proceso finalizado: {proc_name}", "SUCCESS")
            return True
        else:
            msg(f"Proceso no encontrado o ya finalizado: {proc_name}", "DEBUG")
            return False
    except subprocess.TimeoutExpired:
        msg(f"Timeout al intentar finalizar: {proc_name}", "WARNING")
        return False
    except Exception as e:
        msg(f"Error al finalizar proceso {proc_name}: {type(e).__name__} - {e}",
            "ERROR")
        return False


# =============================================================================
# 🔥 SECTION: Main Code con manejo de errores mejorado
# =============================================================================

def main():
    """Función principal con manejo de errores robusto"""

    # Mostrar banner inicial
    show_banner()

    # Verificar permisos de administrador
    try:
        run_as_admin()
    except Exception as e:
        msg(f"Error en verificación de admin: {e}", "ERROR")
        msg("Continuando de todas formas...", "WARNING")


    # =========================================================================
    # Paso 1: Finalizar procesos
    # =========================================================================
    try:
        print_step_header(1, "FINALIZANDO PROCESOS DE ANYDESK")
        msg("🔄 Buscando procesos activos de AnyDesk...", "INFO")
        processes = ["AnyDesk.exe", "AnyDeskService.exe", "AnyDeskAgent.exe"]
        for proc in processes:
            try:
                kill_process(proc)
            except Exception as e:
                msg(f"Error al finalizar {proc}: {e}", "ERROR")
        pause_continue("Paso 1 completado: procesos finalizados")
    except Exception as e:
        msg(f"❌ ERROR EN PASO 1: {e}", "ERROR")
        msg(f"Traceback: {traceback.format_exc()}", "DEBUG")
        msg("Continuando con el siguiente paso...", "WARNING")

    # =========================================================================
    # Paso 2: Desinstalación silenciosa
    # =========================================================================
    try:
        print_step_header(2, "DESINSTALANDO ANYDESK")
        msg("🗑️  Buscando instalación de AnyDesk...", "INFO")
        candidates = [
            r"C:\Program Files\AnyDesk\AnyDesk.exe",
            r"C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
        ]
        anydesk_found = False
        for exe in candidates:
            if os.path.exists(exe):
                anydesk_found = True
                try:
                    subprocess.run([exe, "--silent", "--remove"], timeout=60,
                                   check=True)
                    msg("AnyDesk desinstalado silenciosamente.", "SUCCESS")
                    break
                except subprocess.TimeoutExpired:
                    msg("Timeout en desinstalación silenciosa", "WARNING")
                except Exception as e:
                    msg(f"Error en desinstalación: {type(e).__name__} - {e}",
                        "WARNING")
        if not anydesk_found:
            msg("AnyDesk no encontrado en rutas estándar.", "DEBUG")
        pause_continue("Paso 2 completado: intento de desinstalación")
    except Exception as e:
        msg(f"❌ ERROR EN PASO 2: {e}", "ERROR")
        msg(f"Traceback: {traceback.format_exc()}", "DEBUG")
        msg("Continuando con el siguiente paso...", "WARNING")

    # =========================================================================
    # Paso 3: Eliminar archivos residuales
    # =========================================================================
    try:
        print_step_header(3, "ELIMINANDO ARCHIVOS Y CARPETAS RESIDUALES")
        msg("🧹 Escaneando y eliminando archivos de AnyDesk...", "INFO")
        paths = [
            r"C:\Program Files\AnyDesk",
            r"C:\Program Files (x86)\AnyDesk",
            os.path.join(os.environ.get("ProgramData", ""), "AnyDesk"),
            os.path.join(os.environ.get("APPDATA", ""), "AnyDesk"),
            os.path.join(os.environ.get("LOCALAPPDATA", ""), "AnyDesk"),
            os.path.join(os.environ.get("TEMP", ""), "AnyDesk"),
            r"C:\Windows\Temp\AnyDesk"
        ]
        for path in paths:
            try:
                safe_remove_path(path)
            except Exception as e:
                msg(f"Error al eliminar {path}: {type(e).__name__} - {e}",
                    "ERROR")
        pause_continue("Paso 3 completado: limpieza de archivos")
    except Exception as e:
        msg(f"❌ ERROR EN PASO 3: {e}", "ERROR")
        msg(f"Traceback: {traceback.format_exc()}", "DEBUG")
        msg("Continuando con el siguiente paso...", "WARNING")

    # =========================================================================
    # Paso 4: Limpiar registro
    # =========================================================================
    try:
        print_step_header(4, "LIMPIANDO ENTRADAS DEL REGISTRO DE WINDOWS")
        msg("🔧 Escaneando el registro en busca de claves de AnyDesk...", "INFO")
        reg_paths = [
            (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\AnyDesk"),
            (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\AnyDesk"),
            (winreg.HKEY_CURRENT_USER, r"SOFTWARE\AnyDesk")
        ]
        for hive, path in reg_paths:
            try:
                delete_registry_tree(hive, path)
            except Exception as e:
                msg(f"Error al eliminar clave {path}: {type(e).__name__} - {e}",
                    "ERROR")
        pause_continue("Paso 4 completado: limpieza del registro")
    except Exception as e:
        msg(f"❌ ERROR EN PASO 4: {e}", "ERROR")
        msg(f"Traceback: {traceback.format_exc()}", "DEBUG")
        msg("Continuando con el siguiente paso...", "WARNING")

    # =========================================================================
    # Paso 5: Verificación final
    # =========================================================================
    try:
        print_step_header(5, "VERIFICACIÓN FINAL DE LIMPIEZA")
        msg("🔍 Escaneando sistema en busca de elementos residuales...", "INFO")

        remaining = []

        # Verificar carpetas
        try:
            for path in paths:
                try:
                    if os.path.exists(path):
                        msg(f"⚠️ AÚN EXISTE: {path}", "WARNING")
                        remaining.append(path)
                except Exception as e:
                    msg(f"Error al verificar {path}: {e}", "ERROR")
        except Exception as e:
            msg(f"Error al verificar carpetas: {e}", "ERROR")
            msg(f"Traceback: {traceback.format_exc()}", "DEBUG")

        # Verificar procesos
        try:
            for proc in ["AnyDesk.exe"]:
                try:
                    result = subprocess.run(
                        ["tasklist", "/FI", f"IMAGENAME eq {proc}"],
                        capture_output=True, text=True, timeout=10)
                    if proc.lower() in result.stdout.lower():
                        msg(f"⚠️ PROCESO AÚN ACTIVO: {proc}", "WARNING")
                        remaining.append(proc)
                except subprocess.TimeoutExpired:
                    msg(f"Timeout al verificar proceso {proc}", "WARNING")
                except Exception as e:
                    msg(f"Error al verificar proceso {proc}: {e}", "ERROR")
        except Exception as e:
            msg(f"Error al verificar procesos: {e}", "ERROR")
            msg(f"Traceback: {traceback.format_exc()}", "DEBUG")

        # Mostrar resultado final
        try:
            print(f"\n{Colors.BGREEN}╔{'═' * 101}╗{Colors.RESET}")
            print(
                f"{Colors.BGREEN}║{' ' * 40}{Colors.BYELLOW}RESULTADO FINAL{' ' * 46}{Colors.BGREEN}║{Colors.RESET}")
            print(f"{Colors.BGREEN}╚{'═' * 101}╝{Colors.RESET}\n")

            if not remaining:
                print(f"{Colors.BGREEN}╔{'═' * 101}╗{Colors.RESET}")
                print(f"{Colors.BGREEN}║{' ' * 101}║{Colors.RESET}")
                print(
                    f"{Colors.BGREEN}║{' ' * 25}{Colors.BGREEN}✅✅✅ LIMPIEZA COMPLETADA EXITOSAMENTE ✅✅✅{' ' * 26}{Colors.BGREEN}║{Colors.RESET}")
                print(f"{Colors.BGREEN}║{' ' * 101}║{Colors.RESET}")
                print(f"{Colors.BGREEN}╚{'═' * 101}╝{Colors.RESET}")
                msg("\n🎉 ¡Todos los archivos y registros de AnyDesk han sido eliminados!",
                    "SUCCESS")
            else:
                print(f"{Colors.BYELLOW}╔{'═' * 101}╗{Colors.RESET}")
                print(
                    f"{Colors.BYELLOW}║{' ' * 20}{Colors.BRED}⚠️  ALGUNOS ELEMENTOS NO SE PUDIERON ELIMINAR  ⚠️{' ' * 22}{Colors.BYELLOW}║{Colors.RESET}")
                print(f"{Colors.BYELLOW}╚{'═' * 101}╝{Colors.RESET}\n")

                msg("📋 Elementos restantes:", "WARNING")
                for item in remaining:
                    print(f"   {Colors.BRED}•{Colors.RESET} {item}")

                print(f"\n{Colors.BCYAN}╔{'═' * 101}╗{Colors.RESET}")
                print(
                    f"{Colors.BCYAN}║{' ' * 40}{Colors.BYELLOW}💡 SOLUCIONES{' ' * 43}{Colors.BCYAN}║{Colors.RESET}")
                print(f"{Colors.BCYAN}╚{'═' * 101}╝{Colors.RESET}\n")
                msg("   1️⃣  Reinicia tu PC en Modo Seguro y ejecuta el script de nuevo",
                    "INFO")
                msg("   2️⃣  Usa Revo Uninstaller o IObit Uninstaller", "INFO")
                msg("   3️⃣  Elimina manualmente las carpetas restantes después de reiniciar",
                    "INFO")
        except Exception as e:
            msg(f"Error al mostrar resultado final: {e}", "ERROR")

        print(f"\n{Colors.BPURPLE}╔{'═' * 101}╗{Colors.RESET}")
        print(
            f"{Colors.BPURPLE}║{' ' * 20}{Colors.BCYAN}💡 RECOMENDACIÓN: Reinicia tu equipo ahora{' ' * 33}{Colors.BPURPLE}║{Colors.RESET}")
        print(f"{Colors.BPURPLE}╚{'═' * 101}╝{Colors.RESET}\n")

        pause_continue("Presiona ENTER para salir")

    except Exception as e:
        msg(f"❌ ERROR EN PASO 5: {e}", "ERROR")
        msg(f"Traceback completo:", "ERROR")
        print(traceback.format_exc())
        msg("El script terminará, pero puedes ver el error arriba", "WARNING")
        pause_continue("Presiona ENTER para salir")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(
            f"\n{Colors.BRED}❌ Ejecución interrumpida por el usuario.{Colors.RESET}")
    except Exception as e:
        print(f"\n{Colors.BRED}❌ ERROR CRÍTICO NO MANEJADO:{Colors.RESET}")
        print(f"{Colors.BRED}Tipo: {type(e).__name__}{Colors.RESET}")
        print(f"{Colors.BRED}Mensaje: {e}{Colors.RESET}")
        print(f"\n{Colors.BYELLOW}Traceback completo:{Colors.RESET}")
        print(traceback.format_exc())
        print(
            f"\n{Colors.BGRAY}El script no pudo completarse, pero los errores están arriba.{Colors.RESET}")
    finally:
        pause_on_exit()
