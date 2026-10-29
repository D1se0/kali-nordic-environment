#!/usr/bin/env bash
# workspaces.sh — 10 escritorios bspwm (tail sobre bspc subscribe)
# Todos con el MISMO icono (>_); señales por color/fondo:
#   activo   → fondo translúcido + icono brillante
#   ocupada  → icono Frost
#   urgente  → icono Aurora-red
#   vacía    → icono muy atenuado
# Uso: stream | raw | click N
set -u
export PATH="$HOME/.local/bin:$PATH"
DIR="$(dirname "${BASH_SOURCE[0]}")"
. "$DIR/lib.sh"

readonly WS_ICON=$'\uf120'   # >_ terminal (uniforme en los 10)

in_list() { case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

ws() {
    local name="$1" state="${2:-}" out
    local act="%{A1:$HOME/.config/polybar/scripts/workspaces.sh click $name:}"
    case "$state" in
        focused)   out="$act%{F$IC_BRIGHT}%{T5} $WS_ICON %{F-}%{T1}%{A}" ;;
        urgent)    out="$act%{F$RED}%{T5} $WS_ICON %{F-}%{T1}%{A}" ;;
        occupied)  out="$act%{F$MUT}%{T5} $WS_ICON %{F-}%{T1}%{A}" ;;
        *)         out="$act%{F$MUT_DIM}%{T5} $WS_ICON %{F-}%{T1}%{A}" ;;
    esac
    printf '%s%%{O2}' "$out"
}

state_line() {
    local names focused occupied urgent out='' n i=0
    names=$(bspc query -D --names 2>/dev/null | tr '\n' ' ' | xargs)
    if [[ -z $names ]]; then echo ""; return 0; fi
    focused=$(bspc query -D -d focused --names 2>/dev/null | head -1)
    occupied=$(bspc query -D -d .occupied --names 2>/dev/null | tr '\n' ' ' | xargs)
    urgent=$(bspc query -D -d .urgent --names 2>/dev/null | tr '\n' ' ' | xargs)
    for n in $names; do
        state=''
        in_list "$n" "$occupied" && state=occupied
        in_list "$n" "$urgent" && state=urgent
        [[ $n == "$focused" ]] && state=focused
        out+="$(ws "$n" "$state")"
        i=$((i + 1))
    done
    # empuje final: polybar fija el módulo centrado en el ANCHO TOTAL de la
    # barra (fixed-center=true). Este espacio invisible al final del módulo
    # desplaza el bloque VISIBLE a la izquierda para que los huecos hacia la
    # zona izquierda y hacia la zona derecha queden iguales (calibrado ~94px).
    echo "$out%{O94}"
}

case "${1:-}" in
    stream)
        state_line
        bspc subscribe 2>/dev/null | while read -r _; do state_line; done
        ;;
    raw|'') state_line ;;
    click)  bspc desktop -f "$2" 2>/dev/null ;;
esac
