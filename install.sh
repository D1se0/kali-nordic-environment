#!/usr/bin/env bash
# install.sh — versión modular (desarrollo). Idempotente. Ver docs/DECISIONS.md
set -Eeuo pipefail
export PATH="$PATH:/usr/local/bin"
REPO="$(cd "$(dirname "$0")" && pwd)"
LOG="$HOME/.cache/nordic/install.log"
mkdir -p "$HOME/.cache/nordic" "$(dirname "$LOG")"
(mkdir -p /run/nordic 2>/dev/null && chmod 1777 /run/nordic 2>/dev/null) || sudo -n mkdir -p /run/nordic 2>/dev/null || sudo -n chmod 1777 /run/nordic 2>/dev/null || true

step() { printf '  • %s\n' "$*"; }

# ── 0. usuario ──────────────────────────────────────────────────────────────
[ -n "${USER:-}" ] || USER="$(id -un)"

# ── 0bis. VALIDACIONES previas (nada se instala hasta pasarlas) ──────────
step "validando entorno antes de instalar nada"
FAIL=()
# a) OS Kali/Debian
if [ -r /etc/os-release ] && grep -qiE 'kali|debian' /etc/os-release; then
    step "  ✓ sistema: $(. /etc/os-release; echo "$PRETTY_NAME")"
else
    FAIL+=("no parece Kali/Debian (revisa /etc/os-release)")
fi
# b) sudo utilizable
sudo -n true 2>/dev/null || { FAIL+=("sudo sin contraseña disponible: ejecuta con sudo -v antes"); }
# c) NOT root (el entorno vive en $HOME)
[ "$(id -u)" -ne 0 ] || { FAIL+=("nada de instalar como root: usa tu usuario normal (por ejemplo kali)"); }
# d) espacio libre en $HOME (>1.5 GB)
FREE=$(df -BG --output=avail "$HOME" 2>/dev/null | tail -1 | tr -dc '0-9')
[ "${FREE:-0}" -ge 2 ] 2>/dev/null || FAIL+=("menos de 2 GB libres en $HOME")
# e) X11 + bspwm/polybar al alcance (instalables vía apt)
PKGS_EXTRA=""
for p in bspwm sxhkd polybar kitty rofi picom dunst lightdm-gtk-greeter i3lock xdotool imagemagick zsh git xclip ranger zathura thunar zsh-autosuggestions zsh-syntax-highlighting; do
    command -v "$p" >/dev/null 2>&1 || case "$p" in
        lightdm-gtk-greeter) dpkg -s lightdm-gtk-greeter >/dev/null 2>&1    || PKGS_EXTRA+="lightdm-gtk-greeter " ;;
        imagemagick)         command -v magick >/dev/null || command -v convert >/dev/null || PKGS_EXTRA+="imagemagick " ;;
        *)                   PKGS_EXTRA+="$p " ;;
    esac
done
if [ -n "$PKGS_EXTRA" ]; then
    step "  ✓ faltan paquetes: ${PKGS_EXTRA% } — instalando por apt"
    sudo -n apt-get update -qq 2>/dev/null || true
    sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $PKGS_EXTRA 2>/dev/null || FAIL+=("apt no pudo instalar: $PKGS_EXTRA")
fi
if [ "${#FAIL[@]}" -gt 0 ]; then
    printf '\n  ✘ VALIDACIONES FALLIDAS — no se instaló nada:\n'
    for f in "${FAIL[@]}"; do printf '    • %s\n' "$f"; done
    exit 1
fi
step "  ✓ todas las validaciones pasan: continúo con la instalación"

# ── 1. deploy de configs de usuario ────────────────────────────────────────
step "desplegando configuraciones de usuario en ~/.config"
mkdir -p "$HOME/.config"
for d in bspwm sxhkd polybar picom rofi dunst kitty alacritty zsh gtk qt nano fastfetch btop; do
    [ -d "$REPO/config/$d" ] && mkdir -p "$HOME/.config/$d" && rsync -a "$REPO/config/$d/" "$HOME/.config/$d/" 2>/dev/null || true
