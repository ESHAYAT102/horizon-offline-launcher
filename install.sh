#!/bin/sh
set -eu
python3 - "$HOME" <<'PY'
import json, sys
from pathlib import Path
home=Path(sys.argv[1])
settings=home/'.local/share/horizon-launcher/settings.json'
if settings.is_file():
    data=json.loads(settings.read_text())
else:
    data={}
data['dev_offline']=True
settings.parent.mkdir(parents=True, exist_ok=True)
settings.write_text(json.dumps(data, indent=2)+'\n')
print('Enabled dev_offline in', settings)
PY
echo "Done. Open Settings (seven clicks on the launcher version) then Play offline without a Microsoft account."
