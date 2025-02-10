#!/usr/bin/env bash
# update.sh
#
# This file contains the update logic for craft.
# It checks if a newer version (as defined by the remote VERSION file)
# is available and, if so, prompts the user to update before proceeding.

update::check_for_updates() {
    local repo_dir
    repo_dir="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
    source "${repo_dir}/lib/config.sh"

    local remote_version_url="https://raw.githubusercontent.com/VincentVanCode101/craft/main/VERSION"

    local local_version="unknown"
    if [[ -f "${repo_dir}/VERSION" ]]; then
        local_version=$(<"${repo_dir}/VERSION")
    fi

    local remote_version
    remote_version=$(curl -fsSL "$remote_version_url" 2>/dev/null || echo "unknown")

    if [[ "$remote_version" != "unknown" && "$local_version" != "$remote_version" ]]; then
        logger::warn "A newer version of craft is available."
        logger::info "Local version:  $local_version"
        logger::info "Remote version: $remote_version"
        echo -n "Would you like to update craft? [y/n] "
        read -r answer
        if [[ "$answer" =~ ^[Yy] ]]; then
            if [[ -d "${repo_dir}/.git" ]]; then
                logger::info "Updating craft repository..."
                cd "$repo_dir" || {
                    logger::error "Cannot change directory to ${repo_dir}"
                    exit 1
                }
                git pull || {
                    logger::error "Update failed. Please update manually."
                    exit 1
                }
                logger::info "craft updated successfully."
                logger::info "Restarting craft..."
                # Re-execute craft.sh (using the binary name defined in your config)
                exec "${repo_dir}/${CRAFT_BINARY_NAME}" "$@"
            else
                logger::error "Automatic update is not available (not a Git repository)."
                exit 1
            fi
        else
            logger::info "Continuing with the current version of craft."
        fi
    fi
}
