#!/usr/bin/env bash

# FAULT CONFIGURATION
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# CONSTANTS
readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __file_name="$(basename "$__file")"
readonly __base="$(basename "${__file}" .sh)"

source "$__dir/languages.sh"

readonly _MSG_NEW_ARGUMENT_REQUIRED="Missing argument: new"

pullFilesToTemplateFolder() {
    readonly __templates = templates
    readonly __templatesZip = templates.zip

    curl -L -o $__templatesZip $1

    unzip $__templatesZip $__templates

    rm $__templatesZip
}

#-------------------------------------------------------------
# DISPLAY HOW TO USE THE SCRIPT
# This function displays usage information for the script,
# including a summary of available options and their descriptions.
#
# Usage:
#   This function should be called to display usage
#   information for the script.
#
# Example usage:
#   usage
#-------------------------------------------------------------
usage() {
    echo "Usage: ${ROOT_SCRIPT} [OPTIONS] COMMAND [ARG]"
    echo
    echo "Options:"
    echo "  -h, --help             Display this help message."
    echo
    echo "Commands:"
    echo "  new <language>         Create a new project for the specified language."
    echo "  inspect                View supported languages.('${ROOT_SCRIPT} inspect')"
    echo
    echo "Flags for the 'new' command:"
    echo "  --dependencies=<list>  Comma-separated list of dependencies to include."
    echo
    echo "  --level=<build|prod>   Specify the project level. Allowed values are 'build' or 'prod'."
    echo "                         This flag controls the complexity of the generated setup:"
    echo "                           * 'build'  may include additional tools (e.g., pre-commit hooks)"
    echo "                                      for a robust development experience."
    echo "                           * 'prod'   generates production-ready features (e.g., multi-stage"
    echo "                                      Dockerfile builds) for deployment."
    echo "                         (If omitted, the default level 'dev' is assumed but not mentioned."
    echo "                         ...dev will just be a basic language-runtime container)"
    echo
    echo "  --path=<folder>        Specify the directory where the project should be created."
    echo "                         If not provided, a folder will be created using the naming"
    echo "                         convention: craft-<language>[-<level>][-<dependencies>]."
    echo "                         For example, a Java project with prod level and dependencies"
    echo "                         mariadb and ncurs ("
    echo "                           craft new java --dependencies=mariadb,ncurs --level=prod"
    echo "                         ) will be created in a folder named:"
    echo "                           craft-java-prod-mariadb-ncurs"
    echo
    echo "Additional Flags for the 'new' command:"
    echo "  --show-dependencies    Show supported dependencies and allowed levels for the specified language."
    echo "                         e.g.: ${ROOT_SCRIPT} new java --show-dependencies"
    echo
    echo "Usage Examples:"
    echo "  ${ROOT_SCRIPT} -h"
    echo "  ${ROOT_SCRIPT} new go"
    echo "  ${ROOT_SCRIPT} new java --dependencies=mariadb,ncurs --level=prod --path=~/projects/java_app"
    echo "  ${ROOT_SCRIPT} inspect"
    echo "  ${ROOT_SCRIPT} new java --show-dependencies"
    exit 0
}

#-------------------------------------------------------------
# SCRIPT CLEANUP
# This function is executed when the script finishes, whether
# it completes successfully, is terminated by a signal, or
# encounters an error. It is used to perform cleanup tasks
# such as releasing resources or deleting temporary files.
#
# Usage:
#   This function should be called at the end of the script
#   to ensure cleanup actions are performed.
#
# Example usage:
#   cleanup
#-------------------------------------------------------------
cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

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
setup_colors() {
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

#######################################
# Logs messages with optional color to STDOUT.
# Globals:
#   COLOR_RED
#   COLOR_GREEN
#   COLOR_YELLOW
#   COLOR_RESET
# Arguments:
#   $1: Log level ('INFO', 'WARN', 'ERROR')
#   $2: Message to log
#######################################
log() {
    local level="$1"
    shift # Shift arguments so $* captures all remaining as the message
    local message="$*"
    local color

    case "$level" in
    INFO)
        color="$GREEN"
        ;;
    WARN)
        color="$YELLOW"
        ;;
    ERROR)
        color="$RED"
        ;;
    *)
        color="$COLOR_RESET"
        ;;
    esac

    echo -e "${color}${ROOT_SCRIPT} [$(now)] | [$level]: $message${COLOR_RESET}"
}

#######################################
# Logs informational messages.
# Arguments:
#   $1: Message to log
#######################################
info() {
    log "INFO" "$@"
}

#######################################
# Logs warning messages.
# Arguments:
#   $1: Message to log
#######################################
warn() {
    log "WARN" "$@"
}

#######################################
# Logs error messages.
# Arguments:
#   $1: Message to log
#######################################
error() {
    log "ERROR" "$@"
}

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
die() {
    local msg=$1
    local code=${2:-1} # default exit status 1
    error "$msg"
    exit "$code"
}

# Function to ensure a parameter is not empty
ensure_not_empty() {
    local value="${1-}"
    local error_message="${2-}"
    echo $error_message

    if [[ -z "$value" ]]; then
        info ${error_message}
        warn ${error_message}
        error ${error_message}
        die "${error_message}

Usage:
    craft new <language>

Available languages: $(print_available_languages)"
    fi
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
need_cmd() {
    if ! check_cmd "$1"; then
        die "Error: '$1' command not found"
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
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}
