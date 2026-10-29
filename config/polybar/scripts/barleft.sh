#!/usr/bin/env bash
# barleft.sh — ZONA IZQUIERDA combinada (un solo módulo, sin fondues de color):
# [dragón Kali] [mira + IP atacante] [red + IP local] [candado + IP VPN]
# Un único módulo esquiva el fantasma de avance entre módulos/custom-script
# de polybar/XFT en este stack. Los clics van por tags %{A}.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SPACE='%{O10}'   # aire entre icono y su texto (dentro del par)
SEP2="$SEP"     # separador de secciones (viene de lib.sh)

# ── logo KALI (solo icono; clic → rofi) ─────────────────────────────────
# aire extra a la derecha del logo: nunca pegado a la IP víctima
LOGO="%{A1:rofi -show drun:}%{O12}$(chunk $'\uf327' "" "$IC" "")%{O14}%{A}"

# ── IP atacante (target; mira; clic → settarget --copy) ─────────────────
target_file="${NORDIC_TARGET_FILE:-$( [ ${EUID:-$(id -u)} -eq 0 ] && echo /run/nordic/target 2>/dev/null || echo "$HOME/.cache/nordic/target" )}"
line=''
[ -r "$target_file" ] && read -r line < "$target_file" 2>/dev/null
tip=${line%%|*}
tname=${line#*|}

if [ -z "$tip" ]; then
    TARGET_PAIR="%{A1:bash -c 'settarget --copy' 2>/dev/null:}$(chunk $'\uf05b' "No Target" "$MUT" "$MUT")%{A}"
else
    tlabel="${tname:-${tip}}"; tlabel="${tlabel:0:22}"
    TARGET_PAIR="%{A1:bash -c 'settarget --copy' 2>/dev/null:}$(chunk $'\uf05b' "$tlabel" "$IC_BRIGHT" "$FG")%{A}"
fi

# ── IP local (red; clic → nordic-netmenu) ───────────────────────────────
ip4=""
for f in eth0 ens33 $(ls /sys/class/net 2>/dev/null | grep -E '^(en|eth)' 2>/dev/null); do
    v=$(ip -4 -o addr show dev "$f" 2>/dev/null | awk 'NR==1{print $4; exit}')
    if [ -n "$v" ]; then ip4="${v%%/*}"; break; fi
done
if [ -n "$ip4" ]; then
    IP_PAIR="%{A1:nordic-netmenu:}$(chunk $'\uf0ac' "$ip4")%{A}"
else
    IP_PAIR="%{A1:nordic-netmenu:}$(chunk $'\uf0ac' "sin red" "$MUT" "$MUT")%{A}"
fi

# ── IP VPN (candado; tun*/wg*/tailscale*/ppp*) ──────────────────────────
dev="$(ip -o link 2>/dev/null | awk -F': ' '{print $2}' | grep -Eo '^(tun|wg|tailscale|ppp)[a-zA-Z0-9]*' | head -1)"
if [ -n "$dev" ]; then
    ip_v="$(ip -4 -o addr show dev "$dev" 2>/dev/null | awk 'NR==1{print $4}' | cut -d/ -f1)"
    [ -n "$ip_v" ] || ip_v="$(ip -6 -o addr show dev "$dev" scope global 2>/dev/null | awk 'NR==1{print $4}' | cut -d/ -f1)"
    case "$ip_v" in
        10.10.*) et=" · ${IP_ENV_LABEL:-HTB}"; ics="$GRN" ;;
        *)       et=''; ics="$GRN" ;;
    esac
    VPN_PAIR=$(chunk $'\uf023' "VPN ${ip_v}${et}" "$ics" "$FG")
else
    VPN_PAIR=$(chunk $'\uf023' "no VPN" "$MUT" "$MUT")
fi

# Colchón final espejo: empuja el fin de la zona izquierda hasta el punto
# simétrico del inicio de la zona derecha → huecos iguales around del centro.
printf '%s%s%s%s%s%s%s%s\n' "$LOGO" "$SEP2" "$TARGET_PAIR" "$SEP2" "$IP_PAIR" "$SEP2" "$VPN_PAIR"
