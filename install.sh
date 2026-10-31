#!/bin/sh
set -eu

# A source checkout can be supplied for local development; published installs
# use the reviewed PR commit below, not a moving branch or a binary download.
commit=efc875c37e174ac27cebb712c2449c0fdc17a484
launcher_home=${HORIZON_LAUNCHER_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/horizon-launcher}
versions="$launcher_home/versions"
base=${HORIZON_API_BASE_VERSION:-v0.2.97}
source=${HORIZON_API_SOURCE:-}
tag=local-visual-api-$(printf '%s' "$commit" | cut -c1-9)
dest="$versions/$tag"
settings="$launcher_home/settings.json"
test -f "$versions/$base/.installed" || { echo "Install official Horizon $base first (or set HORIZON_API_BASE_VERSION)." >&2; exit 1; }
test -d "$versions/$base/.local/horizon-client" || { echo "Base version has no prepared client resources." >&2; exit 1; }
test ! -e "$dest" || { echo "Already installed: $dest" >&2; exit 1; }
tmp=$(mktemp -d "${TMPDIR:-/tmp}/horizon-api-install.XXXXXX")
stage=$(mktemp -d "$versions/.${tag}.XXXXXX")
trap 'rm -rf -- "$tmp" "$stage"' EXIT HUP INT TERM
if [ -z "$source" ]; then
    git -C "$tmp" init -q source
    git -C "$tmp/source" remote add origin https://github.com/ESHAYAT102/horizon.git
    git -C "$tmp/source" fetch -q --depth 1 origin "$commit"
    git -C "$tmp/source" checkout -q --detach FETCH_HEAD
    source="$tmp/source"
fi
test "$(git -C "$source" rev-parse HEAD)" = "$commit" || { echo "Source must be PR commit $commit" >&2; exit 1; }
PATH="${HOME}/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin:$PATH" \
    "${CARGO:-cargo}" build --release --manifest-path "$source/Cargo.toml" -p horizon-client --bin horizon-client --bin horizon-ctl --target-dir "$tmp/target"
cp -a --reflink=auto "$versions/$base/." "$stage/"
cp "$tmp/target/release/horizon-client" "$stage/.horizon-client.new"
cp "$tmp/target/release/horizon-ctl" "$stage/.horizon-ctl.new"
mv "$stage/.horizon-client.new" "$stage/horizon-client"
mv "$stage/.horizon-ctl.new" "$stage/horizon-ctl"
mv "$stage" "$dest"
if [ "${HORIZON_API_SELECT:-1}" = 0 ]; then
    echo "Installed $tag alongside official versions; current launcher selection unchanged."
    exit 0
fi
python3 - "$settings" "$tag" <<'PY'
import json, os, pathlib, shutil, sys, tempfile, time
path = pathlib.Path(sys.argv[1]); tag = sys.argv[2]
data = json.loads(path.read_text()) if path.exists() else {}
data['dev_offline'] = True
data['selected'] = tag
path.parent.mkdir(parents=True, exist_ok=True)
if path.exists():
    shutil.copy2(path, path.with_name(path.name + '.backup.' + time.strftime('%Y%m%dT%H%M%SZ', time.gmtime())))
fd, tmp = tempfile.mkstemp(prefix='.settings-', dir=path.parent)
try:
    with os.fdopen(fd, 'w') as out: json.dump(data, out, indent=2); out.write('\n')
    os.replace(tmp, path)
finally:
    if os.path.exists(tmp): os.unlink(tmp)
PY
echo "Installed $tag alongside official versions; restart the official launcher."
