#!/usr/bin/env bash
#
# Utility functions for logging and Docker image building.

# ANSI color codes
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RESET='\033[0m'

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
  local message="$2"
  local color

  case "$level" in
    INFO)
      color="$COLOR_GREEN"
      ;;
    WARN)
      color="$COLOR_YELLOW"
      ;;
    ERROR)
      color="$COLOR_RED"
      ;;
    *)
      color="$COLOR_RESET"
      ;;
  esac

  echo -e "${color}[$(date +'%Y-%m-%dT%H:%M:%S%z')] [$level]: $message${COLOR_RESET}"
}

#######################################
# Logs error messages to STDERR with a timestamp and color.
# Globals:
#   None
# Arguments:
#   Message string to log.
#######################################
err() {
  log "ERROR" "$*" >&2
}

#######################################
# Builds a Docker image with a given name and context.
# Logs the status and exits on failure.
# Globals:
#   None
# Arguments:
#   $1: Docker image name (required)
#   $2: Build context (optional, defaults to current directory)
#######################################
build_docker_image() {
  local image_name="$1"
  local context="${2:-.}"

  if [[ -z "$image_name" ]]; then
    err "Docker image name must be provided."
    exit 1
  fi

  log "INFO" "Building Docker image '$image_name' with context '$context'..."
  if docker build -t "$image_name" "$context"; then
    log "INFO" "Successfully built Docker image '$image_name'."
  else
    err "Failed to build Docker image '$image_name'."
    exit 1
  fi
}
