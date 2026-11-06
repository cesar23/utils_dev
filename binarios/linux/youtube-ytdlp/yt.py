#!/usr/bin/env python3
"""
VIDEO//GRAB · Descargador de videos con panel en terminal (yt-dlp + rich).

Uso:
  python yt.py            -> menú principal (video, playlist, carpeta, cookies,
                             historial, estado y actualización)
  python yt.py <URL>      -> va directo a descargar esa URL (detecta si es playlist)

Configuración persistente (compartida con yt.sh) en ~/.yt-downloader/:
  config.json     carpeta de descargas
  last_path.txt   última carpeta (compatibilidad con yt.sh)
  cookies.txt     cookies de YouTube (formato Netscape)
  historial.txt   fecha|TIPO|título|url

Requisitos:
  pip install -U "yt-dlp[default]" rich
  ffmpeg  y  deno  (ver Gui_uso.md)
"""

import json
import os
import shutil
import importlib.util
import site
import subprocess
import sys
import sysconfig
import time
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path

try:
    import yt_dlp
    from yt_dlp.utils import DownloadError
except ImportError:
    sys.exit('Falta yt-dlp. Instálalo con:  pip install -U "yt-dlp[default]"')

try:
    from rich import box
    from rich.console import Console, Group
    from rich.markup import escape
    from rich.panel import Panel
    from rich.progress import (BarColumn, DownloadColumn, Progress, TextColumn,
                               TimeRemainingColumn, TransferSpeedColumn)
    from rich.table import Table
    from rich.text import Text
except ImportError:
    sys.exit("Falta rich. Instálalo con:  pip install rich")


VERSION = "2.0"
DIAS_AVISO = 60  # yt-dlp con más días que esto se marca como desactualizado

# ----------------------------------------------------------------------
# Paleta (la del diseño aprobado)
# ----------------------------------------------------------------------
CIAN = "#3ee6ff"      # acciones, video
MAGENTA = "#ff4fd8"   # acento, audio, prompt
LIMA = "#a3ff5c"      # éxito, video+audio
AMBAR = "#ffcc4d"     # avisos
ROJO = "#ff6b6b"      # errores
GRIS = "#8a94aa"      # etiquetas
TEXTO = "#c9d1e3"     # texto normal
BLANCO = "#f2f5fb"    # títulos
BORDE = "#232a3a"
FONDO_FILA = "#0e121b"
FONDO_BARRA = "#161b27"

console = Console(highlight=False)

# ----------------------------------------------------------------------
# Rutas de configuración (mismas que yt.sh)
# ----------------------------------------------------------------------
CONFIG_DIR = Path.home() / ".yt-downloader"
CONFIG_FILE = CONFIG_DIR / "config.json"
LAST_PATH_FILE = CONFIG_DIR / "last_path.txt"
HISTORIAL_FILE = CONFIG_DIR / "historial.txt"
COOKIES_FILE = CONFIG_DIR / "cookies.txt"

COOKIES_URL = ("https://raw.githubusercontent.com/cesar23/utils_dev/refs/heads/"
               "master/binarios/linux/youtube-ytdlp/cookies.txt")

# Prefiere H.264 + AAC: compatible con Windows, Premiere y móviles (de yt.sh).
SELECTOR_MEJOR = "bv*[vcodec^=avc1]+ba[ext=m4a]/bv*[ext=mp4]+ba[ext=m4a]/bv*+ba/b"


def selector_mp4(altura=None):
    """Selector H.264 + AAC con tope de altura opcional (formato_mp4 de yt.sh)."""
    h = f"[height<={altura}]" if altura else ""
    return f"bv*{h}[vcodec^=avc1]+ba[ext=m4a]/bv*{h}[ext=mp4]+ba[ext=m4a]/bv*{h}+ba/b{h}/b"


# Calidades para playlists: (tecla, texto, nota, altura | "mp3")
CALIDADES_LISTA = [
    ("1", "Mejor calidad MP4", "H.264 + AAC · recomendado", None),
    ("2", "Hasta 1080p MP4", "", 1080),
    ("3", "Hasta 720p MP4", "", 720),
    ("4", "Hasta 480p MP4", "", 480),
    ("5", "Hasta 360p MP4", "", 360),
    ("6", "Solo audio MP3", "", "mp3"),
]


# ======================================================================
# Utilidades de formato (de descargador.py)
# ======================================================================
def tamano_legible(num_bytes):
    if not num_bytes:
        return "?"
    for unidad in ("B", "KiB", "MiB", "GiB", "TiB"):
        if num_bytes < 1024:
            return f"{num_bytes:.1f} {unidad}"
        num_bytes /= 1024
    return f"{num_bytes:.1f} PiB"


def duracion_legible(segundos):
    if not segundos:
        return "desconocida"
    segundos = int(segundos)
    h, resto = divmod(segundos, 3600)
    m, s = divmod(resto, 60)
    return f"{h:d}:{m:02d}:{s:02d}" if h else f"{m:d}:{s:02d}"


def fecha_legible(f):
    if f and len(f) == 8:
        return f"{f[6:8]}/{f[4:6]}/{f[0:4]}"
    return "desconocida"


def acortar_ruta(ruta, maximo=48):
    p = str(ruta)
    casa = str(Path.home())
    if p.startswith(casa):
        p = "~" + p[len(casa):]
    if len(p) > maximo:
        p = "..." + p[-(maximo - 3):]
    return p


# ======================================================================
# Sistema y herramientas (de yt.sh)
# ======================================================================
def detectar_sistema():
    """termux | wsl | gitbash | windows | macos | linux"""
    if Path("/data/data/com.termux/files/usr/bin/pkg").exists():
        return "termux"
    if os.name == "nt":
        return "gitbash" if os.environ.get("MSYSTEM") else "windows"
    if sys.platform == "darwin":
        return "macos"
    if os.environ.get("WSL_DISTRO_NAME") or os.environ.get("WSL_INTEROP"):
        return "wsl"
    try:
        if "microsoft" in Path("/proc/version").read_text().lower():
            return "wsl"
    except OSError:
        pass
    return "linux"


SISTEMA = detectar_sistema()


def _salida(cmd):
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        return r.stdout.strip() if r.returncode == 0 else ""
    except (OSError, subprocess.SubprocessError):
        return ""


def es_ruta_android(ruta):
    """Almacenamiento compartido de Android: no admite : ? " * | < > en nombres."""
    return str(ruta).startswith(("/storage/", "/sdcard"))


def existe_dir(ruta):
    try:
        return Path(ruta).is_dir()
    except OSError:  # p. ej. sin permiso de almacenamiento en Termux
        return False


def termux_sin_almacenamiento():
    return SISTEMA == "termux" and not (Path.home() / "storage").exists()


class MantenerDespierto:
    """En Termux evita que Android suspenda el proceso durante descargas largas."""

    def __enter__(self):
        self.activo = SISTEMA == "termux" and bool(shutil.which("termux-wake-lock"))
        if self.activo:
            subprocess.run(["termux-wake-lock"], capture_output=True)
        return self

    def __exit__(self, *exc):
        if self.activo and shutil.which("termux-wake-unlock"):
            subprocess.run(["termux-wake-unlock"], capture_output=True)
        return False


def escanear_galeria(ruta):
    """Termux: avisa a Android del archivo nuevo para que salga en galería y apps."""
    if SISTEMA != "termux" or not ruta or not es_ruta_android(ruta):
        return
    if shutil.which("termux-media-scan"):
        cmd = ["termux-media-scan"] + (["-r"] if Path(ruta).is_dir() else []) + [str(ruta)]
        subprocess.run(cmd, capture_output=True)


def carpeta_por_defecto():
    if SISTEMA == "termux":
        return Path("/storage/emulated/0/Download/youtube")
    if SISTEMA == "wsl" and shutil.which("cmd.exe") and shutil.which("wslpath"):
        perfil = _salida(["cmd.exe", "/c", "echo %USERPROFILE%"]).splitlines()
        if perfil:
            ruta = _salida(["wslpath", "-u", perfil[-1].strip()])
            if ruta and Path(ruta, "Downloads").is_dir():
                return Path(ruta, "Downloads", "youtube")
    if SISTEMA in ("linux", "wsl") and shutil.which("xdg-user-dir"):
        d = _salida(["xdg-user-dir", "DOWNLOAD"])
        if d and Path(d) != Path.home() and Path(d).is_dir():
            return Path(d, "youtube")
    return Path.home() / "Downloads" / "youtube"


