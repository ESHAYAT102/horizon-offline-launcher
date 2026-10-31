#!/bin/sh
set -eu
home=${HORIZON_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/horizon}
python3 - "$home" <<'PY'
import pathlib, sys, zipfile
home = pathlib.Path(sys.argv[1]); dest = home / 'horizon-native-mods/horizon_better_visuals.hnmod'
ores = home / 'resourcepacks/better-visuals.zip'
if dest.is_file():
    with zipfile.ZipFile(dest) as bundle:
        prefix = 'mixins/horizon_better_visuals/data/'
        shader_name = next((name for name in ('native-horizon_better_visuals', 'better-visuals')
            if prefix + 'shaderpacks/' + name + '/horizon-shaders.toml' in bundle.namelist()), None)
        shader = home / 'shaderpacks' / shader_name if shader_name else None
        if ores.is_file() and ores.read_bytes() == bundle.read(prefix + 'resourcepacks/better-visuals.zip'):
            ores.unlink()
        names = ('horizon-shaders.toml', 'sky.wgsl', 'glow.wgsl')
        if shader and shader.is_dir() and set(p.name for p in shader.iterdir()) == set(names) and all(
            (shader / name).read_bytes() == bundle.read(prefix + 'shaderpacks/' + shader_name + '/' + name) for name in names
        ):
            for name in names: (shader / name).unlink()
            shader.rmdir()
    dest.unlink()
for name, key in [('horizon-mods.txt', 'mod.horizon_better_visuals:true'), ('horizon-mods.txt', 'mod.horizon_better_visuals:false'), ('horizon-graphics.txt', 'pickedShaderPack:better-visuals'), ('horizon-graphics.txt', 'pickedShaderPack:native-horizon_better_visuals')]:
    path = home / name
    if path.exists():
        path.write_text(''.join(line for line in path.read_text().splitlines(keepends=True) if line.strip() != key))
options = home / 'options.txt'
if options.exists():
    import json
    lines = options.read_text().splitlines(keepends=True)
    for i, line in enumerate(lines):
        if line.startswith('resourcePacks:'):
            packs = json.loads(line.partition(':')[2]);packs = [p for p in packs if p != 'file/better-visuals.zip']
            lines[i] = 'resourcePacks:' + json.dumps(packs, separators=(',', ':')) + '\n'
            break
    options.write_text(''.join(lines))
print('Removed Better Visuals bundle and its shader selection. Existing native game versions and worlds remain.')
PY
