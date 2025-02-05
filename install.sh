#!/usr/bin/env bash

set -e

REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

source "${REPO_DIR}/config.sh"

CRAFT_BINARY="${REPO_DIR}/${CRAFT_BINARY_NAME}"

if [ -d "/usr/local/bin" ]; then
    TARGET="/usr/local/bin/${CRAFT_BINARY_NAME}"
elif [ -d "/opt/homebrew/bin" ]; then
    TARGET="/opt/homebrew/bin/${CRAFT_BINARY_NAME}"
else
    echo "Error: Neither /usr/local/bin nor /opt/homebrew/bin exist. Please create one of these directories and add it to your PATH." >&2
    exit 1
fi

echo "Creating symlink $TARGET -> $CRAFT_BINARY"

if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    echo "Removing existing file or symlink at $TARGET"
    sudo rm -f "$TARGET"
fi

sudo ln -s "$CRAFT_BINARY" "$TARGET"

EXECUTED_PATH="$(readlink -f "$TARGET")"
if [ "$EXECUTED_PATH" = "$CRAFT_BINARY" ]; then
    echo "Symlink created successfully. When executing $TARGET, the repository binary is used."
else
    echo "Error: The symlink does not point to the expected file."
    echo "Expected: $CRAFT_BINARY"
    echo "Got:      $EXECUTED_PATH"
    exit 1
fi

echo "install.sh completed successfully."
