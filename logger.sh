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
        ORANGE='\033[0;33m'   # Orange color
        BLUE='\033[0;34m'     # Blue color
        YELLOW='\033[0;33m'   # Yellow color
        PURPLE='\033[0;35m'   # Purple color
        CYAN='\033[0;36m'     # Cyan color
        YELLOW='\033[1;33m'   # Yellow color
    else
        # If colorization is disabled or unsupported, set variables to empty strings
        COLOR_RESET=''
        RED=''
        GREEN=''
        ORANGE=''
        BLUE=''
        YELLOW=''
        PURPLE=''
        CYAN=''
        YELLOW=''
    fi
}

log() {
    local level="$1"
    shift
    local message="$*"
    local color

    case "$level" in
    INFO) color="$GREEN" ;;
    WARN) color="$YELLOW" ;;
    ERROR) color="$RED" ;;
    *) color="$COLOR_RESET" ;;
    esac

    echo -e "${color}[$(now)] [$level]: $message${COLOR_RESET}"
}

info() { log "INFO" "$@"; }
warn() { log "WARN" "$@"; }
error() { log "ERROR" "$@"; }

#-------------------------------------------------------------
# PRINT MESSAGES
# This function prints messages to standard error with support
# for colorization if configured. It allows printing formatted
# messages with colors and variables.
#
# Usage examples:
#   msg "${RED}Read parameters:${COLOR_RESET}"
#   msg "- flag: ${flag}"
#   msg "- param: ${param}"
#   msg "- arguments: ${args[*]-}"
#
# Arguments:
#   $1: The message to be printed. It can include color codes
#       or variables.
#-------------------------------------------------------------
msg() {
    echo >&2 -e "${1-}"
}

#-------------------------------------------------------------
# GET DATE AND TIME
# This function retrieves the current date and time in the
# format "YYYY-MM-DD-HH:MM:SS".
#
# Usage:
#   now
#
# Returns:
#   The current date and time.
#-------------------------------------------------------------
now() {
    date +%F-%T
}