def preparar_path_deno():
    """Si deno se instaló en ~/.deno/bin pero no está en el PATH, lo añade."""
    if shutil.which("deno"):
        return
    carpeta = Path.home() / ".deno" / "bin"
    if (carpeta / "deno").exists() or (carpeta / "deno.exe").exists():
        os.environ["PATH"] = f"{carpeta}{os.pathsep}{os.environ.get('PATH', '')}"


def detectar_js_runtime():
    """Devuelve (nombre, opciones_extra_para_yt_dlp)."""
    preparar_path_deno()
    if shutil.which("deno"):
        return "deno", {}  # yt-dlp usa deno por defecto
    if shutil.which("node"):
        version = _salida(["node", "-v"]).lstrip("v").split(".")[0]
        if version.isdigit() and int(version) >= 20:
            return "node", {"js_runtimes": {"node": {}}}
    for q in ("qjs", "quickjs"):
        if shutil.which(q):
            return "quickjs", {"js_runtimes": {"quickjs": {}}}
    return "none", {}


def pista_instalacion(herramienta):
    pistas = {
        "ffmpeg": {
            "termux": "pkg install ffmpeg",
            "windows": "winget install --id Gyan.FFmpeg",
            "gitbash": "winget install --id Gyan.FFmpeg  (desde PowerShell)",
            "macos": "brew install ffmpeg",
        },
        "deno": {
            "termux": "pkg install nodejs",
            "windows": "winget install --id DenoLand.Deno",
            "gitbash": "winget install --id DenoLand.Deno  (desde PowerShell)",
            "macos": "brew install deno",
        },
    }
    por_defecto = {"ffmpeg": "sudo apt install ffmpeg",
                   "deno": "curl -fsSL https://deno.land/install.sh | sh"}
    return pistas[herramienta].get(SISTEMA, por_defecto[herramienta])


def dias_desde_version(version):
    """yt-dlp usa versiones tipo 2026.10.22: devuelve los días desde esa fecha."""
    try:
        anio, mes, dia = (int(x) for x in version.split(".")[:3])
        return (datetime.now() - datetime(anio, mes, dia)).days
    except (ValueError, TypeError):
        return None


def estado_herramientas():
    runtime, opciones_js = detectar_js_runtime()
    return {
        "ffmpeg": bool(shutil.which("ffmpeg")),
        "runtime": runtime,
        "opciones_js": opciones_js,
        "ytdlp": yt_dlp.version.__version__,
    }


# ======================================================================
# Configuración persistente (carpeta)
# ======================================================================
def cargar_config():
    try:
        return json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def guardar_config(cfg):
    CONFIG_FILE.write_text(json.dumps(cfg, indent=2, ensure_ascii=False), encoding="utf-8")


def guardar_carpeta(carpeta):
    cfg = cargar_config()
    cfg["carpeta"] = str(carpeta)
    guardar_config(cfg)
    LAST_PATH_FILE.write_text(f"{carpeta}\n", encoding="utf-8")  # para yt.sh


def carpeta_inicial():
    """Última carpeta usada (config.json o last_path.txt) o la de por defecto."""
    candidatas = [cargar_config().get("carpeta")]
    try:
        candidatas.append(LAST_PATH_FILE.read_text(encoding="utf-8").strip())
    except OSError:
        pass
    for c in candidatas:
        if c and existe_dir(c):
            return Path(c)

    carpeta = carpeta_por_defecto()
    try:
        carpeta.mkdir(parents=True, exist_ok=True)
    except OSError:
        carpeta = Path.home() / "Downloads" / "youtube"
        carpeta.mkdir(parents=True, exist_ok=True)
    guardar_carpeta(carpeta)
    return carpeta


def espacio_libre(carpeta):
    try:
        return shutil.disk_usage(carpeta).free
    except OSError:
        return None


# ======================================================================
# Cookies (misma lógica que yt.sh: se bajan del repositorio)
# ======================================================================
def cookies_activas():
    return COOKIES_FILE.exists() and COOKIES_FILE.stat().st_size > 0


def contar_cookies(texto):
    """Formato Netscape: líneas no comentadas con 7 campos separados por tab."""
    total = 0
    for linea in texto.splitlines():
        if linea.startswith("#HttpOnly_"):
            linea = linea[len("#HttpOnly_"):]
        elif linea.startswith("#"):
            continue
        if len(linea.split("\t")) >= 7:
            total += 1
    return total


def instalar_cookies(texto):
    """Respalda las anteriores y guarda las nuevas con permisos 600."""
    if cookies_activas():
        shutil.copyfile(COOKIES_FILE, COOKIES_FILE.with_suffix(".txt.bak"))
    COOKIES_FILE.write_text(texto, encoding="utf-8")
    try:
        COOKIES_FILE.chmod(0o600)
    except OSError:
        pass  # en Windows chmod no aplica


def descargar_cookies():
    """Devuelve (ok, mensaje)."""
    try:
        with urllib.request.urlopen(COOKIES_URL, timeout=20) as r:
            texto = r.read().decode("utf-8", errors="replace")
    except Exception as e:  # noqa: BLE001
        return False, f"No se pudo descargar el archivo: {e}"
    total = contar_cookies(texto)
    if total == 0:
        return False, "El archivo descargado no contiene cookies válidas (formato Netscape)"
    instalar_cookies(texto)
    return True, f"{total} cookies instaladas"


def importar_cookies(ruta):
    ruta = Path(ruta).expanduser()
    try:
        texto = ruta.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        return False, f"No se pudo leer el archivo: {e}"
    total = contar_cookies(texto)
    if total == 0:
        return False, "El archivo no contiene cookies válidas (formato Netscape)"
    instalar_cookies(texto)
    return True, f"{total} cookies importadas"


# ======================================================================
# Historial (mismo formato que yt.sh)
# ======================================================================
def guardar_historial(url, titulo, tipo):
    fecha = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    titulo = (titulo or "").replace("|", "-").replace("\n", " ")
    with HISTORIAL_FILE.open("a", encoding="utf-8") as f:
        f.write(f"{fecha}|{tipo}|{titulo}|{url}\n")


def leer_historial():
    try:
        lineas = HISTORIAL_FILE.read_text(encoding="utf-8").splitlines()
    except OSError:
        return []
    filas = []
    for linea in lineas:
        partes = linea.split("|", 3)
        if len(partes) == 4:
            filas.append(partes)
    return filas


def buscar_en_historial(url):
    previas = [f for f in leer_historial() if f[3] == url]
    return previas[-1] if previas else None


# ======================================================================
# Lógica de yt-dlp (de descargador.py, con cookies y runtime JS)
# ======================================================================
def opciones_base(estado, carpeta=None):
    """Opciones comunes: cookies, runtime JS y nombres seguros en NTFS."""
    opciones = {"quiet": True, "no_warnings": True, "noplaylist": True}
    opciones.update(estado["opciones_js"])
    if cookies_activas():
        opciones["cookiefile"] = str(COOKIES_FILE)
    if carpeta and (str(carpeta).startswith("/mnt/") or es_ruta_android(carpeta)):
        # WSL escribiendo en NTFS o Termux en /storage: sin caracteres prohibidos
        opciones["windowsfilenames"] = True
    return opciones


def obtener_info(url, estado):
    """Consulta la información del video sin descargarlo."""
    with yt_dlp.YoutubeDL(opciones_base(estado)) as ydl:
        return ydl.extract_info(url, download=False)


def tipo_formato(f):
    if f.get("vcodec") == "none":
        return "solo audio"
    if f.get("acodec") == "none":
        return "solo video"
    return "video+audio"


def formatos_descargables(info):
    """Filtra los formatos reales (sin storyboards) y los ordena por calidad."""
    lista = []
    for f in info.get("formats", []):
        if f.get("ext") == "mhtml" or "storyboard" in (f.get("format_note") or ""):
            continue
        lista.append(f)
    lista.sort(key=lambda f: (f.get("height") or 0, f.get("tbr") or 0))
    return lista


