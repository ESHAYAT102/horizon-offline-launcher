# Better Horizon launcher installer

The official Horizon launcher gained a `dev-offline` developer option. This
installer enables it and builds a Horizon client from the built-in visual API,
packaged as `local-better-horizon-api-*`. It also seeds Better Visuals (v0.1.3)
into the selected gamehome for normal Horizon gameplay.

## Install

Install official `v0.2.97` first, then:

```sh
curl -fsSL https://raw.githubusercontent.com/ESHAYAT102/better-horizon/master/install.sh | sh
```

Options:
- `HORIZON_HOME` / `XDG_DATA_HOME` controls gamehome (default ~/.local/share/horizon)
- `HORIZON_LAUNCHER_HOME` controls launcher home
- `HORIZON_API_SELECT=0` keeps current selection untouched
- `HORIZON_API_SOURCE=` uses a local checkout at the pinned commit
