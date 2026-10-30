# Horizon offline play via its built-in developer option

The official Horizon launcher has a `dev-offline` developer option. The installer
enables it and builds a game client from the pinned source of [mod API PR #2888](https://github.com/horizon-rust/horizon/pull/2888).

It installs the client as a **separate local version**, selects it and keeps the
stock launcher, official versions, worlds and other mods unchanged. It copies
an existing official version's prepared game resources before replacing only
the local version's game and control binaries. Updating the official launcher
does not replace the local version. This is a source build, not an official
Horizon release.

## Install
Install the official `v0.2.97` game version and its Minecraft resources first.
You need git, Python 3, Rust and Horizon's Linux build dependencies. The build
can take several minutes and needs several GB of free space.

```sh
curl -fsSL https://raw.githubusercontent.com/ESHAYAT102/horizon-offline-launcher/master/install.sh | sh
```

Restart the official launcher and select the new `local-visual-api-*` version
if it was not selected automatically. Keep the official version installed.
Set `HORIZON_API_BASE_VERSION` to a different *installed* compatible version
if `v0.2.97` is unavailable. The installer makes a timestamped backup of
`settings.json` before changing `selected` and `dev_offline`. It refuses to
overwrite an existing local version; uninstalling does not remove versions.

For local source validation, `HORIZON_API_SOURCE` accepts a checkout at the
pinned PR commit. `HORIZON_LAUNCHER_HOME` points at a scratch launcher home for
testing. Neither option alters official game binaries.
