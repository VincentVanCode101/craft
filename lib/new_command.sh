#!/usr/bin/env bash
# new_command.sh

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/languages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../.env"
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
new_command::handle_new_command() {
    if [ $# -lt 1 ]; then
        logger::error "'${BINARY_NAME} new' requires an additional argument."
        logger::notice "Use '${BINARY_NAME} new --help' for usage information."
        exit 1
    fi

    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        usage::new_command
        exit 0
    fi

    local language="$1"
    languages::validate "$language"
    shift

    local dependencies_flag=""
    local path_flag=""
    local level_flag=""
    local show_deps_flag=""

    while [ $# -gt 0 ]; do
        case "$1" in
        -p=* | --path=*)
            path_flag="${1#*=}"
            if [ -z "$path_flag" ]; then
                logger::error "The '--path' flag requires a value."
                logger::notice "Usage: ${BINARY_NAME} new $language --path=<foo/bar/name>"
                exit 1
            fi
            ;;
        -p | --path)
            logger::error "The '--path' flag requires a value."
            logger::notice "Usage: ${BINARY_NAME} new $language --path=<foo/bar/name>"
            exit 1
            ;;
        -d=* | --dependencies=*)
            dependencies_flag="${1#*=}"
            if [ -z "$dependencies_flag" ]; then
                logger::error "The '--dependencies' flag requires a value."
                logger::notice "Usage: ${BINARY_NAME} new $language --dependencies=<dep1,dep2,...>"
                exit 1
            fi
            ;;
        -d | --dependencies)
            logger::error "The '--dependencies' flag requires a value."
            logger::notice "Usage: ${BINARY_NAME} new $language --dependencies=<dep1,dep2,...>"
            exit 1
            ;;
        -l=* | --level=*)
            level_flag="${1#*=}"
            if [ -z "$level_flag" ]; then
                logger::error "The '--level' flag requires a value (build or prod)."
                exit 1
            fi
            ;;
        -l | --level)
            logger::error "The '--level' flag requires a value (build or prod)."
            exit 1
            ;;
        --show-dependencies)
            show_deps_flag="true"
            ;;
        # Logging verbosity flags
        -q | --quiet)
            LOG_LEVEL=1
            ;;
        -vv | --debug)
            LOG_LEVEL=4
            SUPER_DEBUG=true
            ;;
        -v | --verbose)
            LOG_LEVEL=4
            ;;
        -h | --help)
            usage::new_command
            exit 0
            ;;
        *)
            logger::error "Unknown option or argument '$1' after '${BINARY_NAME} new $language'."
            logger::notice "Use '${BINARY_NAME} new $language --help' for usage information."
            exit 1
            ;;
        esac
        shift
    done

    if [ "$SUPER_DEBUG" = "true" ]; then
        set -x
        logger::debug "Super debug mode enabled"
    fi

    if [ "$show_deps_flag" = "true" ]; then
        _show_supported_options "$language"
        exit 0
    fi

    level_flag=$(_process_level_flag "$language" "$level_flag")
    if [ -n "$dependencies_flag" ]; then
        languages::validate_dependencies "$language" "$dependencies_flag"
    fi

    local template_key
    template_key=$(_construct_templates_key "$language" "$dependencies_flag" "$level_flag")

    local project_dir
    project_dir=$(_create_project_folder "$template_key" "$path_flag")
    trap "_error_handler ${BASH_LINENO[0]} '${project_dir:-}'" EXIT

    local templates_url
    templates_url=$(_get_templates_url "$template_key")
    _download_templates "$templates_url" "$project_dir"

    _create_new_project "$language" "$dependencies_flag" "$project_dir"

    trap - ERR EXIT
    exit 0
}

_process_level_flag() {
    local language="$1"
    local level="$2"
    if [ -z "$level" ]; then
        echo ""
    else
        if [ "$level" = "dev" ]; then
            logger::error "'dev' is the default level and should not be explicitly passed. Allowed levels are: build, prod." >&2
            exit 1
        fi
        languages::validate_level "$language" "$level"
        echo "$level"
    fi
}

_show_supported_options() {
    local language="$1"
    local deps
    local levels

    deps=$(languages::get_allowed_dependencies "$language")
    levels=$(languages::get_allowed_levels "$language")

    if [ "$language" = "java" ]; then
        echo "Maven is the default build tool for Java projects."
    fi

    echo ""
    echo "Supported Dependencies:"
    if [ -z "$deps" ]; then
        echo "  - None supported"
    else
        for dep in $deps; do
            echo "  - $dep"
        done
    fi

    echo ""
    echo "Allowed Levels:"
    if [ -z "$levels" ]; then
        echo "  - None supported"
    else
        for lvl in $levels; do
            echo "  - $lvl"
        done
    fi
}

