# Horizon offline play via its built-in developer option

This is the supported alternative to the rejected PR #3116: the latest official Horizon
launcher already has a `dev-offline` developer option. This script just enables it.

No replacement binary, no build, no divergence from the official launcher; settings survive updates.

## Enable
```sh
curl -fsSL https://raw.githubusercontent.com/ESHAYAT102/horizon-offline-launcher/master/install.sh | sh
```

Then restart the official launcher, turn offline play on if required, and use
`HORIZON_NO_SELF_UPDATE` normally.
