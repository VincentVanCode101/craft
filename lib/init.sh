#!/usr/bin/env bash
# init.sh

init::setup() {

    set -Eeuo pipefail
    trap 'echo "Caught Ctrl+C! Exiting gracefully."; exit 1' SIGINT
    trap 'echo "Caught termination signal! Exiting gracefully."; exit 1' SIGTERM
    trap - ERR EXIT

    # Determine the canonical path of the script.
    # Since init.sh is sourced from the main script, $0 refers to the main script.
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
    readonly SCRIPT_DIR

    ROOT_SCRIPT="$(basename "$0")"
    readonly ROOT_SCRIPT

    DEBUG=true
    SUPER_DEBUG=false

    source "$SCRIPT_DIR/lib/utils.sh"
    source "$SCRIPT_DIR/lib/logger.sh"
    source "$SCRIPT_DIR/lib/usage.sh"
    source "$SCRIPT_DIR/lib/new_command.sh"

    logger::setup_colors

    utils::need_cmd "docker"
    utils::need_cmd "curl"
    utils::need_cmd "unzip"

    if [[ "${SUPER_DEBUG}" == "true" ]]; then
        set -x
        logger::debug "Super debug mode enabled"
    fi
}
