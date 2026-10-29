#!/usr/bin/env bash
# ram.sh — píldora RAM: % + GB usados
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
avail=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
if [ -z "$total" ] || [ -z "$avail" ] || [ "$total" -eq 0 ]; then
    pill $'\uf080' "--" "$BG_PILL" "$MUT" "$MUT"; exit 0
fi
used=$(( total - avail ))
pc=$(( used * 100 / total ))
ug=$(awk -v u="$used" 'BEGIN{printf "%.1f", u/1048576}')
if [ "$pc" -ge 85 ]; then nc="$RED"
elif [ "$pc" -ge 75 ]; then nc="$YEL"
else nc="$FG"; fi
pill $'\uf080' "${ug}G · ${pc}%" "$BG_PILL" "$IC" "$nc"
