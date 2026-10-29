#!/usr/bin/env bash
# target.sh — módulo TARGET (ipc-hook).
# empty → atenuado     · set → texto/icono en Aurora-red suave (sin fondo)
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
state_file="${NORDIC_TARGET_FILE:-$( [ ${EUID:-$(id -u)} -eq 0 ] && echo /run/nordic/target 2>/dev/null || echo "$HOME/.cache/nordic/target" )}"
read -r line < "$state_file" 2>/dev/null || line=''
ip=${line%%|*}
name=${line#*|}

if [ -z "$ip" ]; then
    chunk $'\uf05b' "No Target" "$MUT" "$MUT"
else
    label="${name:-${ip}}"
    label="${label:0:26}"
    chunk $'\uf05b' "$label" "$RED_SOFT" "$RED_SOFT"
fi
