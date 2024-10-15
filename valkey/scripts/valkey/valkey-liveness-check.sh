#!/bin/bash
#
# Liveness check script for Valkey containers

# Strict mode
set -euo pipefail

# Load functions used by the script
# shellcheck disable=SC1091
. /mnt/valkey/scripts/functions.sh
# shellcheck disable=SC1091
. /mnt/valkey/scripts/valkey-functions.sh

if PING_RESPONSE="$(valkey_cli_exec ping)"; then
    if [[ $PING_RESPONSE != PONG && $RESPONSE != *"LOADING"* && $RESPONSE != *"MASTERDOWN"* ]]; then
        log "Invalid response"
        echo "$PING_RESPONSE"
        exit 1
    fi
else
    log "Could not perform ping"
    exit 1
fi
