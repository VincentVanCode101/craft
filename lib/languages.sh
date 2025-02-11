#!/usr/bin/env bash
# languages.sh

export AVAILABLE_LANGUAGES=("go" "java" "rust")

GO_DEPENDENCIES=("")
JAVA_DEPENDENCIES=("quarkus")
RUST_DEPENDENCIES=("")

export ALLOWED_LEVELS_go=""
export ALLOWED_LEVELS_java=""
export ALLOWED_LEVELS_rust=""

# -----------------------------------------------------------------------------
# ---------------------------- LANGUAGES --------------------------------------
# -----------------------------------------------------------------------------

languages::print_available() {
    echo "${AVAILABLE_LANGUAGES[*]}" | tr ' ' ', '
}

languages::validate() {
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
        languages::print_available
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# ---------------------------- DEPENDENCIES -----------------------------------
# -----------------------------------------------------------------------------

# Returns the allowed dependencies for the given language
languages::get_allowed_dependencies() {
    local lang
    lang=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$lang" in

    go) echo "${GO_DEPENDENCIES[*]}" ;;
    java) echo "${JAVA_DEPENDENCIES[*]}" ;;
    rust) echo "${RUST_DEPENDENCIES[*]}" ;;
    *) echo "" ;;
    esac
}

languages::validate_dependencies() {
    local language="$1"
    local dep_string="$2"
    local allowed_deps_str
    local dep
    local valid

    allowed_deps_str=$(languages::get_allowed_dependencies "$language")
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

# -----------------------------------------------------------------------------
# ---------------------------- LEVELS -----------------------------------------
# -----------------------------------------------------------------------------

languages::get_allowed_levels() {
    local lang
    lang=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local var_name="ALLOWED_LEVELS_${lang}"
    echo "${!var_name}"
}

# Validates that the provided level (build or prod) is allowed for the specified language.
languages::validate_level() {
    local language="$1"
    local level="$2"
    local allowed_levels

    allowed_levels=$(get_allowed_levels_for_language "$language")
    if [ -z "$allowed_levels" ]; then
        echo "Error: Language '$language' does not support levels." >&2
        echo "Run '${ROOT_SCRIPT} new ${language} --show-dependencies' to see supported levels and dependencies" >&2
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
