#!/bin/sh
set -eu
launcher_home=${HORIZON_LAUNCHER_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/horizon-launcher}
echo "Local API clients are separate versions under $launcher_home/versions/local-visual-api-*"
echo 'Select an official version in the launcher before removing an API client. This script does not remove game versions, worlds, mods or the stock launcher.'