# ---------------------------------------------------------------------
# Retrieves the templates URL from the environment using the templates key.
# The .env file should define variables in the format: TEMPLATES_URL_<key>
# ---------------------------------------------------------------------
_get_templates_url() {
    local template_key="$1"
    local var_name="TEMPLATES_URL_${template_key}"
    local templates_url="${!var_name:-}"

    if [ -z "$templates_url" ]; then
        logger::error "No templates URL found for key '$template_key'." >&2
        logger::error "Please define ${var_name} in your .env file." >&2
        exit 1
    fi

    echo "$templates_url"
}

# ---------------------------------------------------------------------
# Downloads the template files from the remote repository.
#
# Arguments:
#   $1 - The URL from which to download the templates.
#   $2 - The destination directory where the templates should be extracted.
#
# This function downloads the zip file from the provided URL into the target
# directory, unzips its contents, and cleans up the downloaded zip file.
# ---------------------------------------------------------------------
_download_templates() {
    local url="$1"
    local target_dir="$2"

    logger::info "Downloading templates from ${url} into ${target_dir}..."
    curl -L -o "${target_dir}/templates.zip" "$url"
    unzip -o "${target_dir}/templates.zip" -d "$target_dir" 1>/dev/null
    rm "${target_dir}/templates.zip"

    local extracted_folder
    extracted_folder=$(find "$target_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    if [ -n "$extracted_folder" ]; then
        shopt -s dotglob
        mv "$extracted_folder"/* "$target_dir"/
        shopt -u dotglob

        rm -rf "$extracted_folder"
    fi
}

_create_project_folder() {
    local template_key="$1"
    local path_flag="$2"
    local project_dir=""

    if [ -n "$path_flag" ]; then
        if [[ "$path_flag" == "~"* ]]; then
            path_flag="${path_flag/#\~/$HOME}"
        fi
        project_dir="$path_flag"
    else
        project_dir="craft-${template_key}"
    fi

    if [ -d "$project_dir" ]; then
        logger::error "Directory '$project_dir' already exists. Use a different path/name." >&2
        exit 1
    else
        mkdir -p "$project_dir"
        logger::info "Created project directory: $project_dir" >&2
    fi

    echo "$project_dir"
}

_create_new_project() {
    local language="$1"
    local dependencies="$2"
    local project_dir="$3"

    logger::info "Project Details:"
    logger::info "  - Project Language: $language"
    logger::info "  - Project Dependencies: $dependencies"
    logger::info "  - Project Directory: $project_dir"

    local project_name
    project_name=$(basename "$project_dir")

    if [ -f "$project_dir/create.sh" ]; then
        logger::info "Found create.sh in $project_dir, executing it..."
        if (cd "$project_dir" && bash create.sh "$project_name"); then
            logger::info "create.sh executed successfully. Removing create.sh..."
            rm -f "$project_dir/create.sh"
        else
            logger::error "create.sh execution failed." >&2
            # [ ] TODO: solve how this can be done more elegently...
            # if I do not un-trap the EXIT, but still call the error_handler
            # I get the last error message twice. But I need to call the
            # error_handler manually for the correct line number of the
            # error to be passed to it (so it appears correctly in the logs)
            trap - EXIT
            _error_handler ${BASH_LINENO[0]} "${project_dir:-}"
            exit 1
        fi
    else
        logger::warn "No create.sh found in $project_dir." >&2
        logger::error "${BINARY_NAME} expects a create.sh script to set up the project. Cleaning up..." >&2

        trap - EXIT
        _error_handler ${BASH_LINENO[0]} "${project_dir:-}"
        exit 1
    fi

    logger::info "Project setup complete for $language."
}

_construct_templates_key() {
    local language="$1"
    local dep_string="$2"
    local level="$3"
    local key=""

    if [ -n "$level" ]; then
        key="${language}_${level}"
    else
        key="${language}"
    fi

    if [ -n "$dep_string" ]; then
        IFS=',' read -r -a deps <<<"$dep_string"
        local sorted_deps
        sorted_deps=$(printf "%s\n" "${deps[@]}" | sort)
        local joined_deps
        joined_deps=$(echo "$sorted_deps" | tr '\n' '_' | sed 's/_$//')
        key="${key}_${joined_deps}"
    fi

    echo "$key"
}

# ---------------------------------------------------------------------
# Handles errors by logging the line number, function name, and project directory,
# cleaning up the project directory, and exiting.
#
# Parameters:
#   $1 - The line number where the error occurred.
#   $2 - The project directory to clean up.
# ---------------------------------------------------------------------
_error_handler() {
    local line_number="$1"
    local project_dir="$2"
    local func="${FUNCNAME[1]:-MAIN}"

    if [[ "$LOG_LEVEL" -eq 4 ]]; then
        logger::error "An error occurred while executing function \"$func\" on line $line_number. Removing created project directory: $project_dir" >&2
    else
        logger::error "An error occurred. Removing created project directory: $project_dir" >&2
    fi

    rm -rf "$project_dir"
    exit 1
}
