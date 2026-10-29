#! /usr/bin/env bash
# logo.sh — solo el icono del dragón (clic → rofi lanzador)
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
g=$'\uf327'   # nf-linux-kali_linux (logo Kali en Nerd Font v3)
printf '%%{A1:rofi -show drun:}%%{O2}%%{T4}%%{F%s}%s%%{F-}%%{T1}%%{O2}%%{A}\n' "$IC" "$g"
