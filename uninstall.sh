#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

source "${REPO_DIR}/config.sh"

CRAFT_BINARY="${REPO_DIR}/${CRAFT_BINARY_NAME}"

BIN_DIRS=("/usr/local/bin" "/opt/homebrew/bin")

for BIN_DIR in "${BIN_DIRS[@]}"; do
    if [ -d "${BIN_DIR}" ]; then
        TARGET="${BIN_DIR}/${CRAFT_BINARY_NAME}"
        if [ -L "$TARGET" ]; then
            LINK_TARGET="$(readlink -f "$TARGET")"
            if [ "$LINK_TARGET" = "$CRAFT_BINARY" ]; then
                echo "Removing symlink: $TARGET -> $CRAFT_BINARY"
                sudo rm -f "$TARGET"
            else
                echo "Skipping $TARGET because it does not point to the expected binary."
            fi
        else
            if [ -e "$TARGET" ]; then
                echo "A file exists at $TARGET but is not a symlink. Skipping removal."
            else
                echo "No file or symlink found at $TARGET."
            fi
        fi
    else
        echo "Directory ${BIN_DIR} does not exist. Skipping."
    fi
done

echo "uninstall.sh completed successfully."
