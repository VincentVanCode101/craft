#!/usr/bin/env bash
# utils.sh

source "$(dirname "${BASH_SOURCE[0]}")/languages.sh"

#-------------------------------------------------------------
# FINISH EXECUTION
# This function prints an error message and exits the script
# with a specified exit status.
#
# Usage:
#   die "Error message" [exit_status]
#
# Arguments:
#   $1: The error message to be printed.
#   $2: (Optional) The exit status. Default is 1.
#-------------------------------------------------------------
_die() {
    local msg=$1
    local code=${2:-1} # default exit status 1
    error "$msg"
    exit "$code"
}

#-------------------------------------------------------------
# NEED COMMAND
# This function checks if a specific command is available in
# the system. If the command is not found, it prints an error
# message and terminates the script.
#
# Usage example:
#   need_cmd "gcc"
#
# Arguments:
#   $1: The command to be checked for availability.
#-------------------------------------------------------------
utils::need_cmd() {
    if ! _check_cmd "$1"; then
        _die "Error: '$1' command not found but needed"
    fi
}

#-------------------------------------------------------------
# CHECK COMMAND
# This function checks if a specific command is available in
# the system. It returns success if the command is found,
# otherwise it returns failure.
#
# Usage example:
#   check_cmd "gcc"
#
# Arguments:
#   $1: The command to be checked for availability.
#-------------------------------------------------------------
_check_cmd() {
    command -v "$1" >/dev/null 2>&1
}