done
# los scripts de sesión/barras SIEMPRE ejecutables (rsync -a puede perder el bit x)
chmod 755 "$HOME"/.config/polybar/scripts/*.sh "$HOME"/.config/bspwm/*.sh "$HOME"/.config/bspwm/autostart.sh \
    "$HOME"/.config/rofi/modi/*.sh 2>/dev/null || true
install -D -m 644 "$REPO/config/zsh/zshrc" "$HOME/.config/nordic-zsh/zshrc" 2>/dev/null || true
mkdir -p "$HOME/.config/zsh" && cp -f "$REPO/config/zsh/zshrc" "$HOME/.config/zsh/zshrc"

# paleta compartida
mkdir -p "$HOME/.config/colors"
if ! sudo -n mkdir -p /usr/share/nordic 2>/dev/null; then
    echo "  ✘ sudo sin permiso para /usr/share/nordic; aborto"
    exit 1
fi
install -c -m 644 "$REPO/config/colors/nord.sh" "$HOME/.config/colors/nord.sh"
sudo -n install -c -m 644 "$REPO/config/colors/nord.sh" /usr/share/nordic/nord.sh 2>/dev/null || true
# env global (SUDO_USER friendly)
grep -q NORDIC_NORD_SH /etc/environment 2>/dev/null || echo 'NORDIC_NORD_SH=/usr/share/nordic/nord.sh' | sudo -n tee /etc/environment >/dev/null

# nano configuración: sistema + usuario
sudo -n mkdir -p "$HOME/.cache/nano/backups" "$HOME/.cache/nordic" 2>/dev/null || true
sudo -n install -c -m 644 "$REPO/config/nano/nanorc.conf" "$HOME/.cache/nordic/nanorc-core" 2>/dev/null || true
sudo -n install -c -m 644 "$REPO/config/nano/nordic.nanorc" /usr/share/nordic/nordic.nanorc 2>/dev/null || true
if ! grep -q 'nordic.nanorc' /etc/nanorc 2>/dev/null; then
    echo 'include /usr/share/nordic/nordic.nanorc' | sudo -n tee -a /etc/nanorc >/dev/null
fi
install -c -m 644 "$REPO/config/nano/nanorc.conf" "$HOME/.nanorc"
# El include de nordic.nanorc vive SOLO en /etc/nanorc: dos includes cargan las
# mismas sintaxis dos veces y nano saca el banner "Mistakes".
sed -i '/nordic.nanorc/d' "$HOME/.nanorc"
# Las sintaxis base de la distro chocan con las nuestras (nombres duplicados):
# las comentamos para que el único origen sea nordic.nanorc.
sudo -n sed -i -E 's/^([[:space:]]*include[[:space:]]+"?/usr/share/nano)/# \1/' /etc/nanorc 2>/dev/null || true

# ── 2. binarios de usuario + compartidos (/usr/local/bin) ───────────────────
step "instalando binarios en ~/.local/bin y /usr/local/bin"
mkdir -p "$HOME/.local/bin"
for b in "$REPO"/bin/*; do
    [ -f "$b" ] && install -c -m 755 "$b" "$HOME/.local/bin/"
done
for shared in settarget nordic-doctor nordic-power nordic-confirm nordic-perf nano-check nano-help ctfinit nordic-greeter-setup nordic-session nordic-typeip nordic-lock; do
    [ -f "$REPO/bin/$shared" ] && sudo -n install -c -m 755 "$REPO/bin/$shared" "/usr/local/bin/$shared"
done

# ── 3. perfil picom inicial: lite si renderizador es software ──────────────
mkdir -p "$HOME/.cache/nordic"
if command -v glxinfo >/dev/null 2>&1; then
    if DISPLAY="${DISPLAY:-:0}" glxinfo -B 2>/dev/null | grep -q 'Accelerated: yes'; then
        echo glass > "$HOME/.cache/nordic/profile"
    else
        echo lite > "$HOME/.cache/nordic/profile"
    fi
else
    echo lite > "$HOME/.cache/nordic/profile"   # errar hacia lite si glxinfo aún no está
fi
sed -i -e "s|^blur: method = .*|blur: method = \"$([ "$(cat "$HOME/.cache/nordic/profile")" = glass ] && echo dual_kawase || echo none)\";|" "$HOME/.config/picom/picom.conf"

# ── 4. sesión bspwm en LightDM (sin tocar Xfce) ─────────────────────────────
step "registrando sesión bspwm en /usr/share/xsessions"
sudo -n install -D -m 644 /dev/stdin /usr/share/xsessions/bspwm.desktop <<'EOF'
[Desktop Entry]
Name=bspwm
Comment=Kali Nordic (bspwm + polybar + picom)
Exec=/usr/local/bin/nordic-session
TryExec=/usr/local/bin/nordic-session
Type=Application
EOF

# ── 5. teclado español en todos los puntos (13.4) ───────────────────────────
step "configurando teclado es (bspwmrc/xprofile/xsessionrc/localectl/lightdm)"
grep -q 'setxkbmap es' "$HOME/.config/bspwm/bspwmrc" || sed -i '1i setxkbmap es &' "$HOME/.config/bspwm/bspwmrc"
cp -f "$REPO/config/xprofile" "$HOME/.xprofile"
cp -f "$REPO/config/xsessionrc" "$HOME/.xsessionrc"
sudo -n localectl set-x11-keymap es 2>/dev/null || true
sudo -n sed -i -e 's/^XKBLAYOUT=.*/XKBLAYOUT="es"/' /etc/default/keyboard 2>/dev/null || true
grep -q '^XKBLAYOUT=' /etc/default/keyboard 2>/dev/null || echo 'XKBLAYOUT="es"' | sudo -n tee -a /etc/default/keyboard >/dev/null
sudo -n install -D -m 644 "$REPO/config/lightdm/99-nordic.conf" /etc/lightdm/lightdm.conf.d/99-nordic.conf
sudo -n install -c -m 755 "$REPO/bin/nordic-greeter-setup" /usr/local/bin/nordic-greeter-setup

