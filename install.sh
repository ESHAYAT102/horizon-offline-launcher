#!/bin/sh
set -eu
REPO="https://github.com/ESHAYAT102/horizon.git"
BRANCH="fix/optional-microsoft-offline-play"
ROOT="${HOME}/code/horizon/horizon-offline-launcher-src"
DEST="${HOME}/.local/opt/horizon-offline"
mkdir -p "$ROOT" "$DEST"
if [ ! -d "$ROOT/.git" ]; then
  git clone --depth 1 --branch "$BRANCH" "$REPO" "$ROOT"
fi
cd "$ROOT"
cargo build --manifest-path launcher/Cargo.toml --release --locked
cp "target/release/horizon-launcher" "$DEST/horizon-launcher"
echo "Installed offline-capable launcher to $DEST/horizon-launcher"
