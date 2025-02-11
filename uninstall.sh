#!/usr/bin/env bash
set -euo pipefail

#######################################
# Helper Functions
#######################################

_die() {
    echo "Error: $*" >&2
    exit 1
}

_log() {
    echo "$@"
}

#######################################
# Initialization Functions
#######################################

_get_repo_dir() {
    REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
}

_load_config() {
    local config_file="${REPO_DIR}/lib/config.sh"
    if [[ ! -f "${config_file}" ]]; then
        _die "Configuration file not found: ${config_file}"
    fi
    # shellcheck disable=SC1090
    source "${config_file}"
}

_set_binary() {
    if [[ -z "${BINARY_NAME:-}" ]]; then
        _die "BINARY_NAME is not defined in config.sh"
    fi
    BINARY="${REPO_DIR}/${BINARY_NAME}"
}

#######################################
# Uninstallation Functions
#######################################

_uninstall_from_directory() {
    local bin_dir="$1"
    local target="${bin_dir}/${BINARY_NAME}"

    if [[ ! -d "${bin_dir}" ]]; then
        _log "Directory ${bin_dir} does not exist. Skipping."
        return
    fi

    if [[ -L "$target" ]]; then
        local link_target
        link_target="$(readlink -f "$target")"
        if [[ "$link_target" == "$BINARY" ]]; then
            _log "Removing symlink: ${target} -> ${BINARY}"
            sudo rm -f "$target"
        else
            _log "Skipping ${target} because it does not point to the expected binary."
        fi
    elif [[ -e "$target" ]]; then
        _log "A file exists at ${target} but is not a symlink. Skipping removal."
    else
        _log "No file or symlink found at ${target}."
    fi
}

#######################################
# Main Function
#######################################

_main() {
    _get_repo_dir
    _load_config
    _set_binary

    # Define directories where the symlink may be installed.
    local BIN_DIRS=("/usr/local/bin" "/opt/homebrew/bin")
    for bin_dir in "${BIN_DIRS[@]}"; do
        _uninstall_from_directory "$bin_dir"
    done

    _log "uninstall.sh completed successfully."
}

# Execute the main function.
_main "$@"
