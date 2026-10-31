#!/bin/sh
set -eu
commit=efc875c37e174ac27cebb712c2449c0fdc17a484
version=v0.1.3
gamehome=${HORIZON_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/horizon}
python3 - "$commit" "$version" "$gamehome" <<'PYEOF'
import json, pathlib, shutil, sys, tempfile, time, zipfile, urllib.request, os
version=sys.argv[2]; gamehome=pathlib.Path(sys.argv[3])
bundle=gamehome/'.better-visuals-bundle.hnmod'
import os
bundled=os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),'better-visuals','native','horizon_better_visuals.hnmod')
url='file://'+bundled if os.path.exists(bundled) else f'https://github.com/ESHAYAT102/horizon-better-visuals/releases/download/{version}/horizon_better_visuals.hnmod'
try:
    if url.startswith('file://'):
        bundle.write_bytes(open(url[7:],'rb').read())
    else:
        with urllib.request.urlopen(url) as r:
            bundle.write_bytes(r.read())
except Exception as e:
    raise SystemExit(f'cannot download Better Visuals: {e}')
dest=gamehome/'horizon-native-mods/horizon_better_visuals.hnmod'
dest.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(bundle,dest)
(z := zipfile.ZipFile(str(bundle)))
(gamehome/'resourcepacks').mkdir(parents=True,exist_ok=True)
(gamehome/'resourcepacks/better-visuals.zip').write_bytes(z.read('mixins/horizon_better_visuals/data/resourcepacks/better-visuals.zip'))
prefix='mixins/horizon_better_visuals/data/shaderpacks/native-horizon_better_visuals/'
shaderhome=gamehome/'shaderpacks'/'native-horizon_better_visuals'
shaderhome.mkdir(parents=True,exist_ok=True)
for name in z.namelist():
    if name.startswith(prefix):
        rel=name[len(prefix):]
        if not rel: continue
        p=shaderhome/rel
        p.parent.mkdir(parents=True,exist_ok=True)
        p.write_bytes(z.read(name))
modslist=gamehome/'horizon-mods.txt'
lines=modslist.read_text().splitlines(keepends=True) if modslist.exists() else []
if not any(line.strip()=='mod.horizon_better_visuals:true' for line in lines):
    lines.append('mod.horizon_better_visuals:true\n')
    modslist.write_text(''.join(lines))
graphics=gamehome/'horizon-graphics.txt'
gtext=graphics.read_text() if graphics.exists() else ''
if 'pickedShaderPack:' not in gtext or 'pickedShaderPack:\n' in gtext:
    gtext=gtext.replace('pickedShaderPack:\n','pickedShaderPack:native-horizon_better_visuals\n') if 'pickedShaderPack:' in gtext else gtext+'pickedShaderPack:native-horizon_better_visuals\n'
    graphics.write_text(gtext)
options=gamehome/'options.txt'
otext=options.read_text() if options.exists() else ''
lines2=otext.splitlines(keepends=True)
changed=False
import json
for i,l in enumerate(lines2):
    if l.startswith('resourcePacks:'):
        packs=json.loads(l.partition(':')[2]) if ':' in l else []
        if 'file/better-visuals.zip' not in packs: packs.append('file/better-visuals.zip')
        lines2[i]='resourcePacks:'+json.dumps(packs,separators=(',',':'))+'\n'
        changed=True;break
if not changed:
    lines2.append('resourcePacks:["file/better-visuals.zip"]\n')
options.write_text(''.join(lines2))
print('Better Visuals installed into', gamehome)
PYEOF
