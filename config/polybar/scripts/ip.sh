#!/usr/bin/env bash
# ip.sh — píldora IP de la interfaz principal (eth0/ens33/enp*)
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

iface=""; ip4=""
for f in eth0 ens33 enp*; do
  case "$f" in *'*') continue ;; esac
  v=$(ip -4 -o addr show dev "$f" 2>/dev/null | awk 'NR==1{print $4; exit}')
  if [ -n "$v" ]; then iface="$f"; ip4="${v%%/*}"; break; fi
done
if [ -z "$ip4" ]; then
  iface=$(ip -4 -o addr show 2>/dev/null | awk '$2!="lo"{print $2; exit}')
  [ -n "$iface" ] && ip4=$(ip -4 -o addr show dev "$iface" 2>/dev/null | awk 'NR==1{print $4}' | cut -d/ -f1)
fi
if [ -n "$ip4" ]; then
    pill $'\uf0ac' "$ip4"
else
    pill $'\uf0ac' "sin red" "$BG_PILL" "$MUT" "$MUT"
fi
