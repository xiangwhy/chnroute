#!/usr/bin/env bash
# shellcheck shell=bash

# Common initialization for chnroute scripts.
# Source this file at the beginning of each main script to set up the environment.

# Initialize script paths and source all library modules
# Usage: source "${LIB_DIR}/init.sh" || exit 1
# Requires: SCRIPT_DIR and LIB_DIR to be set before sourcing

# Guard to prevent double-initialization
_CHNROUTE_INITIALIZED=${_CHNROUTE_INITIALIZED:-0}

init_chnroute() {
    # Skip if already initialized
    if [[ "$_CHNROUTE_INITIALIZED" -eq 1 ]]; then
        return 0
    fi

    # Validate required variables
    if [[ -z "${SCRIPT_DIR:-}" ]]; then
        echo "ERROR: SCRIPT_DIR is not set" >&2
        return 1
    fi
    if [[ -z "${LIB_DIR:-}" ]]; then
        echo "ERROR: LIB_DIR is not set" >&2
        return 1
    fi

    # Source library modules in dependency order
    local modules=(
        "config.sh"
        "logger.sh"
        "temp.sh"
        "error.sh"
        "platform.sh"
        "dependencies.sh"
        "resources.sh"
        "validation.sh"
        "downloader.sh"
        "processor.sh"
    )

    local module
    for module in "${modules[@]}"; do
        local module_path="${LIB_DIR}/${module}"
        if [[ ! -f "$module_path" ]]; then
            echo "ERROR: Library module not found: ${module_path}" >&2
            return 1
        fi
        # shellcheck source=/dev/null
        . "$module_path"
    done

    _CHNROUTE_INITIALIZED=1
    return 0
}

# Initialize logging and create temporary directory
# Usage: init_base_environment
init_base_environment() {
    initialize_logging
    create_temp_root
    trap 'cleanup_temp_root' EXIT INT TERM
    setup_error_trap
    setup_platform_specific
    check_dependencies_detailed
}

# Full initialization for scripts that need resources and processor
# Usage: init_full_environment
init_full_environment() {
    init_base_environment
    check_system_resources
}
