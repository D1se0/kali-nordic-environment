#!/usr/bin/env bash
# power.sh — botón de apagado (solo icono; clic → nordic-power)
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
local_g=$'\uf011'
printf '%%{A1:nordic-power menu:}%%{F%s}%%{O4}%s%%{F-}%%{A}\n' "$RED_SOFT" "$local_g"
