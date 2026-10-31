#!/bin/sh
set -eu
home=${HORIZON_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/horizon}
url=https://github.com/ESHAYAT102/horizon-better-visuals/releases/download/v0.1.3/horizon_better_visuals.hnmod
mkdir -p "$home/horizon-native-mods"
tmp=$(mktemp "$home/horizon-native-mods/.better-visuals.XXXXXX")
trap 'rm -f "$tmp"' EXIT HUP INT TERM
if [ -n "${BETTER_VISUALS_BUNDLE:-}" ]; then
    cp "$BETTER_VISUALS_BUNDLE" "$tmp"
else
    curl -fsSL "$url" -o "$tmp"
fi
python3 - "$home" "$tmp" <<'PY'
import json, pathlib, shutil, sys, zipfile
home, tmp = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
dest = home / 'horizon-native-mods/horizon_better_visuals.hnmod'
shader = home / 'shaderpacks/native-horizon_better_visuals'
ores = home / 'resourcepacks/better-visuals.zip'
prefix = 'mixins/horizon_better_visuals/data/shaderpacks/native-horizon_better_visuals/'
with zipfile.ZipFile(tmp) as z:
    manifest = json.loads(z.read('horizon-native.json'))
    if (manifest['id'], manifest['version'], manifest['horizon']) != ('horizon_better_visuals', '0.1.3', 'efc875c37e174ac27cebb712c2449c0fdc17a484'):
        raise SystemExit('Unexpected Better Visuals bundle')
    files = {name[len(prefix):]: z.read(name) for name in z.namelist() if name.startswith(prefix)}
    if set(files) != {'horizon-shaders.toml', 'sky.wgsl', 'glow.wgsl'}:
        raise SystemExit('Unexpected shader files')
    ore_data = z.read('mixins/horizon_better_visuals/data/resourcepacks/better-visuals.zip')
    from io import BytesIO
    with zipfile.ZipFile(BytesIO(ore_data)) as ores_zip:
        if len([n for n in ores_zip.namelist() if n.endswith('.png')]) != 18:
            raise SystemExit('Missing ore masks')
if shader.exists() or ores.exists() or dest.exists():
    raise SystemExit('Better Visuals is already installed; keep the existing files until you choose to replace them')
shader.mkdir(parents=True)
ores.parent.mkdir(parents=True, exist_ok=True)
for name, content in files.items():
    (shader / name).write_bytes(content)
shutil.copy2(tmp, dest)
ores.write_bytes(ore_data)
mods = home / 'horizon-mods.txt'
if not mods.exists() or not any(line.startswith('mod.horizon_better_visuals:') for line in mods.read_text().splitlines()):
    with mods.open('a') as out:
        out.write('mod.horizon_better_visuals:true\n')
graphics = home / 'horizon-graphics.txt'
text = graphics.read_text() if graphics.exists() else ''
if 'pickedShaderPack:' not in text or 'pickedShaderPack:\n' in text:
    graphics.write_text(text.replace('pickedShaderPack:\n', 'pickedShaderPack:native-horizon_better_visuals\n') if 'pickedShaderPack:' in text else text + 'pickedShaderPack:native-horizon_better_visuals\n')
else:
    print('Kept your selected shader pack. Choose Better Visuals in Horizon Settings to enable its glow.')
options = home / 'options.txt'
text = options.read_text() if options.exists() else ''
lines = text.splitlines(keepends=True)
for i, line in enumerate(lines):
    if line.startswith('resourcePacks:'):
        packs = json.loads(line.partition(':')[2])
        if 'file/better-visuals.zip' not in packs: packs.append('file/better-visuals.zip')
        lines[i] = 'resourcePacks:' + json.dumps(packs, separators=(',', ':')) + '\n'
        break
else:
    lines.append('resourcePacks:["file/better-visuals.zip"]\n')
options.write_text(''.join(lines))
print(f'Installed {dest}. Review its Rust source and use Native mods → Build to compile trusted native code.')
PY
