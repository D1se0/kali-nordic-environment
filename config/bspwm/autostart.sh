#!/usr/bin/env sh
# autostart.sh — procesos de sesión (ligero y en paralelo)
export PATH="$HOME/.local/bin:$PATH"

# Evitar duplicados si bspwmrc se recarga con Super+Shift+R
is_running() { pgrep -f "$1" >/dev/null 2>&1; }

# Portapapeles/redimensionado de VMware (NO arranca solo fuera de Xfce)
if ! is_running "vmtoolsd -n vmusr"; then
    [ -x /usr/bin/vmtoolsd ] && (vmtoolsd -n vmusr >/dev/null 2>&1 &)
fi
if ! is_running "vmware-user-suid-wrapper"; then
    [ -x /usr/bin/vmware-user-suid-wrapper ] && (vmware-user-suid-wrapper >/dev/null 2>&1 &)
fi

# xsession extras para portapapeles y arrastrar-y-soltar
[ -x /usr/bin/vmware-xdg-dashboard ] && true

# Compositor de efectos (glass)
if ! is_running "picom"; then
    picom --config "$HOME/.config/picom/picom.conf" >/dev/null 2>&1 &
fi

# Notificaciones
if ! is_running "dunst"; then
    dunst >/dev/null 2>&1 &
fi

# Hotkeys
if ! is_running "sxhkd"; then
    sxhkd -c "$HOME/.config/sxhkd/sxhkdrc" >/dev/null 2>&1 &
fi

# Fondo de pantalla nórdico + cursor
"$HOME/.local/bin/nordic-wallpaper" restore >/dev/null 2>&1 &
xsetroot -cursor_name left_ptr >/dev/null 2>&1

# Historial de portapapeles (rofi-greenclip)
if ! is_running "greenclip daemon"; then
    command -v greenclip >/dev/null 2>&1 && (greenclip daemon >/dev/null 2>&1 &)
fi

# Barra (por monitor)
"$HOME/.config/polybar/launch.sh" >/dev/null 2>&1 &

# delay de arranque para primer render estable
sleep 0.2
