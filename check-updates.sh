#!/bin/bash

OUTPUT_DIR="$HOME/HomeLab/Monitoring/node-exporter-textfile"
OUTPUT_FILE="$OUTPUT_DIR/apt_updates.prom"
TMP_FILE="${OUTPUT_FILE}.tmp"

mkdir -p "$OUTPUT_DIR"

PENDING_UPDATES=$(
    apt list --upgradable 2>/dev/null |
    tail -n +2 |
    grep -c .
)

if [ -f /var/run/reboot-required ]; then
    REBOOT_REQUIRED=1
else
    REBOOT_REQUIRED=0
fi

cat > "$TMP_FILE" <<EOF
# HELP homelab_pending_updates Number of pending APT package upgrades
# TYPE homelab_pending_updates gauge
homelab_pending_updates $PENDING_UPDATES

# HELP homelab_reboot_required Whether the HomeLab VM requires a reboot
# TYPE homelab_reboot_required gauge
homelab_reboot_required $REBOOT_REQUIRED
EOF

mv "$TMP_FILE" "$OUTPUT_FILE"