def diagnosticar(texto):
    """Traduce un error de yt-dlp a (causa, solución, reintentar, espera_seg)."""
    t = texto.lower()
    if "requested format is not available" in t:
        return ("YouTube no devolvió formatos utilizables",
                f"Menú 6 · actualiza yt-dlp e instala deno (runtime actual: {detectar_js_runtime()[0]})",
                False, 0)
    if "sign in to confirm" in t or "not a bot" in t:
        return ("YouTube pide verificación anti-bot",
                "Actualiza las cookies en el menú 4 · Cookies", False, 0)
    if any(k in t for k in ("private video", "video unavailable", "members-only",
                            "has been removed", "confirm your age", "age-restricted")):
        return ("Video no disponible (privado, eliminado, +18 o solo miembros)",
                "Si es +18 o de miembros, actualiza las cookies (menú 4)", False, 0)
    if "ffmpeg" in t and ("not installed" in t or "not found" in t):
        return ("Falta ffmpeg", pista_instalacion("ffmpeg"), False, 0)
    if "http error 429" in t:
        return ("YouTube está limitando peticiones (429)", "Esperando 20 s...", True, 20)
    if "http error 403" in t:
        return ("Error 403 de YouTube", "Suele resolverse actualizando yt-dlp (menú 6)", True, 5)
    return ("Error en la descarga", "Reintentando...", True, 5)


class BarraColor(BarColumn):
    """Barra cuyo color depende de la tarea (video cian, audio magenta)."""

    def render(self, task):
        color = task.fields.get("color", CIAN)
        self.complete_style = color
        self.finished_style = color
        return super().render(task)


class ProgresoDescarga:
    """Barras de progreso (video cian, audio magenta) alimentadas por yt-dlp."""

    def __init__(self):
        self.progress = Progress(
            TextColumn("{task.fields[etiqueta]}", style="bold"),
            TextColumn(f"[{GRIS}]{{task.fields[detalle]}}"),
            BarraColor(bar_width=None, style=FONDO_BARRA),
            TextColumn(f"[{BLANCO}]{{task.percentage:>3.0f}}%"),
            DownloadColumn(),
            TransferSpeedColumn(),
            TimeRemainingColumn(),
            console=console,
        )
        self.tareas = {}

    def hook(self, d):
        info = d.get("info_dict") or {}
        clave = info.get("format_id") or d.get("filename")
        if clave not in self.tareas:
            if info.get("vcodec") == "none":
                etiqueta = f"[{MAGENTA}]AUDIO"
                color = MAGENTA
                detalle = f"{info.get('ext', '')} · {int(info.get('tbr') or 0)}k"
            else:
                etiqueta = f"[{CIAN}]VIDEO"
                color = CIAN
                res = f"{info.get('height')}p" if info.get("height") else ""
                fps = f" · {int(info['fps'])}fps" if info.get("fps") else ""
                detalle = f"{res}{fps}"
            self.tareas[clave] = self.progress.add_task(
                "", etiqueta=etiqueta, detalle=detalle, color=color, total=None)
        tarea = self.tareas[clave]
        total = d.get("total_bytes") or d.get("total_bytes_estimate")
        if d.get("status") == "downloading":
            self.progress.update(tarea, completed=d.get("downloaded_bytes") or 0, total=total)
        elif d.get("status") == "finished":
            hecho = d.get("total_bytes") or d.get("downloaded_bytes") or total or 1
            self.progress.update(tarea, completed=hecho, total=hecho)

    def hook_post(self, d):
        if d.get("status") == "started" and "Merger" in (d.get("postprocessor") or ""):
            self.progress.console.print(f"  [{AMBAR}]◆[/] [{AMBAR}]uniendo video + audio con ffmpeg…[/]")


def selector_para(formato):
    if formato is None:
        return SELECTOR_MEJOR
    fid = formato["format_id"]
    if tipo_formato(formato) == "solo video":
        # Se le suma audio para dejar un solo archivo (AAC primero).
        return f"{fid}+ba[ext=m4a]/{fid}+ba/{fid}"
    return fid


def _descargar_una_vez(url, formato, carpeta, estado):
    barras = ProgresoDescarga()
    opciones = opciones_base(estado, carpeta)
    opciones.update({
        "format": selector_para(formato),
        "outtmpl": str(carpeta / "%(title).150B [%(id)s].%(ext)s"),
        "continuedl": True,
        "noprogress": True,
        "progress_hooks": [barras.hook],
        "postprocessor_hooks": [barras.hook_post],
    })
    solo_audio = formato is not None and tipo_formato(formato) == "solo audio"
    if not solo_audio:
        opciones["merge_output_format"] = "mp4"

    with barras.progress:
        with yt_dlp.YoutubeDL(opciones) as ydl:
            resultado = ydl.extract_info(url, download=True)

    descargas = resultado.get("requested_downloads") or []
    ruta = Path(descargas[0]["filepath"]) if descargas and descargas[0].get("filepath") else None

    # Si un video no quedó en .mp4, se convierte sin recodificar.
    if ruta and not solo_audio and ruta.suffix.lower() != ".mp4" and ruta.exists():
        destino = ruta.with_suffix(".mp4")
        console.print(f"  [{AMBAR}]◆ convirtiendo {ruta.suffix} → .mp4 (sin recodificar)…[/]")
        r = subprocess.run(["ffmpeg", "-y", "-i", str(ruta), "-c", "copy", str(destino)],
                           capture_output=True, text=True)
        if r.returncode == 0:
            ruta.unlink()
            ruta = destino
        else:
            aviso("No se pudo convertir a mp4; se conserva el archivo original")
    return ruta


def descargar(url, formato, carpeta, estado, intentos=3):
    """Descarga con reintentos y diagnóstico. Devuelve (ok, ruta)."""
    for intento in range(1, intentos + 1):
        try:
            return True, _descargar_una_vez(url, formato, carpeta, estado)
        except DownloadError as e:
            causa, solucion, reintentar, espera = diagnosticar(str(e))
            panel_error(causa, solucion, str(e))
            if not reintentar or intento == intentos:
                return False, None
            info(f"Intento {intento + 1}/{intentos} en {espera} s…")
            time.sleep(espera)
    return False, None


# ======================================================================
# Playlists (lógica)
# ======================================================================
def tipo_url_lista(url):
    """'lista' (/playlist?list=), 'video_en_lista' (watch?v=…&list=…) o None."""
    partes = urllib.parse.urlparse(url)
    consulta = urllib.parse.parse_qs(partes.query)
    if "list" not in consulta:
        return None
    if partes.path.rstrip("/").endswith("/playlist") or "v" not in consulta:
        return "lista"
    return "video_en_lista"


def obtener_info_playlist(url, estado):
    """Lee la lista sin entrar a cada video (rápido)."""
    opciones = opciones_base(estado)
    opciones.update({"noplaylist": False, "extract_flat": "in_playlist"})
    with yt_dlp.YoutubeDL(opciones) as ydl:
        return ydl.extract_info(url, download=False)


def contar_rango(rango, total):
    """Cuántos videos cubre un rango tipo '1-10,15,20-' sobre una lista de `total`."""
    if not rango:
        return total
    indices = set()
    for parte in rango.replace(" ", "").split(","):
        if not parte:
            continue
        if "-" in parte:
            ini, _, fin = parte.partition("-")
            ini = int(ini) if ini else 1
            fin = int(fin) if fin else total
            indices.update(range(ini, min(fin, total) + 1))
        else:
            n = int(parte)
            if 1 <= n <= total:
                indices.add(n)
    return len(indices)


def rango_valido(rango):
    """Acepta '1-10', '5,8,12', '20-'. No acepta índices negativos ('-5')."""
    partes = [p for p in rango.replace(" ", "").split(",") if p]
    if not partes:
        return False
    return all(p[0].isdigit() and all(c.isdigit() or c == "-" for c in p)
               and p.count("-") <= 1 for p in partes)


def nombre_carpeta_lista(titulo):
    try:
        from yt_dlp.utils import sanitize_filename
        limpio = sanitize_filename(titulo or "", restricted=False)
    except Exception:  # noqa: BLE001
        limpio = "".join(c for c in (titulo or "") if c not in '<>:"/\\|?*')
    return (limpio.strip(" .") or "playlist")[:120]


