#!/usr/bin/env bash
# update.sh
#
# This file contains the update logic for craft.
# It checks if a newer version (as defined by the remote VERSION file)
# is available and, if so, prompts the user to update before proceeding.
# Only the main function is exported (update::check_for_updates),
# while internal helpers are named with an underscore.

# Internal helper functions

_get_repo_dir() {
    cd "$(dirname "$(readlink -f "$0")")" && pwd
}

_get_timestamp_file() {
    local repo_dir
    repo_dir="$(_get_repo_dir)"
    echo "${repo_dir}/.timestamp"
}

_last_update_check() {
    local timestamp_file
    timestamp_file="$(_get_timestamp_file)"
    if [[ -f "$timestamp_file" ]]; then
        cat "$timestamp_file"
    else
        echo "0"
    fi
}

_update_timestamp() {
    local timestamp_file
    timestamp_file="$(_get_timestamp_file)"
    date +%s >"$timestamp_file"
}

_should_check_for_updates() {
    local current_time last_check diff
    current_time=$(date +%s)
    last_check=$(_last_update_check)
    diff=$((current_time - last_check))
    # One week = 604800 seconds
    if ((diff >= 604800)); then
        return 0 # Yes: enough time has passed.
    else
        return 1 # No: not yet.
    fi
}

_get_local_version() {
    local repo_dir
    repo_dir="$(_get_repo_dir)"
    if [[ -f "${repo_dir}/VERSION" ]]; then
        cat "${repo_dir}/VERSION"
    else
        echo "unknown"
    fi
}

_get_remote_version() {
    local remote_version_url="https://raw.githubusercontent.com/VincentVanCode101/craft/main/VERSION"
    curl -fsSL "$remote_version_url" 2>/dev/null || echo "unknown"
}

_prompt_update() {
    echo -n "Would you like to update ${BINARY_NAME}? [y/n] "
    read -r answer
    if [[ "$answer" =~ ^[Yy] ]]; then
        return 0
    else
        return 1
    fi
}

_perform_update() {
    local repo_dir
    repo_dir="$(_get_repo_dir)"
    if [[ -d "${repo_dir}/.git" ]]; then
        logger::info "Updating ${BINARY_NAME} repository..."
        cd "$repo_dir" || {
            logger::error "Cannot change directory to ${repo_dir}"
            exit 1
        }
        git pull || {
            logger::error "Update failed. Please update manually."
            exit 1
        }
        logger::info "${BINARY_NAME} updated successfully."
        logger::info "Restarting ${BINARY_NAME}..."
        exec "${repo_dir}/${BINARY_NAME}" "$@"
    else
        logger::error "Automatic update is not available (not a Git repository)."
        exit 1
    fi
}

update::check_for_updates() {
    local repo_dir
    repo_dir="$(_get_repo_dir)"
    source "${repo_dir}/lib/config.sh"

    if ! _should_check_for_updates; then
        return 0
    fi

    _update_timestamp

    local local_version remote_version
    local_version="$(_get_local_version)"
    remote_version="$(_get_remote_version)"

    if [[ "$remote_version" != "unknown" && "$local_version" != "$remote_version" ]]; then
        logger::warn "A newer version of ${BINARY_NAME} is available."
        logger::info "Local version:  $local_version"
        logger::info "Remote version: $remote_version"
        if _prompt_update; then
            _perform_update "$@"
        else
            logger::info "Continuing with the current version of ${BINARY_NAME}."
        fi
    fi
}
