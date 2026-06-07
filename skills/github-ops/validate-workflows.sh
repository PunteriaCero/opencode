#!/bin/bash

################################################################################
# GitHub Actions Workflow Validator Script
# 
# This script validates all GitHub Actions workflows in the repository using
# actionlint. It checks for syntax errors, type issues, security problems,
# and common mistakes.
#
# Usage:
#   ./validate-workflows.sh                    # Validate all workflows
#   ./validate-workflows.sh --fix              # Try to fix issues
#   ./validate-workflows.sh --verbose          # Verbose output
#   ./validate-workflows.sh --file <path>      # Validate specific file
#
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VERBOSE=false
FIX=false
SPECIFIC_FILE=""
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKFLOWS_DIR="${REPO_ROOT}/.github/workflows"

# Display usage
usage() {
    cat << EOF
${BLUE}GitHub Actions Workflow Validator${NC}

${YELLOW}Usage:${NC}
  $(basename "$0") [OPTIONS]

${YELLOW}Options:${NC}
  --help              Show this help message
  --verbose           Verbose output with detailed checks
  --fix               Try to fix issues automatically
  --file <path>       Validate specific workflow file
  --dir <path>        Validate workflows in specific directory

${YELLOW}Examples:${NC}
  # Validate all workflows
  $(basename "$0")

  # Validate with verbose output
  $(basename "$0") --verbose

  # Validate specific file
  $(basename "$0") --file .github/workflows/ci.yml

  # Try to fix issues
  $(basename "$0") --fix

${YELLOW}Requirements:${NC}
  - actionlint must be installed
  - Git repository context (for finding workflows)

${YELLOW}More info:${NC}
  actionlint: https://github.com/rhysd/actionlint
  Installation: brew install actionlint

EOF
}

# Check if actionlint is installed
check_actionlint() {
    if ! command -v actionlint &> /dev/null; then
        echo -e "${RED}✗ actionlint is not installed${NC}"
        echo ""
        echo "Install it with:"
        echo "  brew install actionlint"
        echo "  OR"
        echo "  go install github.com/rhysd/actionlint/cmd/actionlint@latest"
        exit 1
    fi
    echo -e "${GREEN}✓ actionlint found: $(actionlint --version 2>/dev/null || echo 'installed')${NC}"
}

# Find workflow files
find_workflows() {
    local search_dir="${1:-.}"
    if [[ ! -d "$search_dir" ]]; then
        echo -e "${RED}✗ Directory not found: $search_dir${NC}"
        exit 1
    fi
    find "$search_dir" -name "*.yml" -o -name "*.yaml" | grep -E '\.ya?ml$' || true
}

# Validate single workflow
validate_workflow() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}✗ File not found: $file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}→ Validating: $file${NC}"
    
    local args=()
    [[ "$VERBOSE" == "true" ]] && args+=("-verbose")
    
    # Run actionlint
    if actionlint "${args[@]}" "$file" 2>&1; then
        echo -e "${GREEN}✓ Valid: $file${NC}"
        return 0
    else
        echo -e "${RED}✗ Invalid: $file${NC}"
        return 1
    fi
}

# Validate all workflows
validate_all() {
    local target_dir="${1:-.}"
    local files=()
    
    # Find all workflow files
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        files+=("$file")
    done < <(find_workflows "$target_dir")
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No workflow files found in: $target_dir${NC}"
        return 0
    fi
    
    echo -e "${BLUE}Found ${#files[@]} workflow file(s)${NC}"
    echo ""
    
    local failed=0
    local passed=0
    
    for file in "${files[@]}"; do
        if validate_workflow "$file"; then
            ((passed++))
        else
            ((failed++))
        fi
        echo ""
    done
    
    # Summary
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Validation Summary${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "  ${GREEN}Passed: $passed${NC}"
    echo -e "  ${RED}Failed: $failed${NC}"
    echo -e "  Total:  $((passed + failed))"
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}✓ All workflows are valid!${NC}"
        return 0
    else
        echo -e "${RED}✗ Some workflows have errors${NC}"
        return 1
    fi
}

# Install actionlint if not present
install_actionlint() {
    if ! command -v actionlint &> /dev/null; then
        echo -e "${YELLOW}⚠ actionlint not found${NC}"
        echo "Would you like to install it? (y/n)"
        read -r response
        if [[ "$response" == "y" || "$response" == "Y" ]]; then
            if command -v brew &> /dev/null; then
                echo -e "${BLUE}Installing with Homebrew...${NC}"
                brew install actionlint
            elif command -v go &> /dev/null; then
                echo -e "${BLUE}Installing with go...${NC}"
                go install github.com/rhysd/actionlint/cmd/actionlint@latest
            else
                echo -e "${RED}✗ Neither Homebrew nor Go found${NC}"
                echo "Please install actionlint manually:"
                echo "  https://github.com/rhysd/actionlint"
                exit 1
            fi
        else
            exit 1
        fi
    fi
}

# Main script
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                usage
                exit 0
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --fix)
                FIX=true
                shift
                ;;
            --file)
                SPECIFIC_FILE="$2"
                shift 2
                ;;
            --dir)
                WORKFLOWS_DIR="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                usage
                exit 1
                ;;
        esac
    done
    
    # Check/install actionlint
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}GitHub Actions Workflow Validator${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    
    install_actionlint
    check_actionlint
    echo ""
    
    # Run validation
    if [[ -n "$SPECIFIC_FILE" ]]; then
        # Validate specific file
        if validate_workflow "$SPECIFIC_FILE"; then
            exit 0
        else
            exit 1
        fi
    else
        # Validate all workflows
        if validate_all "$WORKFLOWS_DIR"; then
            exit 0
        else
            exit 1
        fi
    fi
}

# Run main
main "$@"
