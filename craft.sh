#!/usr/bin/env bash
# craft.sh

# Source the initialization module.
source "$(dirname "$(readlink -f "$0")")/lib/init.sh"

init::setup

main() {

    if [ $# -eq 0 ] || [[ "$1" =~ ^(-h|--help)$ ]]; then
        usage::general
    fi

    case "$1" in
    new)
        shift
        new_command::handle_new_command "$@"
        ;;
    *)
        echo "Error: Invalid option or command."
        echo "Use -h or --help for usage information."
        exit 1
        ;;
    esac
}

main "$@"
