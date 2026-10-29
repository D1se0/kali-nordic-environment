#!/usr/bin/env bash
# uninstall.sh — restaura el backup previo y desactiva la sesión bspwm
set -Eeuo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"

BK="$(ls -1t ~/backups/pre-nordic-*.tar.gz 2>/dev/null | head -1)"
if [ -z "$BK" ]; then
    echo "  ✘ no hay backup en ~/backups/pre-nordic-*.tar.gz"
    exit 1
fi
echo "  • restaurando $BK"
tar xzf "$BK" -C "$HOME"

echo "  • eliminando configs nordic de ~/.config"
rm -rf "$HOME"/.config/{bspwm,sxhkd,polybar,picom,rofi,dunst,kitty,alacritty,nordic-zsh}
rm -f "$HOME"/.nanorc "$HOME"/.xprofile "$HOME"/.xsessionrc

echo "  • eliminando binarios ~/ .local/bin"
for b in "$REPO"/bin/*; do rm -f "$HOME/.local/bin/$(basename "$b")"; done

echo "  • sistema: retirando /usr/local/bin compartidos y sesión bspwm"
for s in settarget nordic-doctor nordic-power nordic-confirm nordic-perf nano-check nano-help ctfinit nordic-greeter-setup nordic-session; do
    sudo -n rm -f "/usr/local/bin/$s"
done
sudo -n rm -f /usr/share/xsessions/bspwm.desktop
sudo -n rm -f /etc/lightdm/lightdm.conf.d/99-nordic.conf
sudo -n sed -i '/nordic.nanorc/d' /etc/nanorc 2>/dev/null || true
sudo -n rm -rf /usr/share/nordic /var/lib/lightdm/nordic-greeter-bg.png

echo "  ✔ desinstalado (Xfce sigue disponible; el resto del sistema sin tocar)"