class ProgresoPlaylist:
    """Barra general de la lista + barra del archivo actual."""

    def __init__(self, total):
        self.total = total
        self.hechos = 0
        self.saltados = 0
        self.errores = []
        self.progress = Progress(
            TextColumn("{task.fields[etiqueta]}", style="bold"),
            TextColumn(f"[{GRIS}]{{task.fields[detalle]}}"),
            BarraColor(bar_width=None, style=FONDO_BARRA),
            TextColumn(f"[{BLANCO}]{{task.percentage:>3.0f}}%"),
            TextColumn(f"[{TEXTO}]{{task.fields[extra]}}"),
            console=console,
        )
        self.general = self.progress.add_task(
            "", etiqueta=f"[{LIMA}]LISTA ", detalle=f"0/{total}", color=LIMA,
            total=max(total, 1), extra="")
        self.actual = self.progress.add_task(
            "", etiqueta=f"[{CIAN}]VIDEO ", detalle="esperando…", color=CIAN,
            total=None, extra="")

    def _avanzar(self):
        procesados = min(self.hechos + self.saltados + len(self.errores), self.total)
        self.progress.update(self.general, completed=procesados,
                             detalle=f"{procesados}/{self.total}")

    def hook(self, d):
        info = d.get("info_dict") or {}
        es_audio = info.get("vcodec") == "none"
        color = MAGENTA if es_audio else CIAN
        idx = info.get("playlist_index")
        titulo = (info.get("title") or "")[:38]
        detalle = f"#{idx:02d} {titulo}" if isinstance(idx, int) else titulo
        if d.get("status") == "downloading":
            velocidad = d.get("speed")
            self.progress.update(
                self.actual,
                completed=d.get("downloaded_bytes") or 0,
                total=d.get("total_bytes") or d.get("total_bytes_estimate"),
                etiqueta=f"[{color}]{'AUDIO ' if es_audio else 'VIDEO '}",
                detalle=escape(detalle), color=color,
                extra=f"{tamano_legible(velocidad)}/s" if velocidad else "")

    def hook_post(self, d):
        # MoveFiles se ejecuta una vez por cada video terminado.
        if d.get("status") == "finished" and "MoveFiles" in (d.get("postprocessor") or ""):
            info = d.get("info_dict") or {}
            self.hechos += 1
            self._avanzar()
            idx = info.get("playlist_index")
            num = f"{idx:02d} " if isinstance(idx, int) else ""
            self.progress.console.print(
                f"  [{LIMA}]✔[/] [{GRIS}]{num}[/][{TEXTO}]{escape(info.get('title') or '')}[/]")

    def saltar(self):
        self.saltados += 1
        self._avanzar()

    def fallo(self, mensaje):
        self.errores.append(mensaje)
        self._avanzar()
        corto = mensaje.replace("ERROR:", "").strip().splitlines()[0][:110]
        self.progress.console.print(f"  [{ROJO}]✖[/] [{GRIS}]{escape(corto)}[/]")


class RegistroPlaylist:
    """Logger para yt-dlp: cuenta saltados (ya descargados) y errores por video."""

    def __init__(self, progreso):
        self.p = progreso

    def debug(self, mensaje):
        if "has already been recorded in the archive" in mensaje:
            self.p.saltar()

    def info(self, mensaje):
        self.debug(mensaje)

    def warning(self, mensaje):
        pass

    def error(self, mensaje):
        self.p.fallo(mensaje)


def descargar_playlist(url, carpeta_lista, estado, calidad, rango, total):
    """Descarga la lista. Devuelve el ProgresoPlaylist con los contadores."""
    barras = ProgresoPlaylist(total)
    opciones = opciones_base(estado, carpeta_lista)
    opciones.update({
        "noplaylist": False,
        "ignoreerrors": True,   # un video caído no detiene la lista
        "download_archive": str(carpeta_lista / ".descargados.txt"),  # reanudar
        "outtmpl": str(carpeta_lista / "%(playlist_index)03d - %(title).120B [%(id)s].%(ext)s"),
        "continuedl": True,
        "noprogress": True,
        "logger": RegistroPlaylist(barras),
        "progress_hooks": [barras.hook],
        "postprocessor_hooks": [barras.hook_post],
    })
    if rango:
        opciones["playlist_items"] = rango.replace(" ", "")
    if calidad == "mp3":
        opciones["format"] = "ba/b"
        opciones["postprocessors"] = [{"key": "FFmpegExtractAudio",
                                       "preferredcodec": "mp3", "preferredquality": "0"}]
    else:
        opciones["format"] = selector_mp4(calidad)
        opciones["merge_output_format"] = "mp4"

    with barras.progress:
        with yt_dlp.YoutubeDL(opciones) as ydl:
            ydl.download([url])
    return barras


# ======================================================================
# Componentes de interfaz
# ======================================================================
def pedir(texto=""):
    etiqueta = f" [{GRIS}]{texto}[/]" if texto else ""
    return console.input(f"\n  [{MAGENTA}]❯[/]{etiqueta} ").strip()


def confirmar(pregunta, defecto="n"):
    pista = "S/n" if defecto == "s" else "s/N"
    r = console.input(f"  [{TEXTO}]{pregunta}[/] [{GRIS}]({pista})[/] [{MAGENTA}]❯[/] ").strip()
    return (r or defecto).lower() in ("s", "si", "sí", "y")


def pausa(texto="Listo"):
    console.input(f"\n  [{GRIS}]{texto} · ENTER para continuar[/] ")


def exito(texto):
    console.print(f"  [{LIMA}]✔[/] [{TEXTO}]{escape(texto)}[/]")


def aviso(texto):
    console.print(f"  [{AMBAR}]▲[/] [{AMBAR}]{escape(texto)}[/]")


def error(texto):
    console.print(f"  [{ROJO}]✖[/] [{ROJO}]{escape(texto)}[/]")


def info(texto):
    console.print(f"  [{CIAN}]▸[/] [{GRIS}]{escape(texto)}[/]")


def tecla(k, activo=False):
    if activo:
        return f"[bold black on {CIAN}] {k} [/]"
    return f"[bold {TEXTO} on {BORDE}] {k} [/]"


def opcion(k, texto, nota="", activo=False):
    nota = f"   [{GRIS}]{nota}[/]" if nota else ""
    estilo = f"bold {BLANCO}" if activo else TEXTO
    console.print(f"  {tecla(k, activo)}  [{estilo}]{texto}[/]{nota}")


def punto(ok, texto_ok="ok", texto_mal="falta", color_mal=ROJO):
    return f"[{LIMA}]● {texto_ok}[/]" if ok else f"[{color_mal}]○ {texto_mal}[/]"


def cabecera(subtitulo="descargador de videos · yt-dlp + ffmpeg"):
    console.clear()
    logo = Text()
    logo.append("VIDEO", style=f"bold {BLANCO}")
    logo.append("//", style=f"bold {CIAN}")
    logo.append("GRAB", style=f"bold {BLANCO}")
    logo.append("  ")
    logo.append(f" v{VERSION} ", style=f"bold black on {MAGENTA}")
    console.print()
    console.print(logo, style="", justify="left")
    console.print(f"[{GRIS}]{subtitulo}[/]")
    console.print()


def texto_ytdlp(estado):
    dias = dias_desde_version(estado["ytdlp"])
    if dias is not None and dias > DIAS_AVISO:
        return f"[{GRIS}]yt-dlp[/] [{AMBAR}]{estado['ytdlp']} ({dias} días · actualizar: 6)[/]"
    return f"[{GRIS}]yt-dlp[/] [{TEXTO}]{estado['ytdlp']}[/]"


def linea_estado(estado, carpeta):
    if cookies_activas():
        fecha = datetime.fromtimestamp(COOKIES_FILE.stat().st_mtime).strftime("%Y-%m-%d")
        cookies = f"[{LIMA}]● activas · {fecha}[/]"
    else:
        cookies = f"[{AMBAR}]○ no configuradas[/]"
    rt = estado["runtime"]
    partes = [
        f"[{GRIS}]carpeta[/] [{TEXTO}]{escape(acortar_ruta(carpeta))}[/]",
        f"[{GRIS}]ffmpeg[/] {punto(estado['ffmpeg'])}",
        f"[{GRIS}]js[/] {punto(rt != 'none', rt)}",
        f"[{GRIS}]cookies[/] {cookies}",
        texto_ytdlp(estado),
        f"[{GRIS}]sistema[/] [{TEXTO}]{SISTEMA}[/]",
    ]
    console.print("  " + "   ".join(partes))


def panel_error(causa, solucion, detalle=""):
    cuerpo = [Text(causa, style=f"bold {ROJO}"), Text(f"→ {solucion}", style=TEXTO)]
    ultima = [l for l in detalle.splitlines() if l.strip()]
    if ultima:
        cuerpo.append(Text(ultima[-1][:160], style=GRIS))
    console.print(Panel(Group(*cuerpo), border_style=ROJO, box=box.ROUNDED,
                        padding=(0, 2), title=f"[{ROJO}]error[/]", title_align="left"))


