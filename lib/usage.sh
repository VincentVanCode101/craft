#!/usr/bin/env bash
# usage.sh

source "$(dirname "${BASH_SOURCE[0]}")/languages.sh"

usage::general() {
    # ANSI escape codes for styling
    BOLD="\033[1m"
    RESET="\033[0m"
    UNDERLINE="\033[4m"

    echo -e "${BOLD}USAGE${RESET}"
    echo -e "  ${ROOT_SCRIPT} [OPTIONS] COMMAND [ARG]"
    echo

    echo -e "${BOLD}GLOBAL OPTIONS${RESET}"
    echo -e "  ${BOLD}-h, --help${RESET}             Display this help message."
    echo

    echo -e "${BOLD}COMMANDS${RESET}"
    echo -e "  ${UNDERLINE}new${RESET} <language>         Create a new project for the specified language."
    echo -e "  ${UNDERLINE}new --help${RESET}             Display help for the 'new' command (see supported languages, flags, etc.)."
    echo

    echo -e "${BOLD}FLAGS FOR THE 'new' COMMAND${RESET}"
    echo
    echo -e "${BOLD}OPERATION MODIFIER FLAGS${RESET}"
    echo -e "  ${BOLD}--dependencies=<list>${RESET}  Comma-separated list of dependencies to include."
    echo
    echo -e "  ${BOLD}--level=<build|prod>${RESET}   Specify the project level. Allowed values are 'build' or 'prod'."
    echo -e "                         This flag controls the complexity of the generated setup:"
    echo -e "                           * ${BOLD}build${RESET}  may include additional tools (e.g., pre-commit hooks)"
    echo -e "                                      for a robust development experience."
    echo -e "                           * ${BOLD}prod${RESET}   generates production-ready features (e.g., multi-stage"
    echo -e "                                      Dockerfile builds) for deployment."
    echo -e "                         (If omitted, a default level is assumed -- typically a basic language-runtime container.)"
    echo
    echo -e "  ${BOLD}--path=<folder>${RESET}        Specify the directory where the project should be created."
    echo -e "                         If not provided, a folder will be created using the naming"
    echo -e "                         convention: ${BOLD}craft-<language>[-<level>][-<dependencies>]${RESET}."
    echo -e "                         For example, a Java project with prod level and dependencies"
    echo -e "                         mariadb and ncurs (craft new java --dependencies=mariadb,ncurs --level=prod)"
    echo -e "                         will be created in a folder named: ${BOLD}craft-java-prod-mariadb-ncurs${RESET}"
    echo

    echo -e "${BOLD}INFORMATIVE OUTPUT FLAGS FOR THE 'new' COMMAND${RESET}"
    echo -e "  ${BOLD}--show-dependencies${RESET}    Show supported dependencies and allowed levels for the specified language."
    echo -e "                         e.g.: ${ROOT_SCRIPT} new java --show-dependencies"
    echo -e "  ${BOLD}-h, --help${RESET}             Display help for the 'new' command"
    echo

    echo -e "${BOLD}USAGE EXAMPLES${RESET}"
    echo -e "  ${ROOT_SCRIPT} -h"
    echo -e "  ${ROOT_SCRIPT} new -h"
    echo -e "  ${ROOT_SCRIPT} new go"
    echo -e "  ${ROOT_SCRIPT} new java --dependencies=mariadb,ncurs --level=prod --path=~/projects/java_app"
    echo -e "  ${ROOT_SCRIPT} new java --show-dependencies"
    exit 0
}

usage::new_command() {
    # ANSI escape codes for styling
    BOLD="\033[1m"
    RESET="\033[0m"
    UNDERLINE="\033[4m"

    echo -e "${BOLD}CREATE A NEW PROJECT${RESET}"
    echo

    echo -e "${BOLD}USAGE${RESET}"
    echo -e "  ${ROOT_SCRIPT} ${UNDERLINE}new${RESET} <language> [FLAGS]"
    echo

    echo -e "${BOLD}SUPPORTED LANGUAGES${RESET}"
    echo -e "  $(languages::print_available)"
    echo

    echo -e "${BOLD}OPERATION MODIFIER FLAGS${RESET}"
    echo -e "  ${BOLD}-d, --dependencies${RESET} string   Specify the dependencies or project type (e.g., --dependencies=maven,spring)"
    echo -e "  ${BOLD}-l, --level${RESET} string          Specify the project level (allowed values: ${BOLD}build, prod${RESET})"
    echo -e "  ${BOLD}-p, --path${RESET} string           Specify a path for the new project (last segment is the project name)"
    echo

    echo -e "${BOLD}INFORMATIVE OUTPUT FLAGS${RESET}"
    echo -e "  ${BOLD}--show-dependencies${RESET}         Show supported dependencies and allowed levels for the specified language."
    echo -e "  ${BOLD}-h, --help${RESET}                  Display help for the 'new' command."
    echo

    echo -e "${BOLD}USAGE EXAMPLES${RESET}"
    echo -e "  ${ROOT_SCRIPT} new java --show-dependencies"
    echo -e "  ${ROOT_SCRIPT} new java --dependencies=mariadb,ncurs --level=prod --path=~/projects/java_app"
    exit 0
}
