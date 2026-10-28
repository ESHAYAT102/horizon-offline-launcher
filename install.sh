#!/bin/sh
set -eu
ASSET_URL="https://github.com/ESHAYAT102/horizon-offline-launcher/releases/download/v0.2.0-optional-signin-2/horizon-launcher"
DIR="${HOME}/.local/opt/horizon"
BIN="${DIR}/horizon-launcher-offline"
BACKUP="${HOME}/.local/share/horizon-launcher/local-fix-backups/offline-signin-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$DIR" "$BACKUP"
tmp="$(mktemp)"
curl -fsSL "$ASSET_URL" -o "$tmp"
chmod +x "$tmp"
if [ -e "$BIN" ]; then cp "$BIN" "$BACKUP/horizon-launcher-offline"; fi
mv "$tmp" "$BIN"
# Point the desktop entry at the persistent side-by-side binary, so official
# launcher self-updates replace the original file instead of reverting this one.
desktop="${HOME}/.local/share/applications/horizon-launcher.desktop"
if [ -f "$desktop" ]; then
  cp "$desktop" "$BACKUP/horizon-launcher.desktop"
  sed -i "s#Exec=.*#Exec=${BIN}#" "$desktop" 2>/dev/null || true
fi
echo "Installed offline-capable launcher to $BIN"
echo "Future official updates replace ${DIR}/horizon-launcher, not this binary."