# ======================================================================
# Pantallas
# ======================================================================
def mostrar_info(info, url):
    if info.get("is_live"):
        sello = Text(" ● EN VIVO ", style=f"bold black on {AMBAR}")
    elif info.get("formats"):
        sello = Text(" ● DISPONIBLE ", style=f"bold black on {LIMA}")
    else:
        sello = Text(" ○ NO DISPONIBLE ", style=f"bold black on {ROJO}")

    cabeza = Table.grid(expand=True)
    cabeza.add_column()
    cabeza.add_column(justify="right")
    cabeza.add_row(Text("VIDEO", style=f"bold {CIAN}"), sello)

    datos = Table.grid(padding=(0, 4))
    for _ in range(5):
        datos.add_column()
    vistas = f"{info['view_count']:,}" if info.get("view_count") is not None else "?"
    datos.add_row(*(Text(t, style=GRIS) for t in ("autor", "duración", "fecha", "vistas", "sitio")))
    datos.add_row(
        Text(info.get("uploader") or info.get("channel") or "desconocido", style=TEXTO),
        Text(duracion_legible(info.get("duration")), style=TEXTO),
        Text(fecha_legible(info.get("upload_date")), style=TEXTO),
        Text(vistas, style=TEXTO),
        Text(info.get("extractor_key", "?"), style=TEXTO),
    )
    titulo = Text(info.get("title", "desconocido"), style=f"bold {BLANCO}")

    console.print(f"  [{MAGENTA}]❯[/] [{GRIS}]url[/] [{TEXTO}]{escape(url)}[/]")
    console.print(Panel(Group(cabeza, titulo, Text(""), datos), border_style=BORDE,
                        box=box.ROUNDED, padding=(1, 2)))


COLOR_TIPO = {"video+audio": LIMA, "solo video": CIAN, "solo audio": MAGENTA}


def mostrar_formatos(formatos):
    tabla = Table(box=box.SIMPLE_HEAD, border_style=BORDE, header_style=GRIS,
                  row_styles=["", f"on {FONDO_FILA}"], pad_edge=False, padding=(0, 1))
    for nombre, just in (("N°", "right"), ("ID", "left"), ("EXT", "left"),
                         ("RESOLUCIÓN", "left"), ("FPS", "right"), ("BITRATE", "right"),
                         ("TAMAÑO", "right"), ("TIPO", "left")):
        tabla.add_column(nombre, justify=just)

    for i, f in enumerate(formatos, start=1):
        tipo = tipo_formato(f)
        if tipo == "solo audio":
            res = "audio"
        else:
            res = f.get("resolution") or (
                f"{f.get('width')}x{f.get('height')}" if f.get("height") else "-")
        tabla.add_row(
            Text(str(i), style=GRIS),
            Text(str(f.get("format_id", "?")), style=TEXTO),
            Text(f.get("ext", "?"), style=GRIS),
            Text(res, style=f"bold {BLANCO}"),
            Text(f"{int(f['fps'])}" if f.get("fps") else "-", style=TEXTO),
            Text(f"{int(f['tbr'])}k" if f.get("tbr") else "-", style=TEXTO),
            Text(tamano_legible(f.get("filesize") or f.get("filesize_approx")), style=TEXTO),
            Text(tipo, style=f"bold {COLOR_TIPO[tipo]}"),
        )
    console.print(tabla)
    console.print(f"  {tecla('m', True)}  [bold {BLANCO}]mejor calidad automática[/]"
                  f"   [{GRIS}]H.264 + AAC · un solo MP4[/]   [{AMBAR}]★ recomendado[/]")
    console.print(f"  {tecla('0')}  [{TEXTO}]cancelar[/]")


def elegir_formato(formatos):
    """Devuelve (cancelado, formato). formato=None significa 'mejor automático'."""
    while True:
        op = pedir("formato").lower()
        if op == "0":
            return True, None
        if op in ("m", ""):
            return False, None
        if op.isdigit() and 1 <= int(op) <= len(formatos):
            return False, formatos[int(op) - 1]
        error("Opción no válida. Escribe un N° de la lista, 'm' o '0'.")


def pantalla_resultado(ruta, carpeta):
    filas = Table.grid(padding=(0, 3))
    filas.add_column(style=GRIS)
    filas.add_column(style=BLANCO)
    if ruta and ruta.exists():
        filas.add_row("archivo", escape(ruta.name))
        filas.add_row("tamaño", tamano_legible(ruta.stat().st_size))
        filas.add_row("carpeta", escape(acortar_ruta(ruta.parent, 60)))
    else:
        filas.add_row("carpeta", escape(str(carpeta)))
    console.print()
    console.print(Panel(Group(Text("✔ DESCARGA COMPLETA", style=f"bold {LIMA}"), Text(""), filas),
                        border_style=LIMA, box=box.ROUNDED, padding=(1, 2)))


def comprobar_espacio(carpeta):
    libre = espacio_libre(carpeta)
    if libre is None:
        return True
    gb = libre / 1024 ** 3
    color = ROJO if gb < 1 else LIMA
    console.print(f"  [{GRIS}]libre[/] [{color}]{gb:.1f} GB[/]")
    if gb < 1:
        aviso("Menos de 1 GB de espacio libre")
        return confirmar("¿Continuar de todas formas?", "n")
    return True


def flujo_descarga(carpeta, estado, url=None):
    if not url:
        url = pedir("URL del video (Enter para volver)")
        if not url:
            return
    if not url.startswith(("http://", "https://")):
        error("La URL debe empezar con http:// o https://")
        pausa()
        return

    # URL de lista: se ofrece pasar al flujo de playlist antes de consultarla
    # (consultar una lista entera como "video" es muy lento).
    tipo_lista = tipo_url_lista(url)
    if tipo_lista == "lista":
        aviso("La URL es una playlist.")
        if confirmar("¿Descargar la lista completa?", "s"):
            flujo_playlist(carpeta, estado, url)
        return
    if tipo_lista == "video_en_lista":
        info("Este video es parte de una playlist.")
        if confirmar("¿Descargar la lista completa? (n = solo este video)", "n"):
            flujo_playlist(carpeta, estado, url)
            return

    previa = buscar_en_historial(url)
    if previa:
        aviso(f"Esta URL ya se descargó el {previa[0]} · {previa[2]}")
        if not confirmar("¿Descargar nuevamente?", "n"):
            return

    cabecera("consultando video…")
    with console.status(f"[{GRIS}]Consultando información del video…[/]", spinner="dots",
                        spinner_style=CIAN):
        try:
            info_video = obtener_info(url, estado)
        except DownloadError as e:
            info_video = None
            causa, solucion, _, _ = diagnosticar(str(e))
        except Exception as e:  # noqa: BLE001
            info_video = None
            causa, solucion = "Error inesperado", str(e)
    if info_video is None:
        panel_error(causa, solucion)
        pausa()
        return

    if info_video.get("_type") == "playlist":
        aviso("La URL es una lista de reproducción.")
        if confirmar("¿Descargarla como playlist?", "s"):
            flujo_playlist(carpeta, estado, url)
        return

    cabecera("información del video")
    mostrar_info(info_video, url)

    if info_video.get("is_live"):
        aviso("Es una transmisión en vivo: la descarga puede no terminar nunca.")
        if not confirmar("¿Continuar?", "n"):
            return

    formatos = formatos_descargables(info_video)
    if not formatos:
        error("No hay formatos disponibles para descargar.")
        pausa()
        return

    mostrar_formatos(formatos)
    cancelado, formato = elegir_formato(formatos)
    if cancelado:
        info("Descarga cancelada.")
        return

    console.print()
    console.print(f"  [{CIAN}]▸[/] [{GRIS}]destino[/] [{TEXTO}]{escape(acortar_ruta(carpeta, 60))}[/]")
    if not comprobar_espacio(carpeta):
        return
    console.print()

    try:
        with MantenerDespierto():
            ok, ruta = descargar(url, formato, carpeta, estado)
    except KeyboardInterrupt:
        console.print()
        aviso("Descarga interrumpida. Si repites la descarga, se retoma donde quedó.")
        pausa()
        return

    if not ok:
        pausa("La descarga falló")
        return

    escanear_galeria(ruta)
    pantalla_resultado(ruta, carpeta)
    tipo = "AUDIO" if formato is not None and tipo_formato(formato) == "solo audio" else "VIDEO"
    guardar_historial(url, info_video.get("title"), tipo)
    pausa("Descarga completada")


