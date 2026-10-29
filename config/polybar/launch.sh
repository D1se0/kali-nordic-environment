#!/usr/bin/env sh
# launch.sh — mata instancias previas y lanza polybar por cada monitor
export PATH="$HOME/.local/bin:$PATH"
killall -q polybar 2>/dev/null
while pgrep -x polybar >/dev/null; do sleep 0.2; done
for M in $(polybar --list-monitors 2>/dev/null | cut -d: -f1); do
    MONITOR="$M" polybar --reload top -c "$HOME/.config/polybar/config.ini" >> "$HOME/.cache/nordic/polybar.log" 2>&1 &
done
