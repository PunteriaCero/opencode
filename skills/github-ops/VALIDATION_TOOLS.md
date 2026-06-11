# GitHub Actions Workflow Validation Tools

## Executive Summary

This document describes the tools and improvements made to the `github-ops` skill for validating GitHub Actions workflows.

## Tools Found

### 1. **actionlint** ⭐ PRIMARY TOOL
- **URL**: https://github.com/rhysd/actionlint
- **Author**: rhysd
- **Stars**: 3.9k+
- **Language**: Go
- **License**: MIT
- **Latest Version**: v1.7.12 (as of 2026)

#### Features
- Static checker for GitHub Actions workflow files
- Syntax validation
- Strong type checking for `${{ }}` expressions
- Action inputs/outputs verification
- Reusable workflow checking
- Security checks (script injection, hardcoded credentials)
- Glob pattern validation
- Job dependency checking
- Runner label validation
- Cron syntax validation
- Shellcheck and Pyflakes integration
- Online playground available

#### Installation Methods
```bash
# Homebrew (macOS/Linux)
brew install actionlint

# Go
go install github.com/rhysd/actionlint/cmd/actionlint@latest

# Docker
docker run --rm -v "$(pwd):/app" rhysd/actionlint:latest

# Pre-built binaries
# https://github.com/rhysd/actionlint/releases
```

#### Usage
```bash
actionlint                  # Check all workflows
actionlint -verbose         # Verbose output
actionlint .github/workflows/ci.yml  # Check specific file
actionlint -format sarif    # SARIF format for CI tools
```

#### Strengths
- ✓ Most comprehensive validation tool available
- ✓ Active development and maintenance
- ✓ Great documentation and examples
- ✓ Integration with major CI/CD platforms
- ✓ Pre-commit hooks support
- ✓ Online playground for testing
- ✓ Docker support
- ✓ SARIF output for GitHub code scanning

---

### 2. **yamllint**
- **URL**: https://github.com/adrienverge/yamllint
- **Author**: adrienverge
- **Language**: Python
- **License**: GPL-3.0

#### Features
- YAML syntax validation
- Configurable linting rules
- Format checking
- Indentation validation

#### When to Use
- General YAML validation (not GitHub Actions specific)
- Can be used as a supplementary tool

#### Installation
```bash
pip install yamllint
yamllint .github/workflows/
```

---

### 3. **GH-CLI Workflow Validation**
- Built into GitHub CLI (`gh`)
- Validate workflows using GitHub's official tools

#### Usage
```bash
gh workflow list
gh workflow view <workflow>
gh run view <run-id> --verbose
```

---

## Implementation: Enhanced github-ops Skill

### What Was Added

#### 1. SKILL.md Enhancement
Added comprehensive "Workflow Validation with actionlint" section including:
- Installation instructions
- Usage examples
- Validation checks list
- Common error reference
- Online playground link

#### 2. validate-workflows.sh Script
A production-ready Bash script with:
- Automatic actionlint installation
- Colorized output (RED, GREEN, YELLOW, BLUE)
- Multiple validation modes:
  - Validate all workflows
  - Validate specific file
  - Verbose output
  - Custom directory support
- Comprehensive error reporting
- Summary statistics
- Help documentation
- Pre-commit hook integration

#### 3. README.md
Complete guide covering:
- Quick start instructions
- What the validator does
- Installation methods
- Usage examples
- CI/CD integration
- Pre-commit hook setup
- Troubleshooting
- Best practices

### Files Added/Modified

```
/workspace/opencode-custom/skills/github-ops/
├── SKILL.md                    (MODIFIED - Added validation section)
├── validate-workflows.sh       (NEW - Validation script)
└── README.md                   (NEW - Complete documentation)
```

### Features of the Solution

✓ **Comprehensive** - Validates syntax, types, security, and best practices
✓ **Automated** - Automatically installs actionlint if needed
✓ **User-Friendly** - Colorized output, help, and error messages
✓ **Flexible** - Supports multiple validation modes
✓ **Integrated** - Works with git workflows and CI/CD
✓ **Documented** - Extensive documentation and examples
✓ **Production-Ready** - Error handling, exit codes, summary reports

## Usage Workflow

### Before Pushing Workflow Changes

```bash
# 1. Edit your workflow
vim .github/workflows/ci.yml

# 2. Validate it
./skills/github-ops/validate-workflows.sh

# 3. If valid, commit and push
git add .
git commit -m "ci: update workflow"
git push

# 4. If invalid, fix issues and validate again
```

### In CI/CD Pipeline

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: go install github.com/rhysd/actionlint/cmd/actionlint@latest
      - run: actionlint
```

### As Pre-commit Hook

```bash
#!/bin/bash
./skills/github-ops/validate-workflows.sh
if [ $? -ne 0 ]; then
    exit 1
fi
```

## Common Validation Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `unexpected key` | Typo in YAML | Check syntax reference |
| `is not defined` | Wrong action input | Use action's actual inputs |
| `not found` | Invalid action version | Use correct version |
| `property not defined` | Wrong variable reference | Use correct expression syntax |
| `potentially untrusted` | Security vulnerability | Pass to environment variable first |

## Best Practices Going Forward

1. **Always validate before committing** workflow changes
2. **Run actionlint in CI** to catch issues in pull requests
3. **Set up pre-commit hooks** to prevent invalid workflows
4. **Keep workflows documented** with clear comments
5. **Use actionlint playground** to test changes interactively
6. **Review security warnings** carefully

## Resources

- **actionlint GitHub**: https://github.com/rhysd/actionlint
- **actionlint Docs**: https://github.com/rhysd/actionlint/tree/main/docs
- **actionlint Playground**: https://rhysd.github.io/actionlint/
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **GitHub Actions Syntax**: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions

## Conclusion

The enhanced `github-ops` skill now provides comprehensive workflow validation capabilities through:
1. Detailed SKILL.md documentation
2. Production-ready validation script
3. Complete README with examples and integrations

This makes it easy for developers to validate their GitHub Actions workflows and catch errors before they cause CI/CD failures.
