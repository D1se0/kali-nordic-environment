#!/usr/bin/env bash
# layout.sh — disposición de ventanas (tiled/monocle/spiral/full/flotante)
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
lay=$(bspc query -T -d focused 2>/dev/null | jq -r '.layout // "long"' 2>/dev/null)
node=$(bspc query -T -n focused 2>/dev/null | jq -r '.state // empty' 2>/dev/null)
case "$node" in
    fullscreen) pill $'\uf065' "full" ;;
    floating)   pill $'\uf247' "flot" ;;
    *)
        case "$lay" in
            monocle) pill $'\uf135' "monocle" ;;
            spiral)  pill $'\uf07e' "spiral" ;;
            *)       pill $'\uf009' "tiled" ;;
        esac
        ;;
esac
