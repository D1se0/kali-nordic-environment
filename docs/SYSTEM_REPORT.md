# SYSTEM REPORT — Reconocimiento del sistema (Fase 0)

Fecha: 2026-10-27 · Host: `192.168.5.178` · Usuario: `kali`

## 1. Sistema operativo

| Campo | Valor |
|---|---|
| Distribución | **Kali GNU/Linux Rolling 2026.3** (kali-rolling) |
| Kernel | `Linux kali 7.1.5+kali-amd64 (2026-07-29)` x86_64 |
| Arquitectura | amd64 (soportada) |
| Shell por defecto | `/usr/bin/zsh` (nativa, sin cambios) |
| systemd | `running` (estado correcto) |
| systemd-detect-virt | `vmware` ✓ (VM confirmada) |
| git | 2.53.0 |

## 2. Entorno gráfico actual

- Sesión: **X11** (`loginctl` Type=x11), display `:0` activo.
- Display manager: **lightdm** (`/usr/sbin/lightdm`, conf en `/etc/lightdm/lightdm.conf.d/01_kali.conf`).
- Sesiones en `/usr/share/xsessions`: `xfce.desktop`, `lightdm-xsession.desktop`. **bspwm se añadirá como sesión nueva.**
- Resolución: **1918x920** @60 Hz sobre `Virtual-1` (VMware SVGA), con redimensionado automático operativo (vmtoolsd -n vmusr corriendo).

## 3. Recursos de la VM

| Recurso | Valor |
|---|---|
| vCPU | 4 (nproc) |
| RAM | 7.7 GiB total · 1.2 GiB usada · 6.6 GiB disponible |
| Swap | 953 MiB, sin uso |
| Disco `/` | 79 GB · 17 GB usados · **59 GB libres** ✓ (≥ 3 GB requeridos) |
| Red | `eth0` 192.168.5.178/24 (interfaz principal para el módulo IP de la barra) |
| Internet / repos Kali | ✓ OK (DNS + HTTPS a http.kali.org) |

## 4. Renderizador gráfico

`glxinfo` no está instalado todavía (se instalará con `mesa-utils` en la fase de paquetes). Decisión provisionaria: **perfil `glass` con detección dinámica** — picom con blur dual-kawase se desplegará y `nordic-doctor`/el instalador reelegirán el perfil (`lite`) si el renderizador resulta ser `llvmpipe` software o si el coste medido es alto. VMware SVGA suele exponer GL 3.3+ con vmwgfx, favorable a `glass`.

## 5. VMware Tools

- `open-vm-tools` 2:13.0.10-1.1 ✓ instalado y **activo** (`vmtoolsd`).
- `open-vm-tools-desktop` ✓ instalado; `vmtoolsd -n vmusr` corriendo (portapapeles, redimensionado). En la sesión bspwm se arrancará explícitamente en el autostart porque en sesiones no-Xfce no se lanza solo.

## 6. Hardware de entrada / locale

- **Teclado actual: `us`** (localectl X11 Layout=us, VC unset). Pendiente cambiar a **`es`** en todos los puntos (sección 13.4).
- Locale: `en_US.UTF-8` (se mantiene; solo cambia el keymap, no el idioma, salvo decisión contraria).

## 7. Línea base de rendimiento (ANTES de cambios)

| Métrica | Valor baseline |
|---|---|
| CPU total en reposo | ~3.4 % (1.1 us + 2.3 sy), 96.6 % idle |
| Carga (load avg) | 0.03 / 0.62 / 0.81 (recién encendida) |
| RAM usada total del sistema | 1.2 GiB (con Xfce completo + sesión gráfica) |
| Procesos escritorio | lightdm, xfce4-session, xfce4-panel, xfsettingsd, xfdesktop, xfce4-notifyd, xfce4-power-man, xfce4-screensav, wrapper-2.0, Xorg (~2.3 % CPU) |
| vmtoolsd | ~6.8 % puntual (iterando, normal) |

La comparación post-instalación usará el mismo método (`top -bn1`, `free -h`, listado de procesos de escritorio) con la sesión bspwm + pila Nord.

## 8. Inventario de software relevante

- **Ya instalado:** zsh, tmux, git, xclip, open-vm-tools(+desktop), nano 9.2 (`--enable-utf8`, **`--disable-libmagic`**) con 41 sintaxis en `/usr/share/nano`.
- **No instalado (a instalar):** bspwm, sxhkd, polybar, picom, rofi, kitty, alacritty, feh, maim, dunst, i3lock(-color), mesa-utils, shellcheck, shfmt, bats, jq, ImageMagick, starship, JetBrainsMono Nerd Font, Nordic theme, Papirus, Nordzy…
  - Nota `nano`: sin libmagic no funciona la detección vía `magic`; se cubrirá con **extensión + heurística de shebang** (header), que nano 9.2 soporta de forma nativa.
- **sudo:** configurado **sin contraseña** para el usuario `kali` (`sudo -n true` óptimo). No se modifica `sshd_config`, firewall ni credenciales.

## 9. Estado spa / dotfiles a respaldar (backup previo)

`~/.config` (autostart, cherrytree, dconf, gtk-3.0, ibus, nautilus, powershell, procps, pulse, qt6ct, qterminal.org, user-dirs, xfce4), `~/.zshrc`, `~/.bashrc`, `~/.profile`, `~/.zprofile`, `~/.bashrc.original`, `.face`, `.dmrc`. Sin `.xprofile` ni `.Xresources` actuales (se crearán).

## 10. Riesgos identificados

1. **La sesión Xfce del usuario está activa en `:0`** — no se tocará; las pruebas interactivas de bspwm se harán en display aparte (Xephyr/Xvfb) y la sesión real tras el reinicio final confirmado.
2. Teclado `us` hoy: hasta aplicar 13.4, los atajos con símbolos deben probarse también con layout es.
3. Picos de `vmtoolsd` son normales en iteración con el host, no indican problema.
4. `tmux` ya disponible en la VM: los pasos largos (apt, generación de wallpapers, ejecución del instalador) irán en sesión tmux persistente con log para sobrevivir a cortes de SSH.

## 11. Recomendación previa (sección 2.1)

> **Acción para ti (no puedo hacerla yo):** crea antes un **snapshot de VMware** de la VM (VM → Snapshot → Take Snapshot, con la máquina encendida o apagada). Es el punto de restauración maestro si algo saliera mal; el resto de reversibilidad lo cubre `uninstall.sh` + backup de dotfiles.

Continúo con el backup y la instalación de paquetes.
