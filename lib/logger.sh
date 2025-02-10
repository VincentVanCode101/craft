#!/usr/bin/env bash
# logger.sh

#-------------------------------------------------------------
# SETUP COLORS CONFIGURATION
# This function configures color output for the script if the
# terminal supports it and colorization is enabled.
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

#-------------------------------------------------------------
# INTERNAL LOG FUNCTION
# This function prints the log message with the appropriate color,
# timestamp, and log level.
#-------------------------------------------------------------
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

#-------------------------------------------------------------
# LOGGING FUNCTIONS
# These functions log messages at different levels.
#-------------------------------------------------------------
logger::debug() {
    if [[ "${DEBUG}" == "true" ]]; then
        local caller_info
        caller_info=$(caller 0)
        local msg
        msg="$* (caller: ${caller_info})"
        _log "DEBUG" "$msg"
    fi
}

logger::info() {
    if [[ "${DEBUG}" == "true" ]]; then
        local caller_info
        caller_info=$(caller 0)
        local msg
        msg="$* (caller: ${caller_info})"
        _log "INFO" "$msg"
    else
        _log "INFO" "$*"
    fi
}

logger::warn() {
    if [[ "${DEBUG}" == "true" ]]; then
        local caller_info
        caller_info=$(caller 0)
        local msg
        msg="$* (caller: ${caller_info})"
        _log "WARN" "$msg"
    else
        _log "WARN" "$*"
    fi
}

logger::error() {
    if [[ "${DEBUG}" == "true" ]]; then
        local caller_info
        caller_info=$(caller 0)
        local msg
        msg="$* (caller: ${caller_info})"
        _log "ERROR" "$msg"
    else
        _log "ERROR" "$*"
    fi
}

_now() {
    date +%F-%T
}
