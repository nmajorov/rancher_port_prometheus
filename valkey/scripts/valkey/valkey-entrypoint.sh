#!/bin/bash
#
# Entrypoint for Valkey container images

# Strict mode
set -euo pipefail

# Load functions used by the script
# shellcheck disable=SC1091
. /mnt/valkey/scripts/functions.sh
# shellcheck disable=SC1091
. /mnt/valkey/scripts/valkey-functions.sh

log "Starting Valkey"
valkey_conf | exec valkey-server "$@" -
