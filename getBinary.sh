#!/usr/bin/env bash
set -e

# Determine the absolute path to this script (getBinary.sh) and from that, the repository root.
REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Assume that craft.sh is in the repository root.
CRAFT_BINARY="${REPO_DIR}/craft.sh"

# The target location for the symlink.
TARGET="/usr/local/bin/craft.sh"

echo "Creating symlink $TARGET -> $CRAFT_BINARY"

# Remove any existing file or symlink at the target location.
if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    echo "Removing existing file or symlink at $TARGET"
    sudo rm -f "$TARGET"
fi

# Create the symlink using sudo (since /usr/local/bin typically requires elevated privileges).
sudo ln -s "$CRAFT_BINARY" "$TARGET"

# Verify that executing the symlink points to the correct file.
EXECUTED_PATH="$(readlink -f "$TARGET")"
if [ "$EXECUTED_PATH" = "$CRAFT_BINARY" ]; then
    echo "Symlink created successfully. When executing /usr/local/bin/craft.sh, the repository binary is used."
else
    echo "Error: The symlink does not point to the expected file."
    echo "Expected: $CRAFT_BINARY"
    echo "Got:      $EXECUTED_PATH"
    exit 1
fi

echo "getBinary.sh completed successfully."
