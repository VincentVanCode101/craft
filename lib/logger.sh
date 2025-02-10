#!/usr/bin/env bash
# logger.sh

#-------------------------------------------------------------
# SETUP COLORS CONFIGURATION
# This function configures color output for the script if the
# terminal supports it and colorization is enabled. It assigns
# ANSI color codes to variables for use in printing colored
# output messages.
#
# Usage:
#   This function should be called at the beginning of the
#   script to set up color configurations.
#-------------------------------------------------------------
logger::setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        COLOR_RESET='\033[0m' # Reset text format
        RED='\033[0;31m'      # Red color
        GREEN='\033[0;32m'    # Green color
        YELLOW='\033[0;33m'   # Yellow color
        CYAN='\033[0;36m'     # Cyan color
    else
        # If colorization is disabled or unsupported, set variables to empty strings
        COLOR_RESET=''
        RED=''
        GREEN=''
        YELLOW=''
        CYAN=''
    fi
}

_log() {
    local level="$1"
    shift
    local message="$*"
    local color

    case "$level" in
    DEBUG) color="$CYAN" ;;
    INFO) color="$GREEN" ;;
    WARN) color="$YELLOW" ;;
    ERROR) color="$RED" ;;
    *) color="$COLOR_RESET" ;;
    esac

    echo -e "${color}[$(_now)] [$level]: $message${COLOR_RESET}"
}

logger::debug() {
    if [[ "${DEBUG}" == "true" ]]; then
        local caller_info
        caller_info=$(caller 0)
        _log "DEBUG" "$@ (caller: ${caller_info})"
    fi
}

logger::info() {
    if [[ "${DEBUG}" == "true" ]]; then
        local caller_info
        caller_info=$(caller 0)
        _log "INFO" "$@ (caller: ${caller_info})"
    else
        _log "INFO" "$@"
    fi
}

logger::warn() {
    if [[ "${DEBUG}" == "true" ]]; then
        local caller_info
        caller_info=$(caller 0)
        _log "WARN" "$@ (caller: ${caller_info})"
    else
        _log "WARN" "$@"
    fi
}

logger::error() {
    if [[ "${DEBUG}" == "true" ]]; then
        local caller_info
        caller_info=$(caller 0)
        _log "ERROR" "$@ (caller: ${caller_info})"
    else
        _log "ERROR" "$@"
    fi
}

_now() {
    date +%F-%T
}
