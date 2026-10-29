# lib.sh — tokens de diseño de la barra kali-nordic
# Sistema SUAVE: píldoras SIN fondo de color; identidad por color de
# icono/texto. La píldora activa sí mantiene un fondo translúcido sutil.
# Iconos GRANDES (T5 = font-4) separados del texto con aire (O7).

export PATH="$HOME/.local/bin:$PATH"

BG_ACT='#5588C0D0'     # caps translúcidos Frost del workspace activo (sin fondo azulado)
BG_TARGET='#55BF616A'  # target activo · Aurora-red translúcido sutil

# SEP — separador vertical fino entre secciones (“Kali | IP | IP | VPN”)
SEP='%{O9}%{F#667083}%{T1}|%{F-}%{O9}'

FG='#ECEFF4'           # Snow Storm brillante
FG_LOCAL='#D8DEE9'
IC='#88C0D0'           # icono Frost
IC_BRIGHT='#8FBCBB'
MUT='#8DA1BE'          # atenuado legible
MUT_DIM='#667083'      # glifo atenuado de escritorio vacío
RED='#BF616A'
RED_SOFT='#D8AEB4'     # rojo atenuado sobre translúcido
GRN='#A3BE8C'
YEL='#EBCB8B'

# caps de extremos redondeados (powerline semicircular U+E0B6 / U+E0B4)
ROUNDED_L=$'\ue0b6'
ROUNDED_R=$'\ue0b4'

# caps_round <bg> — dibuja el par de caps en el color de fondo dado
caps_round() {
    printf '%%{T4}%%{F%s}%s%%{F-}%%{T1}%%{T4}%%{F%s}%s%%{F-}%%{T1}' "$1" "$ROUNDED_L" "$1" "$ROUNDED_R"
}

# chunk <icono> <texto> [icon-color] [text-color] — icono GRANDE (T5) con aire
# nítido (O10) antes del texto (en font-0), y espacio final entre pares.
chunk() {
    local ic="$1" tx="${2:-}" icc="${3:-$IC}" fgc="${4:-$FG}"
    if [ -n "$tx" ]; then
        printf '%%{T5}%%{F%s}%s%%{F-}%%{O10}%%{T1}%%{F%s}%s %%{F-}' "$icc" "$ic" "$fgc" "$tx"
    else
        printf '%%{T5}%%{F%s}%s%%{F-}%%{T1}' "$icc" "$ic"
    fi
}

# pill <icono> <texto> — píldora activa (única con fondo sutil, caps redondeados)
pill() {
    local ic="$1" tx="${2:-}"
    printf '%%{T4}%%{F%s}%s%%{F-}%%{T1}' "$BG_ACT" "$ROUNDED_L"
    printf '%%{B%s}%%{T5}%%{F%s}%s%%{F-}%%{O10}%%{T1}%%{F%s}%s %%{F-}%%{B-}' "$BG_ACT" "$IC" "$ic" "$FG" "$tx"
    printf '%%{T4}%%{F%s}%s%%{F-}%%{T1}' "$BG_ACT" "$ROUNDED_R"
}
