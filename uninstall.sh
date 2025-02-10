#!/usr/bin/env bash
# uninstall.sh
set -euo pipefail

#######################################
# Variables and Initialization
#######################################

# Determine the repository directory based on the script's location.
REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Ensure config.sh exists before sourcing it.
CONFIG_FILE="${REPO_DIR}/lib/config.sh"
if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Error: ${CONFIG_FILE} not found." >&2
    exit 1
fi
source "${CONFIG_FILE}"

# Construct the full path to the repository binary.
CRAFT_BINARY="${REPO_DIR}/${CRAFT_BINARY_NAME}"

# Define the directories where symlinks might have been installed.
BIN_DIRS=("/usr/local/bin" "/opt/homebrew/bin")

#######################################
# Functions
#######################################

# log: Print a message to stdout.
log() {
    echo "$@"
}

# warn: Print a warning message to stderr.
warn() {
    echo "Warning: $@" >&2
}

# uninstall_from_directory: Remove the symlink from the given bin directory if it points to the expected binary.
# Arguments:
#   $1 - The bin directory to check.
uninstall_from_directory() {
    local bin_dir="$1"
    local target="${bin_dir}/${CRAFT_BINARY_NAME}"

    if [[ ! -d "${bin_dir}" ]]; then
        log "Directory ${bin_dir} does not exist. Skipping."
        return
    fi

    if [[ -L "$target" ]]; then
        local link_target
        link_target="$(readlink -f "$target")"
        if [[ "$link_target" == "$CRAFT_BINARY" ]]; then
            log "Removing symlink: ${target} -> ${CRAFT_BINARY}"
            sudo rm -f "$target"
        else
            log "Skipping ${target} because it does not point to the expected binary."
        fi
    elif [[ -e "$target" ]]; then
        log "A file exists at ${target} but is not a symlink. Skipping removal."
    else
        log "No file or symlink found at ${target}."
    fi
}

#######################################
# Main Script Execution
#######################################

for bin_dir in "${BIN_DIRS[@]}"; do
    uninstall_from_directory "$bin_dir"
done

log "uninstall.sh completed successfully."
