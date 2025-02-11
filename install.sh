#!/usr/bin/env bash
set -euo pipefail

#######################################
# Helper Functions
#######################################

# _die: Print an error message to stderr and exit.
_die() {
    echo "Error: $*" >&2
    exit 1
}

#######################################
# Initialization Functions
#######################################

# _get_repo_dir: Set REPO_DIR to the directory of this script.
_get_repo_dir() {
    REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
}

# _load_config: Load configuration from lib/config.sh.
_load_config() {
    local config_file="${REPO_DIR}/lib/config.sh"
    if [[ ! -f "${config_file}" ]]; then
        _die "Configuration file not found: ${config_file}"
    fi

    # shellcheck disable=SC1090
    source "${config_file}"
}

# _set_binary: Build the full path to the repository binary.
_set_binary() {
    if [[ -z "${BINARY_NAME:-}" ]]; then
        _die "BINARY_NAME is not defined in config.sh"
    fi
    BINARY="${REPO_DIR}/${BINARY_NAME}"
}

#######################################
# Target Directory Functions
#######################################

# _find_target_dir: Check common directories for a valid target directory.
_find_target_dir() {
    for dir in "/usr/local/bin" "/opt/homebrew/bin"; do
        if [[ -d "$dir" ]]; then
            TARGET_DIR="$dir"
            return
        fi
    done
    _die "Neither /usr/local/bin nor /opt/homebrew/bin exist. Please create one and add it to your PATH."
}

# _set_target: Build the full target path for the symlink.
_set_target() {
    TARGET="${TARGET_DIR}/${BINARY_NAME}"
}

#######################################
# Symlink Functions
#######################################

# _create_symlink: Remove an existing symlink/file at TARGET, create a new symlink,
# and verify that it points to the expected binary.
_create_symlink() {
    echo "Creating symlink: ${TARGET} -> ${BINARY}"
    if [[ -e "$TARGET" || -L "$TARGET" ]]; then
        echo "Removing existing file or symlink at ${TARGET}"
        sudo rm -f "$TARGET"
    fi

    sudo ln -s "$BINARY" "$TARGET"

    # Verify that the symlink points to the expected binary.
    local resolved_path
    resolved_path="$(readlink -f "$TARGET")"
    if [[ "$resolved_path" != "$BINARY" ]]; then
        _die "The symlink does not point to the expected file.
Expected: ${BINARY}
Got:      ${resolved_path}"
    fi

    echo "Symlink created successfully. When executing ${TARGET}, the repository binary is used."
}

#######################################
# Main Function
#######################################

_main() {
    _get_repo_dir
    _load_config
    _set_binary
    _find_target_dir
    _set_target
    _create_symlink
    echo "install.sh completed successfully."
}

# Execute the main function.
_main "$@"
