#!/bin/sh
set -eu
REPO="https://github.com/ESHAYAT102/horizon.git"
BRANCH="esh/offline-plus-visual-apis"
ROOT="${HOME}/code/horizon/horizon-offline-plus-visual-apis-src"
DEST="${HOME}/.local/opt/horizon-offline-visual"
mkdir -p "$ROOT" "$DEST"
if [ ! -d "$ROOT/.git" ]; then
  git clone --depth 1 --branch "$BRANCH" "$REPO" "$ROOT"
fi
cd "$ROOT"
cargo build --manifest-path launcher/Cargo.toml --release --locked
cargo build --profile fast -p horizon-client --features mods --locked
cp "target/release/horizon-launcher" "$DEST/horizon-launcher"
cp "target/fast/horizon-client" "$DEST/horizon-client"
cp -r ".local/horizon-client" "$DEST/resources" 2>/dev/null || true
echo "Installed launcher and API-enabled client to $DEST"
