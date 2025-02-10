#!/usr/bin/env bash
set -euo pipefail

#######################################
# Variables and Constants
#######################################

# Determine the repository directory based on the script's location.
REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Load configuration. It is expected that config.sh defines CRAFT_BINARY_NAME.
source "${REPO_DIR}/lib/config.sh"

# Construct the full path to the binary in the repository.
CRAFT_BINARY="${REPO_DIR}/${CRAFT_BINARY_NAME}"

# Determine the target directory for the symlink.
if [[ -d "/usr/local/bin" ]]; then
    TARGET_DIR="/usr/local/bin"
elif [[ -d "/opt/homebrew/bin" ]]; then
    TARGET_DIR="/opt/homebrew/bin"
else
    echo "Error: Neither /usr/local/bin nor /opt/homebrew/bin exist." >&2
    echo "Please create one of these directories and add it to your PATH." >&2
    exit 1
fi

# Define the full target path for the symlink.
TARGET="${TARGET_DIR}/${CRAFT_BINARY_NAME}"

#######################################
# Functions
#######################################

# Print an error message to stderr and exit.
die() {
    echo "Error: $*" >&2
    exit 1
}

# Create or update the symlink.
create_symlink() {
    echo "Creating symlink: ${TARGET} -> ${CRAFT_BINARY}"

    # Remove any existing file or symlink at the target location.
    if [[ -e "$TARGET" || -L "$TARGET" ]]; then
        echo "Removing existing file or symlink at ${TARGET}"
        sudo rm -f "$TARGET"
    fi

    # Create the new symlink.
    sudo ln -s "$CRAFT_BINARY" "$TARGET"

    # Verify that the symlink points to the expected binary.
    local resolved_path
    resolved_path="$(readlink -f "$TARGET")"
    if [[ "$resolved_path" != "$CRAFT_BINARY" ]]; then
        die "The symlink does not point to the expected file.
Expected: ${CRAFT_BINARY}
Got:      ${resolved_path}"
    fi

    echo "Symlink created successfully. When executing ${TARGET}, the repository binary is used."
}

#######################################
# Main
#######################################

create_symlink

echo "install.sh completed successfully."
