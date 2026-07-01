#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB_DIR="${PROJECT_ROOT}/lib"

if [[ -z "${TESTS_PASSED+x}" ]]; then
    # shellcheck source=tests/test_framework.sh
    . "${SCRIPT_DIR}/test_framework.sh"
fi

# shellcheck source=lib/init.sh
. "${LIB_DIR}/init.sh"
if ! init_chnroute; then
    echo "ERROR: Failed to initialize chnroute libraries" >&2
    exit 1
fi

# Reduce noise during tests
LOG_LEVEL=$LOG_LEVEL_ERROR

test_create_temp_root() {
    # Save original TMP_DIR
    local orig_tmp="${TMP_DIR:-}"

    create_temp_root

    # Check TMP_DIR is set
    if [[ -n "${TMP_DIR:-}" ]]; then
        printf "✓ PASS: %s (got: %s)\n" "create_temp_root sets TMP_DIR" "$TMP_DIR"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "create_temp_root should set TMP_DIR"
        ((TESTS_FAILED++)) || true
        return
    fi

    # Check TMP_DIR is a directory
    if [[ -d "$TMP_DIR" ]]; then
        printf "✓ PASS: %s\n" "TMP_DIR is a directory"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "TMP_DIR should be a directory"
        ((TESTS_FAILED++)) || true
    fi

    # Check subdirectories exist
    if [[ -d "${TMP_DIR}/processing" ]] && [[ -d "${TMP_DIR}/cache" ]]; then
        printf "✓ PASS: %s\n" "TMP_DIR subdirectories created"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "TMP_DIR subdirectories should exist"
        ((TESTS_FAILED++)) || true
    fi

    # Cleanup for next test
    cleanup_temp_root
    TMP_DIR="$orig_tmp"
}

test_cleanup_temp_root() {
    create_temp_root
    local temp_dir="$TMP_DIR"

    # Verify it exists
    if [[ -d "$temp_dir" ]]; then
        printf "✓ PASS: %s\n" "temp dir exists before cleanup"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "temp dir should exist before cleanup"
        ((TESTS_FAILED++)) || true
        return
    fi

    cleanup_temp_root

    # Verify it's removed
    if [[ ! -d "$temp_dir" ]]; then
        printf "✓ PASS: %s\n" "temp dir removed after cleanup"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "temp dir should be removed after cleanup"
        ((TESTS_FAILED++)) || true
    fi
}

test_create_temp_root
test_cleanup_temp_root
