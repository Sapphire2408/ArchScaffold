#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAFFOLD_SCRIPT="$SCRIPT_DIR/../scaffold.sh"
TEST_ENV_DIR="$SCRIPT_DIR/test_env"

setup() {
    mkdir -p "$TEST_ENV_DIR"
}

teardown() {
    rm -rf "$TEST_ENV_DIR"
}

pass() {
    echo -e "\033[32m[PASS]\033[0m $1"
}

fail() {
    echo -e "\033[31m[FAIL]\033[0m $1"
    teardown
    exit 1
}

# 1. Test Help Option
test_help() {
    local output
    output=$("$SCAFFOLD_SCRIPT" --help)
    if echo "$output" | grep -q "Usage:"; then
        pass "Help message is displayed"
    else
        fail "Help message is not displayed"
    fi
}

# 2. Test Invalid Option
test_invalid_option() {
    local output
    output=$("$SCAFFOLD_SCRIPT" --invalid 2>&1 || true)
    if echo "$output" | grep -q "Unknown option"; then
        pass "Invalid option throws an error"
    else
        fail "Invalid option does not throw an error"
    fi
}

# 3. Test Missing Project Name (Interactive Fallback)
test_missing_project_name() {
    local output
    output=$(echo -e "\n" | "$SCAFFOLD_SCRIPT" 2>&1 || true)
    if echo "$output" | grep -q "Project name cannot be empty"; then
        pass "Missing project name validation works"
    else
        fail "Missing project name validation failed. Output: $output"
    fi
}

# 4. Test Dry Run (Should not create directories)
test_dry_run() {
    cd "$TEST_ENV_DIR"
    local output
    output=$("$SCAFFOLD_SCRIPT" -n dry_test_app -a clean --dry-run 2>&1)
    if [ ! -d "dry_test_app" ]; then
        pass "Dry run does not create directories"
    else
        fail "Dry run incorrectly created directories"
    fi
    cd "$SCRIPT_DIR"
}

# 5. Test Invalid Architecture
test_invalid_arch() {
    cd "$TEST_ENV_DIR"
    local output
    output=$("$SCAFFOLD_SCRIPT" -n app_invalid -a missing_arch 2>&1 || true)
    if echo "$output" | grep -q "not found"; then
        pass "Invalid architecture throws an error"
    else
        fail "Invalid architecture validation failed"
    fi
    cd "$SCRIPT_DIR"
}

# 6. Test Successful Scaffold
test_successful_scaffold() {
    cd "$TEST_ENV_DIR"
    local output
    output=$("$SCAFFOLD_SCRIPT" -n real_test_app -a clean 2>&1)
    
    if [ -d "real_test_app/domain" ] && [ -f "real_test_app/domain/README.md" ] && [ -d "real_test_app/infrastructure/database" ]; then
        pass "Scaffolding creates correct directories and files"
    else
        fail "Scaffolding did not create expected directories/files"
    fi
    cd "$SCRIPT_DIR"
}

# Execute tests
echo "Running scaffold.sh Unit Tests..."
echo "---------------------------------"
setup
test_help
test_invalid_option
test_missing_project_name
test_dry_run
test_invalid_arch
test_successful_scaffold
teardown
echo "---------------------------------"
echo "All tests passed successfully!"
