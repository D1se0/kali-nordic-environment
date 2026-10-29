#!/usr/bin/env bash
# title.sh — píldora central: título de la ventana activa
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

t=$(bspc query -T -n focused 2>/dev/null | jq -r '.title // empty' 2>/dev/null)
if [ -z "$t" ]; then
    # sin ventana activa: nada (la barra respira)
    echo ""
else
    t="${t:0:58}"
    pill "" "$t" "$BG_PILL" "$IC_BRIGHT" "$FG"
fi
