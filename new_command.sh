#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/languages_dependencies_levels.sh"
source "$(dirname "${BASH_SOURCE[0]}")/.env"
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

handle_new_command() {
    if [ $# -lt 1 ]; then
        echo "Error: 'new' requires an additional argument."
        echo "Use -h or --help for usage information."
        echo "-> ${CRAFT_BINARY_NAME} -h || ${CRAFT_BINARY_NAME} new -h"
        exit 1
    fi
    # Check if the first argument is -h or --help before validating language.
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        usage_new
        exit 0
    fi

    local language="$1"
    validate_language "$language"
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
                echo "Warning: The '--path' flag requires a value."
                echo "Usage: ${CRAFT_BINARY_NAME} new $language --path=<foo/bar/name>"
                exit 1
            fi
            ;;
        -p | --path)
            echo "Warning: The '--path' flag requires a value."
            echo "Usage: ${CRAFT_BINARY_NAME} new $language --path=<foo/bar/name>"
            exit 1
            ;;
        -d=* | --dependencies=*)
            dependencies_flag="${1#*=}"
            if [ -z "$dependencies_flag" ]; then
                echo "Warning: The '--dependencies' flag requires a value."
                echo "Usage: ${CRAFT_BINARY_NAME} new $language --dependencies=<dep1,dep2,...>"
                exit 1
            fi
            ;;
        -d | --dependencies)
            echo "Warning: The '--dependencies' flag requires a value."
            echo "Usage: ${CRAFT_BINARY_NAME} new $language --dependencies=<dep1,dep2,...>"
            exit 1
            ;;
        -l=* | --level=*)
            level_flag="${1#*=}"
            if [ -z "$level_flag" ]; then
                echo "Warning: The '--level' flag requires a value (build or prod)."
                exit 1
            fi
            ;;
        -l | --level)
            echo "Warning: The '--level' flag requires a value (build or prod)."
            exit 1
            ;;
        --show-dependencies)
            show_deps_flag="true"
            ;;
        -h | --help)
            usage_new
            exit 0
            ;;
        *)
            echo "Error: Unknown option or argument '$1' after 'new $language'."
            echo "Use -h or --help for usage information."
            exit 1
            ;;
        esac
        shift
    done

    if [ "$show_deps_flag" = "true" ]; then
        show_supported_options "$language"
        exit 0
    fi

    level_flag=$(process_level_flag "$language" "$level_flag")
    if [ -n "$dependencies_flag" ]; then
        validate_dependencies "$language" "$dependencies_flag"
        parse_dependencies "$dependencies_flag"
    fi

    local branch_name
    branch_name=$(construct_branch_name "$language" "$dependencies_flag" "$level_flag")
    echo "Using branch: $branch_name"

    local project_dir
    project_dir=$(create_project_folder "$branch_name" "$path_flag")

    trap 'error_handler "$project_dir"' ERR
    trap 'error_handler "$project_dir"' EXIT

    download_templates "$branch_name" "$project_dir"

    create_new_project "$language" "$dependencies_flag" "$project_dir"

    trap - ERR EXIT
    exit 0
}

# Processes the level flag.
# If no level is provided, default is implicitly "dev" (but not mentioned in branch names).
# If provided, it must be either "build" or "prod".
process_level_flag() {
    local language="$1"
    local level="$2"
    if [ -z "$level" ]; then
        echo ""
    else
        if [ "$level" = "dev" ]; then
            error "Error: 'dev' is the default level and should not be explicitly passed. Allowed levels are: build, prod." >&2
            exit 1
        fi
        validate_level_for_language "$language" "$level"
        echo "$level"
    fi
}

