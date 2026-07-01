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

test_detect_platform() {
    local platform
    platform=$(detect_platform)

    if [[ -n "$platform" ]]; then
        printf "✓ PASS: %s (got: %s)\n" "detect_platform returns non-empty value" "$platform"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "detect_platform should return non-empty value"
        ((TESTS_FAILED++)) || true
    fi

    # Check it matches expected format
    if [[ "$platform" =~ ^(macos|linux|bsd|unknown)- ]]; then
        printf "✓ PASS: %s\n" "detect_platform returns valid format"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s (got: %s)\n" "detect_platform should return valid format" "$platform"
        ((TESTS_FAILED++)) || true
    fi
}

test_setup_platform_specific() {
    setup_platform_specific

    # Check BASE64_DECODE is set
    if [[ -n "${BASE64_DECODE:-}" ]]; then
        printf "✓ PASS: %s (got: %s)\n" "BASE64_DECODE is set" "$BASE64_DECODE"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "BASE64_DECODE should be set"
        ((TESTS_FAILED++)) || true
    fi

    # Check SED_ERES is set
    if [[ -n "${SED_ERES:-}" ]]; then
        printf "✓ PASS: %s (got: %s)\n" "SED_ERES is set" "$SED_ERES"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "SED_ERES should be set"
        ((TESTS_FAILED++)) || true
    fi

    # Check DATE_FORMAT is set
    if [[ -n "${DATE_FORMAT:-}" ]]; then
        printf "✓ PASS: %s\n" "DATE_FORMAT is set"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "DATE_FORMAT should be set"
        ((TESTS_FAILED++)) || true
    fi
}

test_detect_platform
test_setup_platform_specific
