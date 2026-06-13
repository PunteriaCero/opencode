---
name: github-ops
description: Use git with GHUB_PAT token for GitHub push operations, authentication, and repository management. Load this skill for pushing code changes to GitHub repositories.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: github
---

# GitHub Operations Skill

## Overview

This skill provides comprehensive guidance on GitHub operations using the `GHUB_PAT` (Personal Access Token) for authentication with git and GitHub CLI operations.

## Authentication Configuration

The agent MUST use the `GHUB_PAT` environment variable for all git operations.

### Option 1: Configure git credential helper (Recommended)

```bash
git config --global credential.helper store
echo "https://:${GHUB_PAT}@github.com" >> ~/.git-credentials
git config --global user.name "OpenCode Agent"
git config --global user.email "opencode@anomaly.co"
```

After this one-time configuration, use standard git commands:

```bash
git add -A
git commit -m "message"
git push
```

### Option 2: Use PAT directly in commands

For one-off operations without permanent configuration:

```bash
git -c credential.helper='!echo "username=git"; echo "password=${GHUB_PAT}"' push
```

Or with all git operations:

```bash
git -c credential.helper='!echo "username=git"; echo "password=${GHUB_PAT}"' add -A
git -c credential.helper='!echo "username=git"; echo "password=${GHUB_PAT}"' commit -m "message"
git -c credential.helper='!echo "username=git"; echo "password=${GHUB_PAT}"' push
```

## Important Rules

- **CRITICAL:** The agent MUST ALWAYS use `git push` with the `GHUB_PAT` token to upload changes to any repository
- **NEVER** use MCP GitHub tools (`github_push_files`, `github_create_or_update_file`, `github_create_pull_request`, etc.) for pushing code changes
- ONLY use MCP GitHub tools for read-only operations like:
  - Listing issues and pull requests
  - Searching code and repositories
  - Getting file contents
  - Creating issues or pull requests through the API

## Push Operations Workflow

When pushing changes to any GitHub repository:

1. Stage your changes:
   ```bash
   git add -A
   ```

2. Create a commit with a descriptive message:
   ```bash
   git commit -m "description of changes"
   ```

3. Push using the PAT token:
   ```bash
   git -c credential.helper='!echo "username=git"; echo "password=${GHUB_PAT}"' push
   ```

Or in a single command chain:

```bash
git add -A && git commit -m "message" && git -c credential.helper='!echo "username=git"; echo "password=${GHUB_PAT}"' push
```

## Troubleshooting

### Authentication Failed

If you encounter "fatal: Authentication failed", verify the PAT token:

```bash
echo $GHUB_PAT
```

Ensure the token has the necessary scopes:
- `repo` - Full control of private repositories
- `workflow` - Update GitHub Action workflows
- `read:user` - Read user profile data

### Credential Helper Issues

To reset git credentials:

```bash
rm ~/.git-credentials
git config --global credential.helper store
echo "https://:${GHUB_PAT}@github.com" >> ~/.git-credentials
```

## MCP GitHub Tools Usage

For read-only operations, you can use these MCP tools:
- `github_list_issues` - List issues in a repository
- `github_list_pull_requests` - List pull requests
- `github_search_code` - Search code
- `github_search_repositories` - Search repositories
- `github_get_file_contents` - Get file contents
- `github_create_issue` - Create issues programmatically
- `github_list_commits` - List commits

## Workflow Validation with actionlint

Before pushing GitHub Actions workflows, validate them using **actionlint** - a static checker for GitHub Actions workflow files.

### Installation

```bash
# Using Homebrew (macOS/Linux)
brew install actionlint

# Using go install
go install github.com/rhysd/actionlint/cmd/actionlint@latest

# Using Docker
docker run --rm -v "$(pwd):/app" rhysd/actionlint:latest
```

### Usage

```bash
# Check all workflows in the repository
actionlint

# Check specific workflow file
actionlint .github/workflows/ci.yml

# Check with verbose output
actionlint -verbose

# Fix issues automatically (where possible)
actionlint -format sarif
```

### What actionlint Validates

- **Syntax errors** - Unexpected or missing keys in workflow files
- **Type checking** - Strong type checking for `${{ }}` expressions
- **Action inputs/outputs** - Verifies action inputs and outputs are correct
- **Reusable workflows** - Validates reusable workflow calls
- **Script injection** - Detects security vulnerabilities with untrusted inputs
- **Hardcoded credentials** - Identifies exposed secrets
- **Glob patterns** - Validates path and branch filters
- **Job dependencies** - Checks `needs:` dependencies
- **Runner labels** - Validates runner labels and availability
- **Cron syntax** - Validates cron expressions in schedules
- **Shell scripts** - Integrates shellcheck and pyflakes

### Example: Validating Before Push

```bash
# Check workflows before committing
actionlint

# If validation passes
git add .
git commit -m "ci: add new workflow"
git push

# If validation fails
# Fix the issues reported by actionlint
# Then try again
```

### Common actionlint Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `unexpected key` | Typo in YAML key | Check workflow syntax |
| `is not defined` | Wrong action input name | Use correct input from action |
| `not found` | Missing action version | Use valid action version |
| `property not defined` | Accessing undefined variable | Use correct expression syntax |
| `potentially untrusted` | Script injection risk | Pass to env var first |

### Online Playground

Try actionlint without installing:
https://rhysd.github.io/actionlint/

### Validation Script

See the `validate-workflows.sh` script in this skill's directory for automated validation during CI/CD.

## Best Practices

1. Use meaningful commit messages that describe the "why" not just the "what"
2. Commit frequently with logical units of work
3. Always verify changes with `git status` before pushing
4. Use git branches for features and fixes
5. Never force push to main or master branches without explicit approval
6. **Always validate workflows with actionlint before pushing**
7. Keep workflows DRY by using reusable workflows
8. Document complex workflow logic with comments
9. Use secrets properly and never hardcode credentials
10. Test workflow changes on a branch before merging to main
