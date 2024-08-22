#!/bin/bash
#
# Common functions for Valkey

# @description Print Valkey configuration used to start the server.
#
# @stdout Valkey configuration.
valkey_conf() {
    if [[ -n ${_VALKEY_PASSWORD:-} ]]; then
        # Authentication to the node
        printf 'requirepass "%s"\n' "${_VALKEY_PASSWORD//\"/\\\"}"
        printf 'masterauth "%s"\n' "${_VALKEY_PASSWORD//\"/\\\"}"
    fi
    # Replication configuration
    # Should not be enabled for Valkey Cluster mode (_VALKEY_MASTER_HOST unset)
    if [[ -n ${_VALKEY_MASTER_HOST:-} &&
        $_VALKEY_MASTER_HOST != "$HOSTNAME.$_FQDN_CLUSTER_PREFIX" ]]; then
        echo "replicaof $_VALKEY_MASTER_HOST $_VALKEY_PORT"
    fi
    # Valkey Cluster configuration
    if [[ -n ${_VALKEY_CLUSTER_NODES:-} ]]; then
        echo "cluster-announce-ip $(wait_for_hostname_resolution "$HOSTNAME")"
        echo "cluster-announce-hostname $HOSTNAME.$_FQDN_CLUSTER_PREFIX"
        echo "cluster-announce-human-nodename $HOSTNAME"
    fi
    if [[ -e ${_VALKEY_CONF_FILE} ]]; then
        cat "$_VALKEY_CONF_FILE"
    fi
}

# @description Get the value of a Valiey configuration entry.
#
# @arg $1 The configuration entry name.
#
# @stdout Value of the configuration entry.
valkey_conf_get() {
    local -r entry_name="$1"
    local last_entry=""
    local found=false
    while read -r line; do
        if [[ $line == "$entry_name "* ]]; then
            last_entry="${line##"$entry_name "}"
            found=true
        fi
    done < <(valkey_conf)
    if "$found"; then
        # Only print the string if it is not empty
        if [[ -n $last_entry ]]; then
            # If the string is quoted, remove the quotes
            if [[ $last_entry =~ ^\"([^\"]*)\"$ ]]; then
                echo "${BASH_REMATCH[1]}"
            elif [[ $last_entry =~ ^\'([^\']*)\'$ ]]; then
                echo "${BASH_REMATCH[1]}"
            else
                echo "$last_entry"
            fi
        fi
    else
        return 1
    fi
}

# @description Execute a Valkey command using the Valkey CLI tool.
#
# @stdout Output of the Valkey CLI tool.
valkey_cli_exec() {
    valkey_cli_args=(valkey-cli -h localhost)
    # Check if TLS is enabled
    if ! valkey_conf_get tls-port >/dev/null; then
        valkey_cli_args+=(-p "$(valkey_conf_get port)")
    else
        valkey_cli_args+=(
            --tls -p "$(valkey_conf_get tls-port)"
            --cacert "$(valkey_conf_get tls-ca-cert-file)"
        )
        if [[ "$(valkey_conf_get tls-auth-clients || true)" == yes ]]; then
            valkey_cli_args+=(
                --cert "$(valkey_conf_get tls-cert-file)"
                --key "$(valkey_conf_get tls-key-file)"
            )
        fi
    fi
    "${valkey_cli_args[@]}" "$@"
}
