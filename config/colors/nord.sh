#!/usr/bin/env bash
# nord.sh — Fuente única de la paleta Nord (kali-nordic)
# Origen: https://nordtheme.com/docs/colors-and-palettes
# NORDIC_NORD_SH is set by config/nord-palette.sh (system dir) so scripts find it anywhere.

# Polar Night
export NORD0='#2E3440' NORD1='#3B4252' NORD2='#434C5E' NORD3='#4C566A'
# Snow Storm
export NORD4='#D8DEE9' NORD5='#E5E9F0' NORD6='#ECEFF4'
# Frost
export NORD7='#8FBCBB' NORD8='#88C0D0' NORD9='#81A1C1' NORD10='#5E81AC'
# Aurora
export NORD11='#BF616A' NORD12='#D08770' NORD13='#EBCB8B' NORD14='#A3BE8C' NORD15='#B48EAD'

# Aliases semánticos (usados por los scripts de la barra, rofi, prompt...)
NORD_BG="${NORD0}"          # fondo principal
NORD_BG2="${NORD1}"         # píldoras/fondos suaves
NORD_FG="${NORD6}"          # texto principal
NORD_MUTED="${NORD3}"       # texto atenuado / elementos desactivados
NORD_ACCENT="${NORD8}"      # acento principal (frost)
NORD_WARN="${NORD13}"       # umbral medio (amarillo aurora)
NORD_CRIT="${NORD11}"       # umbral alto / errores (rojo aurora)
NORD_OK="${NORD14}"         # estado correcto (verde aurora)
export NORD_BG NORD_BG2 NORD_FG NORD_MUTED NORD_ACCENT NORD_WARN NORD_CRIT NORD_OK
