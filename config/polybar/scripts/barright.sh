#!/usr/bin/env bash
# barright.sh — ZONA DERECHA combinada (un solo módulo, sin fondos de color):
# [cpu + %] [ram + G·%] [disco + %·usado/total] [reloj + HH:MM]
# El botón de apagado sigue aparte para conservar su propio clic.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SPACE='%{O12}'   # aire entre pares
SEP2="$SEP"     # separador de secciones (viene de lib.sh)

# ── CPU % (delta /proc/stat con cache) ──────────────────────────────────
STATE="${NORDIC_CACHE:-$HOME/.cache/nordic}/cpu-prev"
read -r c < /proc/stat
now="$c"; pc=0
if [ -f "$STATE" ]; then
    read -r prev < "$STATE"
    if [ -n "$prev" ]; then
        set -- $now; u2=$2; n2=$3; s2=$4; i2=$5
        set -- $prev; u1=$2; n1=$3; s1=$4; i1=$5
        used=$(( (u2 + n2 + s2) - (u1 + n1 + s1) ))
        idle=$(( i2 - i1 )); tot=$(( used + idle ))
        [ "$tot" -gt 0 ] && pc=$(( used * 100 / tot ))
    fi
fi
echo "$now" > "$STATE"
if [ "$pc" -ge 85 ]; then ccpu="$RED"; elif [ "$pc" -ge 70 ]; then ccpu="$YEL"; else ccpu="$FG"; fi
CPU_PAIR=$(chunk $'\uf2db' "${pc}%" "$IC" "$ccpu")

# ── RAM ─────────────────────────────────────────────────────────────────
total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
avail=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
RAM_PAIR=$(chunk $'\uf080' "--" "$MUT" "$MUT")
if [ -n "$total" ] && [ -n "$avail" ] && [ "$total" -gt 0 ]; then
    used=$(( total - avail )); pcr=$(( used * 100 / total ))
    ug=$(awk -v u="$used" 'BEGIN{printf "%.1f", u/1048576}')
    if [ "$pcr" -ge 85 ]; then cram="$RED"; elif [ "$pcr" -ge 75 ]; then cram="$YEL"; else cram="$FG"; fi
    RAM_PAIR=$(chunk $'\uf080' "${ug}G · ${pcr}%" "$IC" "$cram")
fi

# ── Disco ───────────────────────────────────────────────────────────────
read -r _ usedd ttld pcd < <(df -k / 2>/dev/null | awk 'NR==2{print $1, $3, $2, $5}')
DISK_PAIR=$(chunk $'\uf0a0' "--" "$MUT" "$MUT")
if [ -n "${ttld:-}" ] && [ "${ttld:-0}" -gt 0 ]; then
    ug=$(awk -v u="$usedd" 'BEGIN{printf "%.0f", u/1048576}')
    tg=$(awk -v t="$ttld" 'BEGIN{printf "%.0f", t/1048576}')
    pcd="${pcd%\%}"
    if [ "$pcd" -ge 90 ]; then cdis="$RED"; elif [ "$pcd" -ge 80 ]; then cdis="$YEL"; else cdis="$FG"; fi
    DISK_PAIR=$(chunk $'\uf0a0' "${pcd}% · ${ug}/${tg}G" "$IC" "$cdis")
fi

# ── Reloj ───────────────────────────────────────────────────────────────
CLOCK_PAIR=$(chunk $'\uf017' "$(date +%H:%M)" "$IC" "$FG")

printf '%s%s%s%s%s%s\n' "$CPU_PAIR" "$SEP2" "$RAM_PAIR" "$SEP2" "$DISK_PAIR" "$SEP2$CLOCK_PAIR"
