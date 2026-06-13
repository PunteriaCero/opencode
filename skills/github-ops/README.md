# GitHub Operations Skill

## Overview

This skill directory contains resources for GitHub operations with secure authentication using `GHUB_PAT`.

## Contents

- **SKILL.md** - Main skill documentation
- **validate-workflows.sh** - Script to validate GitHub Actions workflows

## Workflow Validation

### Quick Start

```bash
# Validate all workflows in your repository
./validate-workflows.sh

# Validate with verbose output
./validate-workflows.sh --verbose

# Validate specific workflow
./validate-workflows.sh --file .github/workflows/ci.yml
```

### What It Does

The validation script uses **actionlint**, a powerful static checker for GitHub Actions:

- ✓ Checks YAML syntax
- ✓ Validates workflow structure
- ✓ Type checks `${{ }}` expressions
- ✓ Verifies action inputs/outputs
- ✓ Detects security issues (script injection, credentials)
- ✓ Validates reusable workflows
- ✓ Checks dependencies and job flows
- ✓ Validates runner labels
- ✓ Checks cron syntax

### Installation

The script can automatically install actionlint if not present:

```bash
# Homebrew
brew install actionlint

# Go
go install github.com/rhysd/actionlint/cmd/actionlint@latest

# Docker
docker run --rm -v "$(pwd):/app" rhysd/actionlint:latest
```

### Usage Examples

```bash
# Basic validation
./validate-workflows.sh

# Verbose output (detailed checks)
./validate-workflows.sh --verbose

# Check specific file
./validate-workflows.sh --file .github/workflows/ci.yml

# Check different directory
./validate-workflows.sh --dir ./custom/.github/workflows

# Show help
./validate-workflows.sh --help
```

### Integration with Git Workflow

```bash
# Before committing workflows
./validate-workflows.sh

# If valid, commit and push
git add .github/workflows/
git commit -m "ci: add new workflow"
git push

# If invalid, fix the issues reported
# Then try validation again
```

### CI/CD Integration

Add to your GitHub Actions workflow:

```yaml
name: Validate Workflows

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate workflows
        run: |
          # Install actionlint
          go install github.com/rhysd/actionlint/cmd/actionlint@latest
          
          # Run validation
          actionlint
```

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
./skills/github-ops/validate-workflows.sh
if [ $? -ne 0 ]; then
    echo "Workflow validation failed. Commit aborted."
    exit 1
fi
```

## Resources

- [actionlint GitHub](https://github.com/rhysd/actionlint)
- [actionlint Documentation](https://github.com/rhysd/actionlint/tree/main/docs)
- [actionlint Playground](https://rhysd.github.io/actionlint/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Troubleshooting

### Script not found

Make sure the script is executable:

```bash
chmod +x ./skills/github-ops/validate-workflows.sh
```

### actionlint not installed

The script will prompt to install. Or install manually:

```bash
brew install actionlint
```

### Validation errors

See the actionlint documentation for detailed error messages:

https://github.com/rhysd/actionlint/blob/main/docs/checks.md

## Best Practices

1. **Always validate before pushing** - Run the script before committing workflow changes
2. **Use actionlint in CI** - Add workflow validation to your CI pipeline
3. **Set up pre-commit hook** - Prevent invalid workflows from being committed
4. **Keep workflows simple** - Complex workflows are harder to validate and maintain
5. **Document your workflows** - Add comments explaining complex logic
6. **Test locally first** - Validate and test workflows locally before pushing

---

For more information, see SKILL.md for the complete GitHub Operations skill documentation.