def mostrar_info_playlist(info_lista, url):
    entradas = [e for e in (info_lista.get("entries") or []) if e]
    total = info_lista.get("playlist_count") or len(entradas)

    cabeza = Table.grid(expand=True)
    cabeza.add_column()
    cabeza.add_column(justify="right")
    cabeza.add_row(Text("PLAYLIST", style=f"bold {LIMA}"),
                   Text(f" {total} videos ", style=f"bold black on {LIMA}"))
    titulo = Text(info_lista.get("title") or "Playlist sin título", style=f"bold {BLANCO}")
    autor = info_lista.get("uploader") or info_lista.get("channel") or "desconocido"

    lista = Table.grid(padding=(0, 2))
    lista.add_column(style=GRIS, justify="right")
    lista.add_column(style=TEXTO, overflow="ellipsis", no_wrap=True, max_width=58)
    lista.add_column(style=GRIS, justify="right")
    for i, e in enumerate(entradas[:8], start=1):
        lista.add_row(f"{i:02d}", e.get("title") or e.get("id") or "?",
                      duracion_legible(e.get("duration")) if e.get("duration") else "")
    if total > 8:
        lista.add_row("", Text(f"… y {total - 8} más", style=GRIS), "")

    console.print(f"  [{MAGENTA}]❯[/] [{GRIS}]url[/] [{TEXTO}]{escape(url)}[/]")
    console.print(Panel(Group(cabeza, titulo, Text(autor, style=GRIS), Text(""), lista),
                        border_style=BORDE, box=box.ROUNDED, padding=(1, 2)))
    return total


def elegir_calidad_lista():
    console.print(f"\n  [bold {BLANCO}]CALIDAD[/]")
    for k, texto, nota, _ in CALIDADES_LISTA:
        opcion(k, texto, nota, activo=(k == "1"))
    opcion("0", "Cancelar")
    while True:
        op = pedir("calidad") or "1"
        if op == "0":
            return False, None
        for k, _, _, valor in CALIDADES_LISTA:
            if op == k:
                return True, valor
        error("Opción no válida.")


def elegir_rango(total):
    console.print(f"\n  [bold {BLANCO}]VIDEOS[/]   [{GRIS}]Enter = todos · ej: 1-10   5,8,12   20-[/]")
    while True:
        rango = pedir("rango")
        if not rango:
            return None, total
        if rango_valido(rango):
            try:
                cantidad = contar_rango(rango, total)
            except ValueError:
                cantidad = 0
            if cantidad > 0:
                return rango, cantidad
        error("Rango no válido para esta lista.")


def pantalla_resumen_lista(barras, carpeta_lista):
    filas = Table.grid(padding=(0, 3))
    filas.add_column(style=GRIS)
    filas.add_column()
    filas.add_row("descargados", Text(str(barras.hechos), style=f"bold {LIMA}"))
    filas.add_row("ya existían", Text(str(barras.saltados), style=TEXTO))
    filas.add_row("fallidos", Text(str(len(barras.errores)),
                                   style=f"bold {ROJO}" if barras.errores else GRIS))
    filas.add_row("carpeta", Text(acortar_ruta(carpeta_lista, 60), style=BLANCO))

    if barras.errores and barras.hechos == 0:
        titulo, color = "✖ NO SE DESCARGÓ NINGÚN VIDEO", ROJO
    elif barras.errores:
        titulo, color = "▲ PLAYLIST COMPLETADA CON ERRORES", AMBAR
    else:
        titulo, color = "✔ PLAYLIST COMPLETA", LIMA
    console.print()
    console.print(Panel(Group(Text(titulo, style=f"bold {color}"), Text(""), filas),
                        border_style=color, box=box.ROUNDED, padding=(1, 2)))
    if barras.errores:
        causa, solucion, _, _ = diagnosticar(barras.errores[-1])
        info(f"Último error: {causa} → {solucion}")
    if barras.errores or barras.saltados:
        info("Vuelve a descargar la misma lista para reintentar: los ya bajados se saltan.")


def flujo_playlist(carpeta, estado, url=None):
    if not url:
        url = pedir("URL de la playlist (Enter para volver)")
        if not url:
            return
    if not url.startswith(("http://", "https://")):
        error("La URL debe empezar con http:// o https://")
        pausa()
        return

    cabecera("consultando playlist…")
    with console.status(f"[{GRIS}]Leyendo la lista…[/]", spinner="dots", spinner_style=CIAN):
        try:
            info_lista = obtener_info_playlist(url, estado)
        except DownloadError as e:
            info_lista = None
            causa, solucion, _, _ = diagnosticar(str(e))
        except Exception as e:  # noqa: BLE001
            info_lista = None
            causa, solucion = "Error inesperado", str(e)
    if info_lista is None:
        panel_error(causa, solucion)
        pausa()
        return

    if info_lista.get("_type") != "playlist":
        aviso("La URL no es una playlist: se descargará como video individual.")
        pausa()
        flujo_descarga(carpeta, estado, url)
        return

    cabecera("playlist")
    total = mostrar_info_playlist(info_lista, url)
    if not total:
        error("La playlist está vacía o es privada.")
        pausa()
        return

    seguir, calidad = elegir_calidad_lista()
    if not seguir:
        info("Descarga cancelada.")
        return
    rango, cantidad = elegir_rango(total)

    carpeta_lista = carpeta / nombre_carpeta_lista(info_lista.get("title"))
    try:
        carpeta_lista.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        error(f"No se pudo crear la carpeta de la lista: {e}")
        pausa()
        return

    console.print()
    console.print(f"  [{CIAN}]▸[/] [{GRIS}]destino[/] [{TEXTO}]{escape(acortar_ruta(carpeta_lista, 60))}[/]")
    console.print(f"  [{CIAN}]▸[/] [{GRIS}]videos[/]  [{TEXTO}]{cantidad} de {total}[/]")
    if not comprobar_espacio(carpeta):
        return
    if not confirmar(f"¿Descargar {cantidad} videos?", "s"):
        info("Descarga cancelada.")
        return
    console.print()

    try:
        with MantenerDespierto():
            barras = descargar_playlist(url, carpeta_lista, estado, calidad, rango, cantidad)
    except KeyboardInterrupt:
        console.print()
        aviso("Descarga interrumpida. Repite la misma lista: se retoma donde quedó.")
        pausa()
        return
    except DownloadError as e:
        causa, solucion, _, _ = diagnosticar(str(e))
        panel_error(causa, solucion, str(e))
        pausa("La descarga de la playlist falló")
        return

    escanear_galeria(carpeta_lista)
    pantalla_resumen_lista(barras, carpeta_lista)
    if barras.hechos:
        guardar_historial(url, info_lista.get("title") or "PLAYLIST", "PLAYLIST")
    pausa("Playlist finalizada")


# ======================================================================
# Mantenimiento: estado y actualización de herramientas (de yt.sh)
# ======================================================================
def ultima_version_ytdlp():
    try:
        with urllib.request.urlopen("https://pypi.org/pypi/yt-dlp/json", timeout=10) as r:
            return json.load(r)["info"]["version"]
    except Exception:  # noqa: BLE001
        return None


def primera_linea(cmd):
    texto = _salida(cmd)
    return texto.splitlines()[0] if texto else ""


def en_entorno_virtual():
    return sys.prefix != getattr(sys, "base_prefix", sys.prefix)


def sistema_bloquea_pip():
    """Ubuntu 23.04+, Debian 12+…: pip no instala fuera de un venv (PEP 668)."""
    try:
        return Path(sysconfig.get_path("stdlib"), "EXTERNALLY-MANAGED").exists()
    except (KeyError, TypeError):
        return False


def origen_ytdlp():
    """Dónde está instalado yt-dlp: venv | usuario | apt | sistema."""
    if en_entorno_virtual():
        return "venv"
    ruta = str(Path(yt_dlp.__file__).resolve())
    try:
        sitio_usuario = site.getusersitepackages()
    except AttributeError:
        sitio_usuario = ""
    if sitio_usuario and ruta.startswith(str(Path(sitio_usuario).resolve())):
        return "usuario"   # pip install --user
    if ruta.startswith("/usr/lib/"):
        return "apt"       # sudo apt install yt-dlp (suele estar desactualizado)
    return "sistema"       # sudo pip install (/usr/local/lib/...)


