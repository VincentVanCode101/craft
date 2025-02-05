#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/languages_dependencies_levels.sh"

inspect_command() {
    echo "Supported Languages:"
    for lang in "${AVAILABLE_LANGUAGES[@]}"; do
        echo "  - $lang"
    done
    echo
    echo "Run 'craft new <language> --help' to see the available dependencies and levels."
}
