---
name: github-pipelines
description: Assist in creating, validating, and managing GitHub Actions workflows/pipelines. Provides best practices, templates, and verification tools.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: github-ci-cd
---

## What I do

I help you:
- Create and structure GitHub Actions workflows from scratch or templates
- Validate YAML syntax and workflow logic
- Implement common CI/CD patterns (testing, linting, building, deploying)
- Debug workflow errors and improve performance
- Set up secrets, variables, and permissions correctly
- Monitor workflow runs and troubleshoot failures
- Use `gh workflow` and `gh run` commands effectively

## When to use me

Load this skill when you need to:
- Create a new GitHub Actions workflow (`.github/workflows/*.yml`)
- Troubleshoot a failing workflow or pipeline
- Implement CI/CD best practices in your workflows
- Set up automated testing, building, or deployment pipelines
- Understand workflow syntax, events, and triggers
- Optimize workflow performance and runtime
- Manage workflow secrets and environment variables
- Monitor and debug workflow runs
- Integrate multiple jobs and steps effectively

## Authentication

GitHub CLI (`gh`) is already authenticated via `GITHUB_PAT` environment variable.

Verify with: `gh auth status`

## GitHub Actions Basics

### Workflow File Structure

Workflows live in `.github/workflows/` and use YAML format:

```yaml
name: CI Pipeline              # Workflow name
on:                            # Trigger conditions
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:                        # Job name
    runs-on: ubuntu-latest     # Runner OS
    steps:
      - uses: actions/checkout@v4  # Use action
      - name: Run tests             # Step name
        run: npm test               # Shell command
```

### Common Triggers (on)

```yaml
on:
  push:
    branches: [main]           # On push to main
  pull_request:
    branches: [main]           # On PR to main
  schedule:
    - cron: '0 0 * * *'        # Daily at midnight UTC
  workflow_dispatch:           # Manual trigger from UI
  release:
    types: [created]           # On release created
  workflow_call:               # Reusable workflow
```

### Runners

- `ubuntu-latest` — Linux (recommended, fast, free)
- `windows-latest` — Windows
- `macos-latest` — macOS
- `self-hosted` — Your own machine

### Common Actions

```yaml
- uses: actions/checkout@v4    # Clone repo
- uses: actions/setup-node@v4  # Install Node.js
  with:
    node-version: '20'
- uses: actions/setup-python@v4
  with:
    python-version: '3.11'
- uses: actions/upload-artifact@v4
  with:
    name: coverage
    path: coverage/
- uses: actions/download-artifact@v4
```

## Basic Workflow Template

### Node.js / JavaScript

```yaml
name: Node.js CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build
```

### Python

```yaml
name: Python CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - run: pip install -r requirements.txt
      - run: pytest
      - run: black --check .
      - run: pylint src/
```

### Docker Build & Push

```yaml
name: Docker Build

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: myregistry/myimage:${{ github.sha }}
```

## Secrets & Variables

### Setting Up Secrets

1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add name and value
4. Use in workflow:

```yaml
- name: Deploy
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: ./deploy.sh
```

### Built-in Variables

```yaml
${{ github.ref }}              # Branch or tag ref
${{ github.event_name }}       # Trigger event
${{ github.sha }}              # Commit SHA
${{ github.actor }}            # Who triggered it
${{ github.workspace }}        # Working directory
${{ runner.os }}               # OS (Linux, Windows, macOS)
${{ job.status }}              # Job status (success, failure)
```

### Matrix Strategy

Test multiple versions in parallel:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
        os: [ubuntu-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
```

## Common Patterns

### Conditional Steps

```yaml
- name: Deploy (main only)
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: ./deploy.sh

- name: Comment PR
  if: github.event_name == 'pull_request'
  run: gh pr comment ${{ github.event.pull_request.number }} --body "..."
```

### Job Dependencies

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  build:
    needs: test          # Only runs if test succeeds
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

  deploy:
    needs: [test, build] # Wait for both
    runs-on: ubuntu-latest
    steps:
      - run: ./deploy.sh
```

### Upload & Download Artifacts

```yaml
jobs:
  build:
    steps:
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  deploy:
    needs: build
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
      - run: deploy-files
```

## Validation & Debugging

### Using `gh workflow` Commands

```bash
gh workflow list                    # List all workflows
gh workflow view <name-or-id>       # View workflow details
gh workflow view <name> --yaml      # Show YAML
gh workflow run <name>              # Trigger manually
gh workflow run <name> --ref main   # Trigger on specific branch
gh workflow disable <name>          # Disable workflow
gh workflow enable <name>           # Enable workflow
```

### Monitoring Runs

```bash
gh run list                         # List recent runs
gh run list --workflow tests        # Filter by workflow
gh run view <run-id>                # View run details
gh run view <run-id> --verbose      # Detailed output
gh run watch <run-id>               # Stream logs live
gh run download <run-id>            # Download artifacts
gh run rerun <run-id>               # Retry failed run
gh run cancel <run-id>              # Cancel in-progress run
```

### Validating Workflow YAML

```bash
# Check syntax with workflow validate (if available)
gh workflow view .github/workflows/main.yml

# Or manually validate online:
# https://www.yamllint.com/
# https://rhysd.github.io/actionlint/
```

## Best Practices

1. **Use pinned action versions** (`@v4` not `@latest` or `@main`)
   ```yaml
   - uses: actions/checkout@v4  # ✅ Good
   - uses: actions/checkout@latest  # ❌ Avoid
   ```

2. **Keep workflows readable**
   - Use descriptive names for jobs and steps
   - Comment complex sections
   - Break large workflows into reusable workflows

3. **Minimize runner time**
   - Cache dependencies: `actions/setup-node@v4` with caching
   - Use `if` conditions to skip unnecessary steps
   - Parallelize with matrix strategy

4. **Secure secrets**
   - Never log secrets: `run: echo ${{ secrets.TOKEN }}` ❌
   - Use `--mask-value` for sensitive output
   - Rotate secrets regularly
   - Use environment-specific secrets

5. **Handle failures gracefully**
   - Use `continue-on-error` for non-critical steps
   - Add retry logic for flaky tests
   - Post helpful comments on PR failures

6. **Document workflows**
   - Add comments in YAML explaining why
   - Keep README.md updated with CI/CD setup
   - Link to internal runbooks for failure handling

## Common Issues & Solutions

### Issue: Workflow file not found
- **Check**: File is at `.github/workflows/name.yml` (not `.github/workflow/`)
- **Check**: File is committed and pushed (not just local)

### Issue: Workflow not triggering
- **Check**: `on:` events match your use case
- **Check**: Branch filters match your branch
- **Check**: Workflow is enabled (not disabled)

### Issue: Permission denied errors
- **Check**: Runner has required permissions
- **Check**: `GITHUB_TOKEN` has sufficient scopes
- **Check**: Add `permissions:` block if needed

### Issue: Slow workflow
- **Check**: Use caching for dependencies
- **Check**: Parallelize jobs with `needs:`
- **Check**: Choose appropriate runner (ubuntu-latest is fastest)

## Workflow Composition

### Reusable Workflows

Define once, use many times:

```yaml
# .github/workflows/test.yml
name: Tests
on:
  workflow_call:
    inputs:
      node-version:
        required: false
        default: '20'
        type: string

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm test
```

Call it:

```yaml
jobs:
  call-test:
    uses: ./.github/workflows/test.yml
    with:
      node-version: '20'
```

## Resources

- Official docs: https://docs.github.com/en/actions
- Workflow syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- Actions marketplace: https://github.com/marketplace?type=actions
- Community actions: https://github.com/actions
