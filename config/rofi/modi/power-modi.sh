#!/usr/bin/env bash
# power-modi.sh — rofi script mode del menú de energía (rofi 2.0: el modo dmenu
# pinta el window blanco; el script-mode usa la ruta de render de drun y sí
# respeta config.rasi). Al elegir, escribe la acción y sale con stdout vacío
# para que rofi se cierre solo.
set -u
ACT_FILE="${XDG_RUNTIME_DIR:-/tmp}/nordic-power-action"

can_suspend()   { grep -qE '\bmem\b'  /sys/power/state 2>/dev/null; }
can_hibernate() { grep -qE '\bdisk\b' /sys/power/state 2>/dev/null; }

if [ "${ROFI_RETV:-0}" = 1 ]; then
    case "$1" in
        *Apagar*)     printf 'poweroff\n' > "$ACT_FILE" ;;
        *Reiniciar*)  printf 'reboot\n'   > "$ACT_FILE" ;;
        *Suspender*)  can_suspend   && printf 'suspend\n'   > "$ACT_FILE" ;;
        *Hibernar*)   can_hibernate && printf 'hibernate\n' > "$ACT_FILE" ;;
        *Bloquear*)   printf 'lock\n'     > "$ACT_FILE" ;;
        *Cerrar*)     printf 'logout\n'   > "$ACT_FILE" ;;
    esac
    exit 0
fi

printf '  Apagar\n'
printf '  Reiniciar\n'
can_suspend && printf '  Suspender\n'
printf '  Bloquear\n'
printf '  Cerrar sesión\n'
can_hibernate && printf '  Hibernar\n'