DESCRIPCION_ORIGEN = {
    "venv": "entorno virtual",
    "usuario": "global · usuario (~/.local)",
    "apt": "paquete apt del sistema",
    "sistema": "global · sistema (/usr/local)",
}


def con_sudo(cmd):
    """Antepone sudo en Linux si no somos root y sudo existe."""
    if SISTEMA == "termux" or os.name == "nt":
        return cmd
    if hasattr(os, "geteuid") and os.geteuid() == 0:
        return cmd
    return (["sudo"] + cmd) if shutil.which("sudo") else cmd


def ejecutar(cmd, confirmar_antes=True):
    """Muestra el comando, pide confirmación y lo ejecuta con salida en vivo."""
    console.print(f"\n  [{GRIS}]$[/] [{TEXTO}]{escape(' '.join(cmd))}[/]")
    if confirmar_antes and not confirmar("¿Ejecutar?", "s"):
        info("Omitido")
        return None
    console.print()
    try:
        rc = subprocess.call(cmd)
    except FileNotFoundError:
        error(f"No se encontró el programa: {cmd[0]}")
        return 1
    except KeyboardInterrupt:
        aviso("Interrumpido")
        return 1
    console.print()
    if rc == 0:
        exito("Comando terminado correctamente")
    else:
        error(f"El comando terminó con código {rc}")
    return rc


def comando_pip_ytdlp():
    """pip adecuado según dónde esté instalado yt-dlp.

    - venv o sistema sin bloqueo (Windows, Termux, Ubuntu antiguo): pip normal.
    - Ubuntu/Debian modernos fuera de venv: se instala para el usuario en
      ~/.local con --break-system-packages (no toca los paquetes del sistema).
      Si yt-dlp venía de apt o de sudo pip, la copia de ~/.local tiene
      prioridad y pasa a ser la que se usa.
    """
    cmd = [sys.executable, "-m", "pip", "install", "-U"]
    origen = origen_ytdlp()
    if origen != "venv" and sistema_bloquea_pip():
        cmd += ["--user", "--break-system-packages"]
    elif origen == "usuario":
        cmd += ["--user"]
    return cmd + ["yt-dlp[default]", "rich"]


def comando_deno():
    """Comando para instalar o actualizar deno (o node en Termux)."""
    if SISTEMA == "termux":
        return ["pkg", "install", "-y", "nodejs"]
    if shutil.which("deno"):
        return ["deno", "upgrade"]
    if os.name == "nt":
        return ["winget", "install", "--id", "DenoLand.Deno", "-e"] if shutil.which("winget") else None
    if SISTEMA == "macos" and shutil.which("brew"):
        return ["brew", "install", "deno"]
    if shutil.which("curl"):
        return ["sh", "-c", "curl -fsSL https://deno.land/install.sh | sh -s -- -y"]
    return None


def comando_ffmpeg():
    if SISTEMA == "termux":
        return ["pkg", "install", "-y", "ffmpeg"]
    if os.name == "nt":
        return ["winget", "install", "--id", "Gyan.FFmpeg", "-e"] if shutil.which("winget") else None
    if SISTEMA == "macos":
        return ["brew", "install", "ffmpeg"] if shutil.which("brew") else None
    for gestor in ("apt-get", "dnf", "yum"):
        if shutil.which(gestor):
            return con_sudo([gestor, "install", "-y", "ffmpeg"])
    return None


def actualizar_ytdlp():
    """Devuelve True si se actualizó (hay que reiniciar para usar la versión nueva)."""
    if importlib.util.find_spec("pip") is None:
        error("pip no está instalado en este Python.")
        if SISTEMA in ("linux", "wsl") and shutil.which("apt-get"):
            ejecutar(con_sudo(["apt-get", "install", "-y", "python3-pip"]))
        if importlib.util.find_spec("pip") is None:
            return False

    origen = origen_ytdlp()
    info(f"yt-dlp instalado en: {DESCRIPCION_ORIGEN[origen]}")
    if origen == "apt":
        aviso("La versión de apt suele ir atrasada: se instalará una copia nueva en ~/.local")
    elif origen == "sistema" and sistema_bloquea_pip():
        aviso("Se instalará una copia nueva en ~/.local que tendrá prioridad sobre /usr/local")
    if origen != "venv" and sistema_bloquea_pip():
        info("--user --break-system-packages instala solo para tu usuario, sin tocar el sistema")
    return ejecutar(comando_pip_ytdlp()) == 0


def instalar_deno():
    if SISTEMA in ("linux", "wsl") and not shutil.which("deno") and not shutil.which("unzip"):
        aviso("El instalador de deno necesita 'unzip'.")
        cmd = comando_ffmpeg()
        if cmd:  # mismo gestor de paquetes que ffmpeg
            ejecutar(cmd[:-1] + ["unzip"])
    cmd = comando_deno()
    if not cmd:
        error("No se encontró una forma automática de instalar deno en este sistema.")
        info(f"Manual: {pista_instalacion('deno')}")
        return
    ejecutar(cmd)
    preparar_path_deno()
    if os.name == "nt" and cmd[0] == "winget":
        info("Cierra y vuelve a abrir la terminal para que deno quede en el PATH.")


def instalar_ffmpeg():
    if shutil.which("ffmpeg"):
        exito(f"ffmpeg ya está instalado: {primera_linea(['ffmpeg', '-version'])[:60]}")
        if os.name == "nt" and shutil.which("winget"):
            ejecutar(["winget", "upgrade", "--id", "Gyan.FFmpeg", "-e"])
        return
    cmd = comando_ffmpeg()
    if not cmd:
        error("No se encontró un gestor de paquetes para instalar ffmpeg.")
        info(f"Manual: {pista_instalacion('ffmpeg')}")
        return
    ejecutar(cmd)
    if os.name == "nt":
        info("Cierra y vuelve a abrir la terminal para que ffmpeg quede en el PATH.")


def mostrar_comandos_manuales():
    console.print(f"\n  [bold {BLANCO}]COMANDOS MANUALES · {SISTEMA}[/]\n")
    lineas = [" ".join(comando_pip_ytdlp()),
              pista_instalacion("deno"),
              pista_instalacion("ffmpeg")]
    if shutil.which("deno"):
        lineas.insert(2, "deno upgrade")
    for linea in lineas:
        console.print(f"  [{GRIS}]$[/] [{TEXTO}]{escape(linea)}[/]")


def reiniciar():
    """Vuelve a lanzar el script para cargar la versión nueva de yt-dlp."""
    console.print(f"\n  [{CIAN}]▸[/] [{GRIS}]reiniciando…[/]\n")
    argumentos = [sys.executable, os.path.abspath(sys.argv[0])]
    if os.name == "nt":
        sys.exit(subprocess.call(argumentos))
    os.execv(sys.executable, argumentos)


def tabla_estado(estado):
    with console.status(f"[{GRIS}]Consultando la última versión de yt-dlp…[/]",
                        spinner="dots", spinner_style=CIAN):
        ultima = ultima_version_ytdlp()

    actual = estado["ytdlp"]
    dias = dias_desde_version(actual)
    if ultima is None:
        estado_yt = Text("sin conexión para comprobar", style=AMBAR)
    elif ultima == actual:
        estado_yt = Text("● al día", style=LIMA)
    else:
        estado_yt = Text(f"▲ hay versión nueva: {ultima}", style=AMBAR)

    rt = estado["runtime"]
    version_rt = primera_linea([rt, "--version"]) if rt in ("deno", "node") else ""
    ffmpeg = primera_linea(["ffmpeg", "-version"])

    t = Table.grid(padding=(0, 3))
    t.add_column(style=GRIS)
    t.add_column()
    t.add_row("sistema", Text(SISTEMA, style=AMBAR))
    t.add_row("python", Text(f"{sys.version.split()[0]} · "
                             f"{'venv activo' if en_entorno_virtual() else 'sin venv'}", style=TEXTO))
    t.add_row("instalado", Text(DESCRIPCION_ORIGEN[origen_ytdlp()], style=TEXTO))
    t.add_row("yt-dlp", Text(f"{actual}" + (f"  ({dias} días)" if dias is not None else ""),
                             style=AMBAR if dias and dias > DIAS_AVISO else LIMA))
    t.add_row("", estado_yt)
    t.add_row("runtime js", Text(f"{rt} {version_rt}".strip() if rt != "none" else "○ no instalado",
                                 style=LIMA if rt != "none" else ROJO))
    t.add_row("ffmpeg", Text(ffmpeg[:60] if ffmpeg else "○ no instalado",
                             style=LIMA if ffmpeg else ROJO))
    t.add_row("cookies", Text("● activas" if cookies_activas() else "○ no configuradas",
                              style=LIMA if cookies_activas() else AMBAR))
    console.print(Panel(t, border_style=BORDE, box=box.ROUNDED, padding=(1, 2),
                        title=f"[{CIAN}]estado de herramientas[/]", title_align="left"))


