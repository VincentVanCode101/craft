#!/usr/bin/env bash
set -euo pipefail

#######################################
# Determine Repository Directory
#######################################

REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

#######################################
# Remote Update Check Function
#######################################

check_for_updates() {
    # URL to the remote VERSION file on GitHub.
    local remote_version_url="https://raw.githubusercontent.com/VincentVanCode101/craft/main/VERSION"

    # Ensure curl is available.
    if ! command -v curl &>/dev/null; then
        return
    fi

    # Read the local version (if available)
    local local_version="unknown"
    if [[ -f "${REPO_DIR}/VERSION" ]]; then
        local_version=$(<"${REPO_DIR}/VERSION")
    fi

    # Fetch the remote VERSION file.
    local remote_version
    remote_version=$(curl -fsSL "$remote_version_url" 2>/dev/null) || remote_version="unknown"

    # Compute SHA256 hashes of the version strings (optional)
    local local_hash remote_hash
    local_hash=$(echo -n "$local_version" | sha256sum | awk '{print $1}')
    remote_hash=$(echo -n "$remote_version" | sha256sum | awk '{print $1}')

    # Compare the hashes (or simply compare the strings)
    if [[ "$remote_hash" != "$local_hash" ]] && [[ "$remote_version" != "unknown" ]]; then
        echo "--------------------------------------------------"
        echo "Update Available: A newer version of craft is available."
        echo "Local version:  $local_version"
        echo "Remote version: $remote_version"
        echo "Please update by pulling the latest changes from the main branch."
        echo "--------------------------------------------------"
    fi
}

# Run the update check at the beginning.
check_for_updates

#######################################
# ... Rest of your craft.sh functionality ...
#######################################
