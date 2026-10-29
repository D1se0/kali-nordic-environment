# ~/.p10k.zsh — prompt powerlevel10k *Nord Frost* para kali-nordic
# Dos líneas, píldoras NORD, TARGET/VPN de la sesión como segmentos custom.
# Requiere JetBrainsMono Nerd Font y powerlevel10k en ~/.powerlevel10k.

typeset -g POWERLEVEL9K_MODE=nerdfont-v3
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

# ── Paleta Nord ──────────────────────────────────────────────────────────────
typeset -g NORD_BG0='#2E3440'
typeset -g NORD_BG1='#3B4252'
typeset -g NORD_BG2='#434C5E'
typeset -g NORD_FG='#D8DEE9'
typeset -g NORD_FROST='#88C0D0'
typeset -g NORD_FROST2='#81A1C1'
typeset -g NORD_RED='#BF616A'
typeset -g NORD_YELLOW='#EBCB8B'
typeset -g NORD_GREEN='#A3BE8C'
typeset -g NORD_VIOLET='#B48EAD'

# ── Segmentos izquierda ──────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    custom_nordic_shell     # calavera + usuario
    dir                     # ruta actual
    vcs                     # git status
    command_execution_time  # si dura > 2s
)

typeset -g POWERLEVEL9K_CUSTOM_NORDIC_SHELL="nordic_p10k_shell"

# ── Segmentos derecha ────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code != 0
    custom_nordic_target    # TARGET del hack
    custom_nordic_vpn       # VPN si está activa
    background_jobs
    custom_nordic_time      # reloj
)
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_TARGET="nordic_p10k_target"
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_VPN="nordic_p10k_vpn"
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_TIME="nordic_p10k_time"

function nordic_p10k_shell() {
    local g=$'\u2620'    # calavera ☠
    [ "$(id -u)" -eq 0 ] || g=$'\uf327'   # dragón Kali
    print -r -- "$g  ${USER:-$(whoami)}"
}
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_SHELL_BACKGROUND="$NORD_BG2"
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_SHELL_FOREGROUND="$NORD_FROST"

# ── DIR sobre Polar Night ────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_DIR_BACKGROUND="$NORD_BG2"
typeset -g POWERLEVEL9K_DIR_FOREGROUND="$NORD_FROST"
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND="$NORD_FROST2"
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_LENGTH=3

# ── GIT ──────────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_VCS_BACKGROUND="$NORD_BG1"
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND="$NORD_FROST2"
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND="$NORD_YELLOW"
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND="$NORD_YELLOW"

# ── Tiempo de ejecución (>2s) ────────────────────────────────────────────────
typeset -g POWERLEVEL9K_EXECUTION_TIME_THRESHOLD=2
typeset -g POWERLEVEL9K_EXECUTION_TIME_PRECISION=0
typeset -g POWERLEVEL9K_EXECUTION_TIME_BACKGROUND="$NORD_YELLOW"
typeset -g POWERLEVEL9K_EXECUTION_TIME_FOREGROUND="$NORD_BG0"

# ── Estado ✘ ─────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
typeset -g POWERLEVEL9K_STATUS_ERROR=true
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND="$NORD_RED"
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND="$NORD_BG0"
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND="$NORD_RED"
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND="$NORD_BG0"
typeset -g POWERLEVEL9K_STATUS_OK=false

# ── TARGET píldora (usa $TARGET/$TARGET_NAME del precmd del zshrc) ───────────
function nordic_p10k_target() {
    [ -n "$TARGET" ] || return 0
    local label="${TARGET_NAME:-$TARGET}"
    label="${label//%/}"
    print -r -- $'\uf05b'" $label"
}
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_TARGET_BACKGROUND="$NORD_BG2"
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_TARGET_FOREGROUND="$NORD_FROST"

# ── VPN píldora ──────────────────────────────────────────────────────────────
function nordic_p10k_vpn() {
    [ -n "$VPN_IP" ] || return 0
    print -r -- $'\uf023'" $VPN_IP"
}
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_VPN_BACKGROUND="$NORD_GREEN"
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_VPN_FOREGROUND="$NORD_BG0"

# ── Reloj ────────────────────────────────────────────────────────────────────
function nordic_p10k_time() {
    print -r -- $'\uf017'" $(date +%H:%M)"
}
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_TIME_BACKGROUND="$NORD_BG1"
typeset -g POWERLEVEL9K_CUSTOM_NORDIC_TIME_FOREGROUND="$NORD_FG"

# ── Jobs ─────────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_THRESHOLD=1
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND="$NORD_BG1"
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND="$NORD_YELLOW"

# ── Aire entre píldoras ──────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_ICON_PADDING=moderate
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PROMPT_CHAR='%F{#81A1C1}❯%f '
