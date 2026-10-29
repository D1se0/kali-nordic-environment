#!/usr/bin/env bash
# cpu.sh — píldora CPU: % global por delta de /proc/stat (sin sleep bloqueante)
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
STATE="${NORDIC_CACHE:-$HOME/.cache/nordic}/cpu-prev"
read -r c < /proc/stat
now="$c"
if [ -f "$STATE" ]; then
    read -r prev < "$STATE"
    if [ -n "$prev" ]; then
        set -- $now
        u2=$2; n2=$3; s2=$4; i2=$5
        set -- $prev
        u1=$2; n1=$3; s1=$4; i1=$5
        used=$(( (u2 + n2 + s2) - (u1 + n1 + s1) ))
        idle=$(( i2 - i1 ))
        tot=$(( used + idle ))
        if [ "$tot" -le 0 ]; then pc=0; else pc=$(( used * 100 / tot )); fi
    else
        pc=0
    fi
else
    pc=0
fi
echo "$now" > "$STATE"
if [ "$pc" -ge 85 ]; then nc="$RED"
elif [ "$pc" -ge 70 ]; then nc="$YEL"
else nc="$FG"; fi
pill $'\uf2db' "${pc}%" "$BG_PILL" "$IC" "$nc"
