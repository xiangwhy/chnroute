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

create_temp_root

test_validate_file_exists() {
    local test_file="${TMP_DIR}/test_file.txt"

    # Test: file does not exist
    if validate_file_exists "$test_file" "Test file"; then
        printf "✗ FAIL: %s\n" "validate_file_exists should fail for missing file"
        ((TESTS_FAILED++)) || true
    else
        printf "✓ PASS: %s\n" "validate_file_exists fails for missing file"
        ((TESTS_PASSED++)) || true
    fi

    # Test: file exists
    echo "test content" > "$test_file"
    if validate_file_exists "$test_file" "Test file"; then
        printf "✓ PASS: %s\n" "validate_file_exists passes for existing file"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "validate_file_exists should pass for existing file"
        ((TESTS_FAILED++)) || true
    fi
}

test_validate_domain_list() {
    local valid_file="${TMP_DIR}/valid_domains.txt"
    local invalid_file="${TMP_DIR}/invalid_domains.txt"

    # Test: valid domains
    cat > "$valid_file" <<EOF
example.com
sub.domain.org
test-site.co.uk
EOF
    if validate_domain_list "$valid_file" "Valid domains"; then
        printf "✓ PASS: %s\n" "validate_domain_list passes for valid domains"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "validate_domain_list should pass for valid domains"
        ((TESTS_FAILED++)) || true
    fi

    # Test: invalid domains (should warn but not fail)
    cat > "$invalid_file" <<EOF
valid.com
-invalid.start
also-valid.net
EOF
    if validate_domain_list "$invalid_file" "Invalid domains"; then
        printf "✓ PASS: %s\n" "validate_domain_list returns 0 even with invalid domains (warnings only)"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "validate_domain_list should return 0 (warnings only)"
        ((TESTS_FAILED++)) || true
    fi
}

test_validate_directory_exists() {
    local test_dir="${TMP_DIR}/test_dir"

    # Test: directory does not exist
    if validate_directory_exists "$test_dir" "Test dir"; then
        printf "✗ FAIL: %s\n" "validate_directory_exists should fail for missing dir"
        ((TESTS_FAILED++)) || true
    else
        printf "✓ PASS: %s\n" "validate_directory_exists fails for missing dir"
        ((TESTS_PASSED++)) || true
    fi

    # Test: directory exists
    mkdir -p "$test_dir"
    if validate_directory_exists "$test_dir" "Test dir"; then
        printf "✓ PASS: %s\n" "validate_directory_exists passes for existing dir"
        ((TESTS_PASSED++)) || true
    else
        printf "✗ FAIL: %s\n" "validate_directory_exists should pass for existing dir"
        ((TESTS_FAILED++)) || true
    fi
}

test_validate_file_exists
test_validate_domain_list
test_validate_directory_exists

cleanup_temp_root
