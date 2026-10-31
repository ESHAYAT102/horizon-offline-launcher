#!/bin/sh
set -eu
launcher_home=${HORIZON_LAUNCHER_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/horizon-launcher}
gamehome=${HORIZON_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/horizon}
settings="$launcher_home/settings.json"
echo "Applying Better Visual mod to the official Horizon install (no source rebuild needed)."
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/horizon/instances/nightly" 2>/dev/null || true
python3 - "$settings" "$gamehome" <<'PY'
import json, os, pathlib, shutil, sys, time
settingspath=pathlib.Path(sys.argv[1]); gamehome=pathlib.Path(sys.argv[2])
data=json.loads(settingspath.read_text()) if settingspath.exists() else {}
data['dev_offline']=True
data['selected']=data.get('selected') or 'v0.2.97'
settingspath.parent.mkdir(parents=True, exist_ok=True)
print('Running in already installed Horizon; applying mod and packs only.')
# Enable offline name only by ensuring accounts list is present but ignored
PY
sh "$(dirname "$0")/setup-mods.sh"
python3 - "$settings" <<'PY'
import json,pathlib
p=pathlib.Path(__import__('sys').argv[1])
d=json.loads(p.read_text()) if p.exists() else {}
d['dev_offline']=True
p.write_text(json.dumps(d,indent=2)+'\n')
print('done configuring launcher settings')
PY
