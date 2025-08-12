#!/bin/bash

# DCP Test Script
# Simple tests to verify dcp functionality

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test configuration
TEST_DIR="/tmp/dcp-test-$$"
DCP_SCRIPT="./dcp"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Setup test environment
setup_test() {
    log_info "Setting up test environment..."

    # Create test directory
    mkdir -p "$TEST_DIR"

    # Ensure dcp script exists and is executable
    if [[ ! -f "$DCP_SCRIPT" ]]; then
        log_error "DCP script not found: $DCP_SCRIPT"
        exit 1
    fi

    if [[ ! -x "$DCP_SCRIPT" ]]; then
        log_error "DCP script not executable: $DCP_SCRIPT"
        exit 1
    fi

    # Clean any existing cache for testing
    export HOME="$TEST_DIR"

    log_success "Test environment setup complete"
}

# Cleanup test environment
cleanup_test() {
    log_info "Cleaning up test environment..."
    rm -rf "$TEST_DIR"
    log_success "Cleanup complete"
}

# Test basic help functionality
test_help() {
    log_info "Testing help functionality..."

    if "$DCP_SCRIPT" --help >/dev/null 2>&1; then
        log_success "Help command works"
    else
        log_error "Help command failed"
    fi
}

# Test cache operations
test_cache_operations() {
    log_info "Testing cache operations..."

    # Test adding host to cache
    if "$DCP_SCRIPT" --add-host "testuser@testhost" >/dev/null 2>&1; then
        log_success "Add host to cache works"
    else
        log_error "Add host to cache failed"
        return
    fi

    # Test listing hosts
    if "$DCP_SCRIPT" --list-hosts | grep -q "testuser@testhost"; then
        log_success "List hosts shows added host"
    else
        log_error "List hosts doesn't show added host"
    fi

    # Test adding duplicate host (should not duplicate)
    "$DCP_SCRIPT" --add-host "testuser@testhost" >/dev/null 2>&1
    local host_count
    host_count=$("$DCP_SCRIPT" --list-hosts | grep -c "testuser@testhost" || true)
    if [[ "$host_count" -eq 1 ]]; then
        log_success "Duplicate host not added to cache"
    else
        log_error "Duplicate host was added to cache"
    fi

    # Test removing host
    if "$DCP_SCRIPT" --remove-host "testuser@testhost" >/dev/null 2>&1; then
        log_success "Remove host from cache works"
    else
        log_error "Remove host from cache failed"
    fi

    # Test clearing cache
    "$DCP_SCRIPT" --add-host "user1@host1" >/dev/null 2>&1
    "$DCP_SCRIPT" --add-host "user2@host2" >/dev/null 2>&1

    if "$DCP_SCRIPT" --clear-cache >/dev/null 2>&1; then
        log_success "Clear cache works"
    else
        log_error "Clear cache failed"
    fi

    # Verify cache is empty
    local cache_file="$HOME/.cache/dcp/hosts"
    if [[ -f "$cache_file" && ! -s "$cache_file" ]]; then
        log_success "Cache is empty after clear"
    else
        log_error "Cache is not empty after clear"
    fi
}

# Test host extraction
test_host_extraction() {
    log_info "Testing host extraction from arguments..."

    # Create a test file
    echo "test content" > "$TEST_DIR/testfile.txt"

    # Test with dry run by checking if host gets cached
    # We'll simulate this by checking if the script would cache the host
    # (We can't actually run scp without real hosts)

    # This test would require mocking scp, so we'll skip for now
    log_warning "Host extraction test skipped (requires scp mocking)"
}

# Test script structure and syntax
test_script_syntax() {
    log_info "Testing script syntax..."

    if bash -n "$DCP_SCRIPT"; then
        log_success "Script syntax is valid"
    else
        log_error "Script has syntax errors"
    fi
}

# Test completion scripts syntax
test_completion_syntax() {
    log_info "Testing completion scripts syntax..."

    if [[ -f "dcp-completion.bash" ]]; then
        if bash -n "dcp-completion.bash"; then
            log_success "Bash completion syntax is valid"
        else
            log_error "Bash completion has syntax errors"
        fi
    else
        log_warning "Bash completion script not found"
    fi

    if [[ -f "dcp-completion.zsh" ]]; then
        if command -v zsh >/dev/null 2>&1; then
            if zsh -n "dcp-completion.zsh" 2>/dev/null; then
                log_success "Zsh completion syntax is valid"
            else
                log_error "Zsh completion has syntax errors"
            fi
        else
            log_warning "Zsh not available for testing"
        fi
    else
        log_warning "Zsh completion script not found"
    fi
}

# Test installation script
test_install_script() {
    log_info "Testing installation script..."

    if [[ -f "install.sh" ]]; then
        if bash -n "install.sh"; then
            log_success "Installation script syntax is valid"
        else
            log_error "Installation script has syntax errors"
        fi

        # Test help option
        if ./install.sh --help >/dev/null 2>&1; then
            log_success "Installation script help works"
        else
            log_error "Installation script help failed"
        fi
    else
        log_error "Installation script not found"
    fi
}

# Main test runner
run_tests() {
    echo -e "${BLUE}DCP Test Suite${NC}"
    echo "=============="
    echo

    setup_test

    # Run all tests
    test_script_syntax
    test_completion_syntax
    test_install_script
    test_help
    test_cache_operations
    test_host_extraction

    # Summary
    echo
    echo -e "${BLUE}Test Summary${NC}"
    echo "============"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

    cleanup_test

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed! 🎉${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed! 😞${NC}"
        exit 1
    fi
}

# Handle command line arguments
case "$1" in
    --help|-h)
        echo "DCP Test Suite"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help"
        echo
        echo "This script runs a series of tests to verify DCP functionality."
        exit 0
        ;;
    *)
        run_tests
        ;;
esac
