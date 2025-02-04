# languages.sh

AVAILABLE_LANGUAGES=("go" "java")

# Allowed dependencies for Go projects
GO_DEPENDENCIES=("ncurs")
JAVA_DEPENDENCIES=("")

ALLOWED_LEVELS_go="build"
ALLOWED_LEVELS_java="build prod"

print_available_languages() {
    echo "${AVAILABLE_LANGUAGES[*]}" | tr ' ' ', '
}

# Returns the allowed dependencies for the given language
get_allowed_dependencies() {
    local lang
    lang=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$lang" in
    go)
        echo "${GO_DEPENDENCIES[*]}"
        ;;

    java)
        echo "${JAVA_DEPENDENCIES[*]}"
        ;;
    *)
        echo ""
        ;;
    esac
}

get_allowed_levels() {
    local lang
    lang=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local var_name="ALLOWED_LEVELS_${lang}"
    echo "${!var_name}"
}