# Estética Nord del login (fondo + tema GTK Nordic-darker + tipografía)
sudo -n install -c -m 644 "$REPO/config/lightdm/99-nordic-greeter.conf" \
    /etc/lightdm/lightdm-gtk-greeter.conf.d/99-nordic-greeter.conf 2>/dev/null || true

# ── 6. fuentes + temas (assets descargados en assets/dl) ───────────────────
step "instalando fuentes JetBrainsMono Nerd y temas GTK/iconos/cursor"
mkdir -p "$HOME/.local/share/fonts" "$HOME/.themes" "$HOME/.icons"
if [ -d "$REPO/assets/dl/JetBrainsMono" ]; then
    cp -f "$REPO/assets/dl/JetBrainsMono/"*.ttf "$HOME/.local/share/fonts/" 2>/dev/null || true
fi
if [ -f "$REPO/assets/dl/Nordic.tar.xz" ]; then
    tar -xf "$REPO/assets/dl/Nordic.tar.xz" -C "$HOME/.themes" 2>/dev/null || true
fi
fc-cache -f >/dev/null 2>&1 || true

# iconos Papirus con carpetas Nord (si está papirus-folders)
if command -v papirus-folders >/dev/null 2>&1; then
    papirus-folders -C nordic --theme Papirus-Dark 2>/dev/null || true
fi

# cursor Nordzy (descarga ya en assets/dl si existe)
if [ -d "$REPO/assets/dl/Nordzy" ]; then
    cp -r "$REPO/assets/dl/Nordzy/"* "$HOME/.icons/" 2>/dev/null || true
fi
# asignar cursora/temas a GTK (gsettings si estamos en X)
if command -v gsettings >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Nordic-darker' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Nordzy-cursors' 2>/dev/null || true
fi

# ── 7. wallpapers generados + fondo para el login ──────────────────────────
step "generando wallpapers nordic + fondo del greeter"
mkdir -p "$REPO/assets"
if DISPLAY="${DISPLAY:-}" true; then :; fi
"$HOME/.local/bin/nordic-wallpaper" generate >/dev/null 2>&1 || true
WP="$HOME/.cache/nordic/nordic-wallpapers/nordic-01.png"
if [ -f "$WP" ]; then
    sudo -n mkdir -p /var/lib/lightdm
    sudo -n install -c -m 644 "$WP" /var/lib/lightdm/nordic-greeter-bg.png
fi

# ── 8. zsh por defecto + prompt + entorno ──────────────────────────────────
step "configurando zsh/entorno"
# Kali ya trae zsh como shell; forzamos si cambiara el usuario
[ "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v zsh)" ] || sudo -n chsh -s "$(command -v zsh)" "$USER" 2>/dev/null || true

# ── 8bis. bloqueo de pantalla + hook de suspensión ──────────────────────
step "restaurando bloqueo Nord y lock automático al suspender"
sudo -n install -c -m 755 "$REPO/bin/nordic-lock" /usr/local/bin/nordic-lock 2>/dev/null || true
sudo -n install -D -m 644 /dev/stdin /etc/systemd/system/nordic-lock-before-sleep.service <<'EOF'
[Unit]
Description=kali-nordic: bloqueo Nord antes de suspender
Before=sleep.target
StopWhenUnneeded=yes

[Service]
Type=oneshot
User=kali
Environment=DISPLAY=:0
Environment=NORDIC_LOCK_FORCE=1
ExecStart=/usr/local/bin/nordic-lock
TimeoutSec=15

[Install]
WantedBy=sleep.target
EOF
sudo -n systemctl daemon-reload 2>/dev/null || true
sudo -n systemctl enable nordic-lock-before-sleep.service 2>/dev/null || true
# refresca la imagen cacheada del lock si hay wallpaper ya (sin bloquear)
nordic-lock gen >/dev/null 2>&1 || "$HOME/.local/bin/nordic-lock" gen >/dev/null 2>&1 || true

# ── 9. historial y estado de sesión ────────────────────────────────
mkdir -p "$HOME/.cache/nordic"

echo
echo "  kali-nordic install completa → ejecuta 'nordic-doctor' tras reiniciar sesión"
exit 0
