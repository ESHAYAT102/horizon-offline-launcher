#!/usr/bin/env python3
"""Package the reviewed native hook bundle without including build artifacts."""
import json
import io
from pathlib import Path
import tomllib
import zipfile

root = Path(__file__).resolve().parent
bundle = root / 'better_visuals'
mod = tomllib.loads((bundle / 'horizon-mixin.toml').read_text())
revision = mod['compatibility']['horizon_revision']
manifest = {
    'schema': 1, 'id': mod['mod']['id'], 'version': mod['mod']['version'],
    'game': '26.3', 'horizon': revision,
    'mixins': 'd9c83d7096b7ea5b83678da2efdfd6161f74997e',
}
out = root / 'horizon_better_visuals.hnmod'
files = {'horizon-native.json': (json.dumps(manifest, indent=2, sort_keys=True) + '\n').encode()}
ore_pack = io.BytesIO()
with zipfile.ZipFile(ore_pack, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
    archive.writestr('pack.mcmeta', json.dumps({'pack': {'min_format': 97, 'max_format': 97,
        'description': 'Better Visuals mineral-only ore masks (derived from prepared 26.3 textures)'}}))
    masks = sorted((root / 'data/ore-masks').glob('*.png'))
    assert len(masks) == 18, 'expected all eighteen ore masks'
    for path in masks:
        archive.writestr(f'assets/horizon_better_visuals/textures/emissive/{path.name}', path.read_bytes())
files[f'mixins/{mod["mod"]["id"]}/data/resourcepacks/better-visuals.zip'] = ore_pack.getvalue()
for path in sorted(bundle.glob('*')):
    if path.suffix in ('.rs', '.toml'):
        files[f'mixins/{mod["mod"]["id"]}/{path.name}'] = path.read_bytes()
for path in sorted((root / 'data').rglob('*')):
    if path.is_file() and 'ore-masks' not in path.parts:
        files[f'mixins/{mod["mod"]["id"]}/data/{path.relative_to(root / "data").as_posix()}'] = path.read_bytes()
with zipfile.ZipFile(out, 'w') as archive:
    for name, content in sorted(files.items()):
        info = zipfile.ZipInfo(name, (2026, 1, 1, 0, 0, 0))
        info.compress_type = zipfile.ZIP_DEFLATED
        info.external_attr = 0o100644 << 16
        archive.writestr(info, content)
print(out)
