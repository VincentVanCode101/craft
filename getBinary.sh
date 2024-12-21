#!/bin/bash
#
# Script to extract the craft binary from a built Docker image,
# copy it to the project directory, and create a symlink in /usr/local/bin.

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly IMAGE_NAME="craft-exec:latest"
readonly BINARY_NAME="craft"
readonly LOCAL_BIN="/usr/local/bin"
readonly SYMLINK_NAME="craft"

# Load utility functions
source "$SCRIPT_DIR/utils.sh"

#######################################
# Creates a symlink for the binary in /usr/local/bin.
# Globals:
#   BINARY_NAME
#   SYMLINK_NAME
#   LOCAL_BIN
# Arguments:
#   $1: Path to the binary file
#######################################
create_symlink() {
  local binary_path="$1"

  if [[ ! -f "$binary_path" ]]; then
    err "Binary not found at $binary_path. Cannot create symlink."
    exit 1
  fi

  log "INFO" "Creating symlink for $BINARY_NAME at $LOCAL_BIN/$SYMLINK_NAME..."
  if ! sudo ln -sf "$binary_path" "$LOCAL_BIN/$SYMLINK_NAME"; then
    err "Failed to create symlink at $LOCAL_BIN/$SYMLINK_NAME"
    exit 1
  fi

  log "INFO" "Symlink created: $LOCAL_BIN/$SYMLINK_NAME -> $binary_path"
}

#######################################
# Main function to build the Docker image, extract the binary,
# and set up the symlink.
# Globals:
#   IMAGE_NAME
#   BINARY_NAME
#   SCRIPT_DIR
# Arguments:
#   None
#######################################
main() {
  log "INFO" "Building the Docker image for $BINARY_NAME..."
  build_docker_image "$IMAGE_NAME" "$SCRIPT_DIR"

  log "INFO" "Extracting the $BINARY_NAME binary from the Docker image..."
  local binary_path="$SCRIPT_DIR/$BINARY_NAME"
  local container_id
  container_id=$(docker create "$IMAGE_NAME")
  docker cp "${container_id}:/app/${BINARY_NAME}" "$binary_path"
  docker rm "${container_id}"

  log "INFO" "Binary extracted to $binary_path"

  create_symlink "$binary_path"

  notify_user "Build Complete" "The $BINARY_NAME build and setup process is complete!"
}

main "$@"
