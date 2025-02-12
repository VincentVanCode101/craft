#!/usr/bin/env bash
# lib/version.sh

version::print() {
    # Determine the project root directory.
    # This assumes that this file is located in PROJECT_ROOT/lib/
    local project_root
    project_root="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
    local version_file="$project_root/VERSION"

    if [[ -f "$version_file" ]]; then
        logger::print "Version: $(cat "$version_file")"
    else
        logger::error "Version file not found." >&2
        exit 1
    fi
}
