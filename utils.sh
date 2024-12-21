#!/usr/bin/env bash
#
# Utility functions for logging and Docker image building.

# ANSI color codes
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RESET='\033[0m'

readonly ICON_PATH="$SCRIPT_DIR/assets/hammer-and-wrench.svg"
readonly NOTIFY_DURATION=4000 # Notification duration in milliseconds

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
# Sends a desktop notification to the user.
# Globals:
#   NOTIFY_DURATION
#   ICON_PATH
# Arguments:
#   $1: Notification title
#   $2: Notification message
#######################################
notify_user() {
  local title="$1"
  local message="$2"

  if command -v notify-send &>/dev/null; then
    notify-send -t "$NOTIFY_DURATION" -i "$ICON_PATH" "$title" "$message"
  else
    log "WARN" "notify-send is not installed. Skipping user notification."
  fi
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

    notify_user "❌Build Faild" "Failed to build Docker image '$image_name'."
    err "Failed to build Docker image '$image_name'."
    exit 1
  fi
}
