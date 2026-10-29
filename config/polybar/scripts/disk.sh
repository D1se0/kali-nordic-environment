#!/usr/bin/env bash
# disk.sh — píldora disco: GB usados/total + % con umbrales de color
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
read -r _ used ttl pc < <(df -k / 2>/dev/null | awk 'NR==2{print $1, $3, $2, $5}')
if [ -z "${ttl:-}" ] || [ "${ttl:-0}" -eq 0 ]; then
    pill $'\uf0a0' "--" "$BG_PILL" "$MUT" "$MUT"; exit 0
fi
ug=$(awk -v u="$used" 'BEGIN{printf "%.0f", u/1048576}')
tg=$(awk -v t="$ttl" 'BEGIN{printf "%.0f", t/1048576}')
pc="${pc%\%}"
if [ "$pc" -ge 90 ]; then nc="$RED"
elif [ "$pc" -ge 80 ]; then nc="$YEL"
else nc="$FG"; fi
pill $'\uf0a0' "${pc}% · ${ug}/${tg}G" "$BG_PILL" "$IC" "$nc"
