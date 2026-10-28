#!/bin/sh
set -u
DEST="${HOME}/.local/opt/horizon/horizon-launcher"
echo "This only removes the patched binary; restore your official launcher from your backups if needed."
rm -f "$DEST"
echo "Removed $DEST"
