#!/usr/bin/env bash
# periodic-backup.sh — backup periódico de la config de la VM kali vía SSH.
# Cada $INTERVAL s: tar de ~/.config + zsh/p10k de kali y root → backups/ con
# timestamp. Guarda las últimas $KEEP copias de cada tipo. Elimina los tar
# temporales de la VM tras bajarlos.
set -u
export SSHPASS='kali'
H='192.168.5.178'
DEST="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$DEST"
cd "$DEST"
INTERVAL=600
KEEP=6

while true; do
    ts=$(date +%Y%m%d-%H%M%S)
    if timeout 90 sshpass -e ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "kali@$H" \
       'tar czf /tmp/nordic-backup-kali-config.tar.gz -C /home/kali .config/kali-nordic .config/kitty .config/rofi .config/polybar .config/bspwm .config/sxhkd .config/picom .config/nano .zshrc .p10k.zsh .cache/nordic 2>/dev/null; echo kali | sudo -S sh -c "tar czf /tmp/nordic-backup-root-config.tar.gz -C /root .zshrc .p10k.zsh .config 2>/dev/null; chmod 666 /tmp/nordic-backup-root-config.tar.gz"; chmod 666 /tmp/nordic-backup-kali-config.tar.gz 2>/dev/null' 2>/dev/null; then
        sshpass -e scp -o StrictHostKeyChecking=no "kali@$H:/tmp/nordic-backup-kali-config.tar.gz" "nordic-backup-kali-config-$ts.tar.gz" 2>/dev/null
        sshpass -e scp -o StrictHostKeyChecking=no "kali@$H:/tmp/nordic-backup-root-config.tar.gz" "nordic-backup-root-config-$ts.tar.gz" 2>/dev/null
    fi
    # rota: conserva las últimas $KEEP de cada tipo
    for kind in kali-config root-config; do
        ls -t "nordic-backup-$kind"-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)) | xargs -r rm -f --
    done
    sleep "$INTERVAL"
done
