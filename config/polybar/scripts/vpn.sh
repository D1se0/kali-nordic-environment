#!/usr/bin/env bash
# vpn.sh — píldora VPN (tun*/wg*/tailscale*/ppp*) con IP propia
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
dev="$(ip -o link 2>/dev/null | awk -F': ' '{print $2}' | grep -Eo '^(tun|wg|tailscale|ppp)[a-zA-Z0-9]*' | head -1)"
if [ -n "$dev" ]; then
  ip_v="$(ip -4 -o addr show dev "$dev" 2>/dev/null | awk 'NR==1{print $4}' | cut -d/ -f1)"
  [ -n "$ip_v" ] || ip_v="$(ip -6 -o addr show dev "$dev" scope global 2>/dev/null | awk 'NR==1{print $4}' | cut -d/ -f1)"
  case "$ip_v" in
    10.10.*) et=" · ${IP_ENV_LABEL:-HTB}" ;;
    *)       et='' ;;
  esac
  pill $'\uf023' "VPN ${ip_v}${et}" "$BG_PILL" "$GRN" "$FG"
else
  pill $'\uf023' "VPN" "$BG_PILL" "$MUT" "$MUT"
fi
