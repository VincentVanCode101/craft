#!/usr/bin/env bash
set -e # Exit on any error

# Determine the real (canonical) path of this script.
# When run via symlink, readlink -f "$0" returns the actual path of craft.sh in the repository.
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly ROOT_SCRIPT="$(basename "$0")"

# Load utility functions and languages configuration from the repository.
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/.env"

setup_colors

# --- Helper Functions ---

# Splits a comma-separated dependency string and prints each dependency.
parse_dependencies() {
    local dep_string="$1"
    IFS=',' read -r -a dependencies <<<"$dep_string"
    echo "Parsed dependencies:"
    for dep in "${dependencies[@]}"; do
        echo "  - $dep"
    done
}

# Validates that each provided dependency is allowed for the given language.
validate_dependencies() {
    local language="$1"
    local dep_string="$2"
    local allowed_deps_str
    local dep
    local valid

    allowed_deps_str=$(get_allowed_dependencies "$language")
    if [ -z "$allowed_deps_str" ]; then
        echo "Error: Language '$language' does not support dependencies."
        exit 1
    fi

    IFS=',' read -r -a deps <<<"$dep_string"
    IFS=' ' read -r -a allowed_deps <<<"$allowed_deps_str"

    for dep in "${deps[@]}"; do
        valid=false
        for allowed in "${allowed_deps[@]}"; do
            if [ "$dep" == "$allowed" ]; then
                valid=true
                break
            fi
        done
        if [ "$valid" = false ]; then
            echo "Error: Dependency '$dep' is not allowed for language '$language'."
            echo "Allowed dependencies: ${allowed_deps[*]}"
            exit 1
        fi
    done
}

# Checks if the specified language is available.
validate_language() {
    local lang="$1"
    lang=$(echo "$lang" | tr '[:upper:]' '[:lower:]')

    local lang_is_available=false
    for LANG in "${AVAILABLE_LANGUAGES[@]}"; do
        if [ "$lang" == "$LANG" ]; then
            lang_is_available=true
        fi
    done

    if [ "$lang_is_available" = false ]; then
        echo "Language '$lang' is not supported."
        echo "Supported languages are:"
        print_available_languages
        exit 1
    fi
}

# Validates that the provided level (build or prod) is allowed for the specified language.
validate_level_for_language() {
    local language="$1"
    local level="$2"
    local allowed_levels

    allowed_levels=$(get_allowed_levels "$language")
    if [ -z "$allowed_levels" ]; then
        echo "Error: Language '$language' does not support levels." >&2
        exit 1
    fi

    for allowed in $allowed_levels; do
        if [ "$level" == "$allowed" ]; then
            return 0
        fi
    done

    echo "Error: Invalid level '$level' for language '$language'. Allowed levels: $allowed_levels" >&2
    exit 1
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
            echo "Error: 'dev' is the default level and should not be explicitly passed. Allowed levels are: build, prod." >&2
            exit 1
        fi
        validate_level_for_language "$language" "$level"
        echo "$level"
    fi
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

# Displays supported dependencies and allowed levels for a language.
show_supported_options() {
    local language="$1"
    local deps
    local levels

    deps=$(get_allowed_dependencies "$language")
    levels=$(get_allowed_levels "$language")

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
        echo "Directory '$project_dir' already exists. Using existing directory." >&2
    else
        mkdir -p "$project_dir"
        echo "Created project directory: $project_dir" >&2
    fi

    echo "$project_dir"
}

# Cleans up (removes) the project directory if an error occurs.
cleanup_project() {
    local project_dir="$1"
    echo "Cleaning up project directory: $project_dir" >&2
    rm -rf "$project_dir"
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
        (cd "$project_dir" && bash create.sh "$project_name")
        if [ $? -eq 0 ]; then
            echo "create.sh executed successfully. Removing create.sh..."
            # rm -f "$project_dir/create.sh"
        else
            echo "Error: create.sh execution failed." >&2
            cleanup_project "$project_dir"
            exit 1
        fi
    else
        echo "Error: No create.sh found in $project_dir." >&2
        echo "Craft expects a create.sh script to set up the project. Cleaning up..." >&2
        cleanup_project "$project_dir"
        exit 1
    fi

    echo "Project setup complete for $language."
}

# --- Command Handlers ---

# Handles the 'inspect' command.
inspect_command() {
    echo "Allowed Operations and Languages:"
    echo "- Operation: New"
    for lang in "${AVAILABLE_LANGUAGES[@]}"; do
        echo "  * Language: $lang"
        echo "    Run 'craft new $lang --help' to see the available dependencies and levels."
    done
}
handle_new_command() {
    if [ $# -lt 1 ]; then
        echo "Error: 'new' requires an additional argument."
        echo "Use -h or --help for usage information."
        echo "-> craft.sh -h || craft.sh new -h"
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
        --path=*)
            path_flag="${1#*=}"
            if [ -z "$path_flag" ]; then
                echo "Warning: The '--path' flag requires a value."
                echo "Usage: craft new $language --path=<foo/bar/name>"
                exit 1
            fi
            ;;
        --path)
            echo "Warning: The '--path' flag requires a value."
            echo "Usage: craft new $language --path=<foo/bar/name>"
            exit 1
            ;;
        --dependencies=*)
            dependencies_flag="${1#*=}"
            if [ -z "$dependencies_flag" ]; then
                echo "Warning: The '--dependencies' flag requires a value."
                echo "Usage: craft new $language --dependencies=<dep1,dep2,...>"
                exit 1
            fi
            ;;
        --dependencies)
            echo "Warning: The '--dependencies' flag requires a value."
            echo "Usage: craft new $language --dependencies=<dep1,dep2,...>"
            exit 1
            ;;
        --level=*)
            level_flag="${1#*=}"
            if [ -z "$level_flag" ]; then
                echo "Warning: The '--level' flag requires a value (build or prod)."
                exit 1
            fi
            ;;
        --level)
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
    download_templates "$branch_name" "$project_dir"
    create_new_project "$language" "$dependencies_flag" "$project_dir"
}

# Prints help for the 'new' command.
usage_new() {
    echo "Create a new project"
    echo ""
    echo "Usage:"
    echo "  craft new <language> [flags]"
    echo ""
    echo "Flags:"
    echo "  -d, --dependencies string   Specify the dependencies or project type (e.g., --dependencies=maven,spring)"
    echo "  -n, --name string           Specify the project name (the last segment of the path)"
    echo "      --level string          Specify the project level (allowed values: build, prod)"
    echo "      --path string           Specify a path for the new project (last segment is the project name)"
    echo "      --show-dependencies     Show supported dependencies and allowed levels for the specified language"
    echo "  -h, --help                  Help for new"
}

# --- Main Function ---

main() {
    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        usage
        exit 0
    fi

    case "$1" in
    new)
        shift
        handle_new_command "$@"
        ;;
    inspect)
        inspect_command
        ;;
    *)
        echo "Error: Invalid option or command."
        echo "Use -h or --help for usage information."
        exit 1
        ;;
    esac
}

# --- Execute Main ---
main "$@"
