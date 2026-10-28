#!/bin/sh
set -eu
ASSET_URL="https://github.com/ESHAYAT102/horizon-offline-launcher/releases/download/v0.2.0-optional-signin-1/horizon-launcher"
DEST="${HOME}/.local/opt/horizon/horizon-launcher"
BACKUP="${HOME}/.local/share/horizon-launcher/local-fix-backups/offline-signin-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$(dirname "$DEST")" "$BACKUP"
tmp="$(mktemp)"
curl -fsSL "$ASSET_URL" -o "$tmp"
chmod +x "$tmp"
if [ -e "$DEST" ]; then cp "$DEST" "$BACKUP/horizon-launcher"; fi
mv "$tmp" "$DEST"
echo "Installed offline-capable launcher to $DEST (backup: $BACKUP)"
