#!/usr/bin/env bash
# bundle.sh — genera nordic-installer.sh autocontenido (payload base64 + SHA-256).
set -Eeuo pipefail
cd "$(dirname "$0")/.."
OUT="nordic-installer.sh"
PAYLOAD="payload.tar.gz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

tar czf "$TMP/payload.tgz" bin config scripts install.sh uninstall.sh

expect="$(sha256sum "$TMP/payload.tgz" | awk '{print $1}')"
b64="$(base64 -w 76 "$TMP/payload.tgz")"

cat > "$OUT" <<HEADER
#!/usr/bin/env bash
# nordic-installer.sh — instalador autocontenido de kali-nordic
# Generado por scripts/bundle.sh. Sin credenciales (nunca embebe secretos).
set -Eeuo pipefail
PAYLOAD_SHA256_EXPECT='$expect'
PAYLOAD_b64=(
$(printf '%s\n' "$b64" | sed 's/^/  "/; s/$/"/')
)
HEADER

cat >> "$OUT" <<'BODY'
# extraer payload
RAW="$(mktemp)"; CLEAN="$(mktemp)"
printf '%s\n' "${PAYLOAD_b64[@]}" | sed 's/^  "//; s/"$//' > "$RAW"
got="$(sha256sum "$RAW" | awk '{print $1}')"
if [ "$got" != "$PAYLOAD_SHA256_EXPECT" ]; then
    echo "  ✘ checksum del payload no coincide (esperado $PAYLOAD_SHA256_EXPECT)"
    exit 1
fi
WORK="$(mktemp -d)"
tar xzf "$RAW" -C "$WORK/."
export NORDIC_WORK="$WORK"
cd "$NORDIC_WORK"

yes_or_skip() { [ "${1:-}" = "--yes" ]; }

# flags
DRYRUN=0 LITE=0 REBOOT=1
ARGS=("$@")
for a in "${ARGS[@]}"; do
    case "$a" in
        --dry-run) DRYRUN=1 ;;
        --lite) LITE=1 ;;
        --no-reboot) REBOOT=0 ;;
        --reboot) REBOOT=1 ;;
    esac
done
if [ "$DRYRUN" = "1" ]; then
    echo "  [dry-run] pre-flight ok: payload intacto, sin cambios aplicados."
    exit 0
fi
if [ "$LITE" = "1" ]; then
    export NORDIC_RES_H="${NORDIC_RES_H:-1080}"
fi

# iteración real del instalador modular (ya en el payload extraído)
bash install.sh

if [ "$REBOOT" = "1" ]; then
    printf '  ✨ instalado. ¿Reiniciar ahora? [y/N] '; read -r a || true
    [ "$a" = "y" ] && { echo '  • reiniciando'; sudo -n systemctl reboot; }
fi
BODY

chmod +x "$OUT"
echo "  ✔ generated $OUT (payload sha256: $expect)"
sha256sum "$OUT"