# Displays supported dependencies and allowed levels for a language.
show_supported_options() {
    local language="$1"
    local deps
    local levels

    deps=$(get_allowed_dependencies_for_language "$language")
    levels=$(get_allowed_levels_for_language "$language")

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

# Downloads the template files from the remote repository based on the branch name.
# Since branches are named using underscores, the branch name directly forms the variable name.
download_templates() {
    local branch_name="$1"
    local target_dir="$2"
    local var_name="TEMPLATES_URL_${branch_name}"

    local templates_url="${!var_name:-}"

    if [ -z "$templates_url" ]; then
        echo "Error: No templates URL found for branch '$branch_name'."
        echo "Please define ${var_name} in your .env file."
        exit 1
    fi

    echo "Downloading templates from ${templates_url} into ${target_dir}..."
    curl -L -o "${target_dir}/templates.zip" "$templates_url"
    unzip -o "${target_dir}/templates.zip" -d "$target_dir"
    rm "${target_dir}/templates.zip"

    local extracted_folder
    extracted_folder=$(find "$target_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    if [ -n "$extracted_folder" ]; then
        echo "Moving contents from $extracted_folder to $target_dir..."
        mv "$extracted_folder"/* "$target_dir"/
        rm -rf "$extracted_folder"
    fi
}

# Creates the project folder.
# If a --path flag is passed, that folder is used; otherwise, a folder named "craft-<branchname>" is created.
create_project_folder() {
    local branch_name="$1"
    local path_flag="$2"
    local project_dir=""

    if [ -n "$path_flag" ]; then
        if [[ "$path_flag" == "~"* ]]; then
            path_flag="${path_flag/#\~/$HOME}"
        fi
        project_dir="$path_flag"
    else
        project_dir="craft-${branch_name}"
    fi

    if [ -d "$project_dir" ]; then
        echo "Directory '$project_dir' already exists. Use a different path/name." >&2
        exit 1
    else
        mkdir -p "$project_dir"
        echo "Created project directory: $project_dir" >&2
    fi

    echo "$project_dir"
}

# Finalizes project creation.
# Checks if a "create.sh" script is present in the downloaded files.
# If present, executes it (passing the project name) and removes it upon success.
# If not, prints an error and cleans up the project directory.
create_new_project() {
    local language="$1"
    local dependencies="$2"
    local project_dir="$3"

    echo "Project Language: $language"
    echo "Project Dependencies: $dependencies"
    echo "Project Directory: $project_dir"

    local project_name
    project_name=$(basename "$project_dir")

    if [ -f "$project_dir/create.sh" ]; then
        echo "Found create.sh in $project_dir, executing it..."
        if (cd "$project_dir" && bash create.sh "$project_name"); then
            echo "create.sh executed successfully. Removing create.sh..."
            rm -f "$project_dir/create.sh"
        else
            echo "Error: create.sh execution failed." >&2
            cleanup_project "$project_dir"
            exit 1
        fi
    else
        echo "Error: No create.sh found in $project_dir." >&2
        echo "${CRAFT_BINARY_NAME} expects a create.sh script to set up the project. Cleaning up..." >&2
        cleanup_project "$project_dir"
        exit 1
    fi

    echo "Project setup complete for $language."
}

# Constructs a canonical branch name based on language, level, and dependencies.
# Uses underscores to separate parts.
construct_branch_name() {
    local language="$1"
    local dep_string="$2"
    local level="$3"
    local branch_name=""

    if [ -n "$level" ]; then
        branch_name="${language}_${level}"
    else
        branch_name="${language}"
    fi

    if [ -n "$dep_string" ]; then
        IFS=',' read -r -a deps <<<"$dep_string"
        local sorted_deps
        sorted_deps=$(printf "%s\n" "${deps[@]}" | sort)
        local joined_deps
        joined_deps=$(echo "$sorted_deps" | tr '\n' '_' | sed 's/_$//')
        branch_name="${branch_name}_${joined_deps}"
    fi

    echo "$branch_name"
}

# Cleans up (removes) the project directory if an error occurs.
cleanup_project() {
    local project_dir="$1"
    echo "Cleaning up project directory: $project_dir" >&2
    rm -rf "$project_dir"
}

error_handler() {
    # BASH_LINENO[0] is the line number of the command that failed.
    # FUNCNAME[1] is the name of the function where the error occurred (or MAIN if not in a function).
    local line_number="${BASH_LINENO[0]}"
    local func="${FUNCNAME[1]:-MAIN}"

    local project_dir="$1"

    if [[ "${DEBUG:-false}" == "true" ]]; then
        error "An error occurred while executing function \"$func\" on line $line_number. Removing created project directory: $project_dir" >&2
    else
        error "An error occurred. Removing created project directory: $project_dir" >&2
    fi

    rm -rf "$project_dir"
    exit 1
}
