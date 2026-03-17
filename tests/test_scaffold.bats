#!/usr/bin/env bats

setup() {
    export SCAFFOLD_SCRIPT="$BATS_TEST_DIRNAME/../scaffold.sh"
    export TEST_ENV_DIR="$BATS_TEST_DIRNAME/test_env"
    mkdir -p "$TEST_ENV_DIR"
}

teardown() {
    rm -rf "$TEST_ENV_DIR"
}

@test "Help message is displayed" {
    run "$SCAFFOLD_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "Invalid option throws an error" {
    run "$SCAFFOLD_SCRIPT" --invalid
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]]
}

@test "Missing project name validation works" {
    run bash -c "echo -e '\n' | \"$SCAFFOLD_SCRIPT\""
    [ "$status" -eq 1 ]
    [[ "$output" == *"Project name cannot be empty"* ]]
}

@test "Dry run does not create directories" {
    cd "$TEST_ENV_DIR"
    run "$SCAFFOLD_SCRIPT" -n dry_test_app -a clean --dry-run
    [ "$status" -eq 0 ]
    [ ! -d "dry_test_app" ]
}

@test "Invalid architecture throws an error" {
    cd "$TEST_ENV_DIR"
    run "$SCAFFOLD_SCRIPT" -n app_invalid -a missing_arch
    [ "$status" -eq 1 ]
    [[ "$output" == *"not found"* ]]
}

@test "Scaffolding creates correct directories and files without artifacts" {
    cd "$TEST_ENV_DIR"
    run "$SCAFFOLD_SCRIPT" -n real_test_app -a clean
    [ "$status" -eq 0 ]
    [ -d "real_test_app/domain" ]
    [ -f "real_test_app/domain/README.md" ]
    [ -d "real_test_app/infrastructure/database" ]
    
    # Check for carriage return artifacts
    run find real_test_app -type d -name "*$(printf '\r')"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "--list flag shows available templates" {
    run "$SCAFFOLD_SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *"clean"* ]]
    [[ "$output" == *"hexagonal"* ]]
    [[ "$output" == *"cqrs"* ]]
}

@test "Path traversal in name is rejected (../bad)" {
    run "$SCAFFOLD_SCRIPT" -n "../bad" -a clean
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid project name"* ]]
}

@test "Semicolon in name is rejected (foo;bar)" {
    run "$SCAFFOLD_SCRIPT" -n "foo;bar" -a clean
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid project name"* ]]
}

@test "Space in name is rejected (foo bar)" {
    run "$SCAFFOLD_SCRIPT" -n "foo bar" -a clean
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid project name"* ]]
}

@test "--force flag overwrites existing directory" {
    cd "$TEST_ENV_DIR"
    mkdir -p force_test_app
    run "$SCAFFOLD_SCRIPT" -n force_test_app -a clean --force
    [ "$status" -eq 0 ]
    [ -d "force_test_app/domain" ]
    [[ "$output" == *"Overwriting"* ]]
}

@test "Overwrite is blocked without --force" {
    cd "$TEST_ENV_DIR"
    mkdir -p blocked_test_app
    run "$SCAFFOLD_SCRIPT" -n blocked_test_app -a clean
    [ "$status" -eq 1 ]
    [[ "$output" == *"already exists"* ]]
}

@test "Generated README.md contains expected headings" {
    cd "$TEST_ENV_DIR"
    run "$SCAFFOLD_SCRIPT" -n readme_check_app -a clean
    [ "$status" -eq 0 ]
    run grep -q "# Domain Layer" "readme_check_app/domain/README.md"
    [ "$status" -eq 0 ]
}

@test "All templates scaffold successfully" {
    cd "$TEST_ENV_DIR"
    for f in "$BATS_TEST_DIRNAME"/../templates/*.txt; do
        if [ -f "$f" ]; then
            tpl_name=$(basename "$f" .txt)
            proj_name="tpl_test_${tpl_name}"
            
            run "$SCAFFOLD_SCRIPT" -n "$proj_name" -a "$tpl_name"
            [ "$status" -eq 0 ]
            [ -d "$proj_name" ]
        fi
    done
}

@test "--verbose flag shows detailed creation output" {
    cd "$TEST_ENV_DIR"
    run "$SCAFFOLD_SCRIPT" -n verbose_app -a clean --verbose
    [ "$status" -eq 0 ]
    [[ "$output" == *"✓"* ]]
}

@test "Root README.md is generated with architecture name" {
    cd "$TEST_ENV_DIR"
    run "$SCAFFOLD_SCRIPT" -n root_readme_app -a clean
    [ "$status" -eq 0 ]
    [ -f "root_readme_app/README.md" ]
    run grep -q "clean" "root_readme_app/README.md"
    [ "$status" -eq 0 ]
}

@test "--output-dir creates project in specified location" {
    cd "$TEST_ENV_DIR"
    mkdir -p custom_output
    run "$SCAFFOLD_SCRIPT" -n outdir_app -a clean --output-dir custom_output
    [ "$status" -eq 0 ]
    [ -d "custom_output/outdir_app/domain" ]
}
