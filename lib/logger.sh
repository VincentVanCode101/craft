#!/usr/bin/env bash
# logger.sh

#-------------------------------------------------------------
# SETUP COLORS CONFIGURATION
#-------------------------------------------------------------
logger::setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        COLOR_RESET='\033[0m'
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[0;33m'
        CYAN='\033[0;36m'
        BLUE='\033[0;34m'
        BLACK='\033[0;30m'

    else
        COLOR_RESET=''
        RED=''
        GREEN=''
        YELLOW=''
        CYAN=''
        BLUE=''
        BLACK=''
    fi
}

#-------------------------------------------------------------
# LOG LEVEL NUMERIC MAPPING
#
#   ERROR = 1
#   WARN  = 2
#   INFO  = 3
#   NOTICE = 3
#   DEBUG = 4
#-------------------------------------------------------------
logger::get_level() {
    case "$1" in
    ERROR) echo 1 ;;
    WARN) echo 2 ;;
    INFO) echo 3 ;;
    NOTICE) echo 3 ;;
    DEBUG) echo 4 ;;
    *) echo 99 ;;
    esac
}

#-------------------------------------------------------------
# GLOBAL VERBOSITY CONFIGURATION
#
# Default is "normal" (LOG_LEVEL=3).
# SUPER_DEBUG remains false unless the -vv/--debug flag is used.
#-------------------------------------------------------------
: "${LOG_LEVEL:=3}"
SUPER_DEBUG=false

#-------------------------------------------------------------
# PARSE VERBOSITY FLAGS
#
# Accepts:
#   -q | --quiet      => quiet mode (only ERROR messages; LOG_LEVEL=1)
#   -v | --verbose    => verbose mode (debug mode; LOG_LEVEL=4)
#   -vv| --debug      => super-debug mode (debug mode plus shell tracing; LOG_LEVEL=4)
#
# Flags should be placed before the command.
#-------------------------------------------------------------
logger::parse_flags() {
    while [ "$#" -gt 0 ] && [[ "$1" =~ ^- ]]; do
        case "$1" in
        -q | --quiet)
            LOG_LEVEL=1
            shift
            ;;
        -vv | --debug)
            LOG_LEVEL=4
            SUPER_DEBUG=true
            shift
            ;;
        -v | --verbose)
            LOG_LEVEL=4
            shift
            ;;
        *)
            break
            ;;
        esac
    done

    if [[ "${SUPER_DEBUG}" == "true" ]]; then
        set -x
        logger::debug "Super debug mode enabled"
    fi
}

_now() {
    date +%F-%T
}

_log() {
    local level="$1"
    shift
    local message="$*"
    local color

    case "$level" in
    DEBUG) color="$CYAN" ;;
    INFO) color="$GREEN" ;;
    NOTICE) color="$BLACK" ;;
    WARN) color="$YELLOW" ;;
    ERROR) color="$RED" ;;
    *) color="$COLOR_RESET" ;;
    esac

    local log_message="${color}[$level]: $message${COLOR_RESET}"

    echo -e "$log_message" >&2
}

logger::debug() {
    if (($(logger::get_level "DEBUG") <= LOG_LEVEL)); then
        if ((LOG_LEVEL >= 4)); then
            local caller_info
            caller_info=$(caller 0)
            _log "DEBUG" "$* (caller: ${caller_info})"
        else
            _log "DEBUG" "$*"
        fi
    fi
}

logger::info() {
    if (($(logger::get_level "INFO") <= LOG_LEVEL)); then
        if ((LOG_LEVEL >= 4)); then
            local caller_info
            caller_info=$(caller 0)
            _log "INFO" "$* (caller: ${caller_info})"
        else
            _log "INFO" "$*"
        fi
    fi
}

logger::warn() {
    if (($(logger::get_level "WARN") <= LOG_LEVEL)); then
        if ((LOG_LEVEL >= 4)); then
            local caller_info
            caller_info=$(caller 0)
            _log "WARN" "$* (caller: ${caller_info})"
        else
            _log "WARN" "$*"
        fi
    fi
}
logger::notice() {
    if (($(logger::get_level "NOTICE") <= LOG_LEVEL)); then
        if ((LOG_LEVEL >= 4)); then
            local caller_info
            caller_info=$(caller 0)
            _log "NOTICE" "$* (caller: ${caller_info})"
        else
            _log "NOTICE" "$*"
        fi
    fi
}

logger::error() {
    if (($(logger::get_level "ERROR") <= LOG_LEVEL)); then
        if ((LOG_LEVEL >= 4)); then
            local caller_info
            caller_info=$(caller 0)
            _log "ERROR" "$* (caller: ${caller_info})"
        else
            _log "ERROR" "$*"
        fi
    fi
}

logger::print() {
    echo -e "$*" >&2
}
