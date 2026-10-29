#!/usr/bin/env bash
# confirm-modi.sh — rofi script mode Yes/No (No por defecto). La pregunta viaja
# en $NORDIC_CONFIRM_TEXT y se muestra con la metadata \0message del script mode.
set -u
ANS_FILE="${XDG_RUNTIME_DIR:-/tmp}/nordic-confirm-answer"

if [ "${ROFI_RETV:-0}" = 1 ]; then
    case "$1" in
        *Sí*|*Si*|*Yes*) printf 'yes\n' > "$ANS_FILE" ;;
        *)               printf 'no\n'  > "$ANS_FILE" ;;
    esac
    exit 0   # stdout vacío → rofi se cierra solo
fi

if [ -n "${NORDIC_CONFIRM_TEXT:-}" ]; then
    printf '\0message\x1f  %s\n' "$NORDIC_CONFIRM_TEXT"
fi
printf '  No (predeterminado)\n'
printf '  Sí\n'
