#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "Caught Ctrl+C! Exiting gracefully."; exit 1' SIGINT
trap 'echo "Caught termination signal! Exiting gracefully."; exit 1' SIGTERM
trap - ERR EXIT

# Determine the real (canonical) path of this script.
# When run via symlink, readlink -f "$0" returns the actual path of craft.sh in the repository.
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPT_DIR

ROOT_SCRIPT="$(basename "$0")"
readonly ROOT_SCRIPT

DEBUG=true

source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/usage.sh"
source "$SCRIPT_DIR/new_command.sh"
source "$SCRIPT_DIR/inspect_command.sh"

setup_colors

need_cmd "docker"
need_cmd "curl"
need_cmd "unzip"

main() {

    [ $# -eq 0 ] && usage
    [[ "$1" == "-h" || "$1" == "--help" ]] && usage

    case "$1" in
    new)
        shift
        handle_new_command "$@"
        ;;
    *)
        echo "Error: Invalid option or command."
        echo "Use -h or --help for usage information."
        exit 1
        ;;
    esac
}

main "$@"
