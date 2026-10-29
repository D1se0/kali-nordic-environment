#!/usr/bin/env bash
# clock.sh — píldora del reloj (hora; fecha en el formato alternativo al hacer clic)
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
pill $'\uf017' "$(date +%H:%M)"
