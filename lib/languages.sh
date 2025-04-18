#!/usr/bin/env bash
# languages.sh

export AVAILABLE_LANGUAGES=("go" "java" "rust" "php", "r")

GO_DEPENDENCIES=("")
JAVA_DEPENDENCIES=("quarkus")
RUST_DEPENDENCIES=("")
PHP_DEPENDENCIES=("symfony")
R_DEPENDENCIES=("")

export ALLOWED_LEVELS_go=""
export ALLOWED_LEVELS_java=""
export ALLOWED_LEVELS_rust=""
export ALLOWED_LEVELS_php=""
export ALLOWED_LEVELS_=""
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
        logger::error "Language '$lang' is not supported."
        logger::notice "Supported languages are: $(languages::print_available)"

        exit 1
    fi
}

# -----------------------------------------------------------------------------
# ---------------------------- DEPENDENCIES -----------------------------------
# -----------------------------------------------------------------------------

languages::get_allowed_dependencies() {
    local lang
    lang=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$lang" in

    go) echo "${GO_DEPENDENCIES[*]}" ;;
    java) echo "${JAVA_DEPENDENCIES[*]}" ;;
    rust) echo "${RUST_DEPENDENCIES[*]}" ;;
    php) echo "${PHP_DEPENDENCIES[*]}" ;;
    r) echo "${PHP_DEPENDENCIES[*]}" ;;
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
        logger::error "Language '$language' does not support dependencies."
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
            logger::error "Dependency '$dep' is not allowed for language '$language'."
            logger::notice "Allowed dependencies: ${allowed_deps[*]}"
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

    if [[ -v $var_name ]]; then
        echo "${!var_name}"
    else
        echo ""
    fi
}

languages::validate_level() {
    local language="$1"
    local level="$2"
    local allowed_levels

    allowed_levels=$(languages::get_allowed_levels "$language")
    if [ -z "$allowed_levels" ]; then
        logger::error "Language '$language' does not support levels." >&2
        logger::notice "Run '${ROOT_SCRIPT} new ${language} --show-dependencies' to see supported levels and dependencies." >&2
        exit 1
    fi

    for allowed in $allowed_levels; do
        if [ "$level" == "$allowed" ]; then
            return 0
        fi
    done

    logger::error "Invalid level '$level' for language '$language'." >&2
    logger::notice "Allowed levels: $allowed_levels" >&2
    exit 1
}
