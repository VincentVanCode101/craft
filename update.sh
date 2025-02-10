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
    local remote_version_url="https://raw.githubusercontent.com/VincentVanCode101/craft/main/VERSION"

    if ! command -v curl &>/dev/null; then
        return
    fi

    local local_version="unknown"
    if [[ -f "${REPO_DIR}/VERSION" ]]; then
        local_version=$(<"${REPO_DIR}/VERSION")
    fi

    local remote_version
    remote_version=$(curl -fsSL "$remote_version_url" 2>/dev/null) || remote_version="unknown"

    local local_hash remote_hash
    local_hash=$(echo -n "$local_version" | sha256sum | awk '{print $1}')
    remote_hash=$(echo -n "$remote_version" | sha256sum | awk '{print $1}')

    if [[ "$remote_hash" != "$local_hash" ]] && [[ "$remote_version" != "unknown" ]]; then
        echo "--------------------------------------------------"
        echo "Update Available: A newer version of craft is available."
        echo "Local version:  $local_version"
        echo "Remote version: $remote_version"
        echo "Please update by pulling the latest changes from the main branch."
        echo "--------------------------------------------------"
    fi
}

check_for_updates