def menu_mantenimiento(estado):
    """Devuelve el estado actualizado (o reinicia el script si cambió yt-dlp)."""
    while True:
        cabecera("mantenimiento · actualizar herramientas")
        tabla_estado(estado)
        console.print()
        opcion("1", "Actualizar yt-dlp y rich", "pip · recomendado", activo=True)
        opcion("2", "Instalar / actualizar deno", "runtime JS para YouTube")
        opcion("3", "Instalar / actualizar ffmpeg")
        opcion("4", "Todo", "si algo falla")
        opcion("5", "Mostrar comandos manuales")
        opcion("0", "Volver")

        op = pedir("opción")
        actualizado = False
        if op == "1":
            actualizado = actualizar_ytdlp()
        elif op == "2":
            instalar_deno()
        elif op == "3":
            instalar_ffmpeg()
        elif op == "4":
            actualizado = actualizar_ytdlp()
            instalar_deno()
            instalar_ffmpeg()
        elif op == "5":
            mostrar_comandos_manuales()
        elif op in ("0", ""):
            return estado
        else:
            error("Opción no válida.")
            time.sleep(1)
            continue

        estado = estado_herramientas()
        if actualizado:
            info("La versión nueva de yt-dlp se usa al reiniciar el programa.")
            if confirmar("¿Reiniciar ahora?", "s"):
                reiniciar()
        pausa("Mantenimiento")


def cambiar_carpeta(actual):
    cabecera("carpeta de descargas")
    console.print(f"  [{GRIS}]actual[/] [{CIAN}]{escape(str(actual))}[/]")
    nueva = pedir("nueva ruta · '.' = carpeta actual · Enter = mantener")
    if not nueva:
        return actual
    ruta = Path.cwd() if nueva == "." else Path(nueva).expanduser().resolve()
    try:
        ruta.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        error(f"No se pudo usar esa carpeta: {e}")
        pausa()
        return actual
    guardar_carpeta(ruta)
    console.print()
    exito(f"Carpeta de descargas: {ruta}")
    comprobar_espacio(ruta)
    pausa()
    return ruta


def menu_cookies():
    while True:
        cabecera("cookies de YouTube")
        if cookies_activas():
            fecha = datetime.fromtimestamp(COOKIES_FILE.stat().st_mtime).strftime("%Y-%m-%d %H:%M")
            total = contar_cookies(COOKIES_FILE.read_text(encoding="utf-8", errors="replace"))
            console.print(f"  [{GRIS}]estado[/]  [{LIMA}]● activas · {total} cookies · {fecha}[/]")
        else:
            console.print(f"  [{GRIS}]estado[/]  [{AMBAR}]○ no configuradas[/]")
        console.print(f"  [{GRIS}]archivo[/] [{TEXTO}]{escape(str(COOKIES_FILE))}[/]")
        console.print()
        opcion("1", "Descargar del repositorio", "reemplaza las actuales", activo=True)
        opcion("2", "Importar archivo local", "cookies.txt exportado del navegador")
        opcion("0", "Volver")

        op = pedir("opción")
        console.print()
        if op == "1":
            with console.status(f"[{GRIS}]Descargando cookies…[/]", spinner="dots",
                                spinner_style=CIAN):
                ok, mensaje = descargar_cookies()
        elif op == "2":
            ruta = pedir("ruta del cookies.txt")
            if not ruta:
                continue
            ok, mensaje = importar_cookies(ruta)
        elif op == "0" or op == "":
            return
        else:
            error("Opción no válida.")
            time.sleep(1)
            continue

        if ok:
            exito(mensaje)
            if COOKIES_FILE.with_suffix(".txt.bak").exists():
                info(f"Respaldo: {COOKIES_FILE.with_suffix('.txt.bak')}")
        else:
            error(mensaje)
        pausa()


def ver_historial():
    cabecera("historial · últimas 10 descargas")
    filas = leer_historial()
    if not filas:
        aviso("El historial está vacío")
        pausa()
        return
    console.print(f"  [{GRIS}]total[/] [{LIMA}]{len(filas)}[/]")
    tabla = Table(box=box.SIMPLE_HEAD, border_style=BORDE, header_style=GRIS,
                  row_styles=["", f"on {FONDO_FILA}"], pad_edge=False)
    tabla.add_column("FECHA", style=GRIS, no_wrap=True)
    tabla.add_column("TIPO", no_wrap=True)
    tabla.add_column("TÍTULO", style=TEXTO, overflow="ellipsis", no_wrap=True, max_width=56)
    colores = {"VIDEO": CIAN, "AUDIO": MAGENTA}
    for fecha, tipo, titulo, _url in filas[-10:]:
        tabla.add_row(fecha[:16], Text(tipo, style=f"bold {colores.get(tipo, AMBAR)}"), titulo)
    console.print(tabla)
    if confirmar("¿Eliminar todo el historial?", "n"):
        if confirmar("Esta acción no se puede deshacer. ¿Seguro?", "n"):
            HISTORIAL_FILE.write_text("", encoding="utf-8")
            exito("Historial eliminado")
            pausa()


def avisos_iniciales(estado):
    if termux_sin_almacenamiento():
        aviso("Termux no tiene permiso de almacenamiento: los videos quedan dentro de Termux.")
        console.print(f"     [{GRIS}]ejecuta una vez:[/] [{TEXTO}]termux-setup-storage[/]"
                      f"  [{GRIS}]y vuelve a abrir el programa[/]")
    if not estado["ffmpeg"]:
        aviso("ffmpeg no está instalado: sin él no se unen video y audio.")
        console.print(f"     [{GRIS}]instálalo con:[/] [{TEXTO}]{pista_instalacion('ffmpeg')}[/]")
    if estado["runtime"] == "none":
        aviso("No hay runtime JavaScript (deno/node 20+): YouTube ocultará formatos.")
        console.print(f"     [{GRIS}]instálalo con:[/] [{TEXTO}]{pista_instalacion('deno')}[/]")


def main():
    # Git Bash / consolas antiguas: forzar UTF-8 para tildes y símbolos.
    for flujo in (sys.stdout, sys.stderr):
        if (getattr(flujo, "encoding", "") or "").lower().replace("-", "") != "utf8":
            try:
                flujo.reconfigure(encoding="utf-8")
            except (AttributeError, ValueError):
                pass

    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    estado = estado_herramientas()
    carpeta = carpeta_inicial()

    if len(sys.argv) > 1:
        flujo_descarga(carpeta, estado, sys.argv[1].strip())
        return

    while True:
        cabecera()
        opcion("1", "Descargar un video", "pegar URL", activo=True)
        opcion("2", "Descargar una playlist", "lista completa o un rango")
        opcion("3", "Cambiar carpeta de descargas")
        opcion("4", "Cookies de YouTube")
        opcion("5", "Historial")
        opcion("6", "Estado y actualización", "yt-dlp · deno · ffmpeg")
        opcion("0", "Salir")
        console.print()
        linea_estado(estado, carpeta)
        avisos_iniciales(estado)

        op = pedir("elige una opción")
        if op == "1":
            flujo_descarga(carpeta, estado)
        elif op == "2":
            flujo_playlist(carpeta, estado)
        elif op == "3":
            carpeta = cambiar_carpeta(carpeta)
        elif op == "4":
            menu_cookies()
        elif op == "5":
            ver_historial()
        elif op == "6":
            estado = menu_mantenimiento(estado)
        elif op in ("0", "q", "x"):
            console.print(f"\n  [{GRIS}]¡Hasta luego![/]\n")
            break
        elif op:
            error("Opción no válida.")
            time.sleep(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        console.print(f"\n\n  [{GRIS}]Saliendo...[/]\n")
    except EOFError:
        pass
