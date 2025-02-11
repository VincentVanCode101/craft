#!/usr/bin/env bash
# craft.sh

# Source the initialization & update module.
source "$(dirname "$(readlink -f "$0")")/update.sh"

_setup() {

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

    # DEBUG=false
    # DEBUG=true
    # SUPER_DEBUG=false

    source "$SCRIPT_DIR/lib/utils.sh"
    source "$SCRIPT_DIR/lib/logger.sh"
    source "$SCRIPT_DIR/lib/usage.sh"
    source "$SCRIPT_DIR/lib/new_command.sh"

    logger::setup_colors

    utils::need_cmd "docker"
    utils::need_cmd "curl"
    utils::need_cmd "unzip"

}

main() {

    _setup

    update::check_for_updates "$@"

    if [ $# -eq 0 ] || [[ "$1" =~ ^(-h|--help)$ ]]; then
        usage::general
    fi

    case "$1" in
    new)
        shift
        new_command::handle_new_command "$@"
        ;;
    *)
        logger::error "Invalid option or command."
        echo "Use -h or --help for usage information."
        exit 1
        ;;
    esac
}

main "$@"
