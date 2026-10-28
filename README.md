# Horizon without mandatory Microsoft login

A persistent, non-blocking optional-Microsoft-login launcher. The script installs a
second launcher binary beside the official one, then points the desktop entry at it.
Official Horizon self-updates replace `horizon-launcher`, not `horizon-launcher-offline`.

## Install
```sh
curl -fsSL https://raw.githubusercontent.com/ESHAYAT102/horizon-offline-launcher/master/install.sh | sh
```

## Restore official
Run the official launcher from `~/.local/opt/horizon/horizon-launcher` or remove the side-by-side binary and re-point the desktop entry.
