---
name: gh-cli
description: Use GitHub CLI (gh) for GitHub operations like PRs, issues, releases, repos, workflows, and gists. Load this skill whenever the user asks to interact with GitHub repositories, pull requests, issues, actions, or releases.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: github
---

## What I do

Use `gh` CLI to interact with GitHub directly from the terminal. Always prefer `gh` CLI over MCP GitHub tools when the operation maps to a `gh` command, as it is faster and more reliable.

## When to use me

Load this skill when the user asks to:
- Create, list, view, merge, or review pull requests
- Create, list, view, close, or comment on issues
- Create or manage GitHub releases and tags
- View or trigger GitHub Actions workflows
- Clone, fork, create, or delete repositories
- Manage GitHub gists
- Any other GitHub operation that `gh` supports

## Authentication

`gh` is already authenticated via `GITHUB_PAT` environment variable. The active account is `hlavrencic` on `github.com`.

To verify: `gh auth status`

## Key commands reference

### Pull Requests
```bash
gh pr list                          # list open PRs
gh pr list --state all              # all PRs
gh pr view <number>                 # view PR details
gh pr create --title "..." --body "..." --base main
gh pr create --fill                 # auto-fill from commits
gh pr merge <number> --squash       # merge PR
gh pr merge <number> --merge        # merge commit
gh pr merge <number> --rebase       # rebase merge
gh pr checkout <number>             # checkout PR branch locally
gh pr review <number> --approve
gh pr review <number> --request-changes --body "..."
gh pr review <number> --comment --body "..."
gh pr close <number>
gh pr diff <number>
gh pr checks <number>               # view CI status
```

### Issues
```bash
gh issue list
gh issue list --label "bug" --state open
gh issue view <number>
gh issue create --title "..." --body "..." --label bug
gh issue close <number>
gh issue reopen <number>
gh issue comment <number> --body "..."
gh issue edit <number> --title "..." --add-label "..."
gh issue assign <number> --assignee @me
```

### Repositories
```bash
gh repo list                        # list your repos
gh repo list <owner>                # list org/user repos
gh repo view                        # view current repo
gh repo view <owner>/<repo>
gh repo create <name> --public      # create new repo
gh repo create <name> --private
gh repo fork <owner>/<repo>
gh repo clone <owner>/<repo>
gh repo delete <owner>/<repo> --confirm
```

### Releases
```bash
gh release list
gh release view <tag>
gh release create <tag> --title "..." --notes "..."
gh release create <tag> --generate-notes  # auto-generate notes
gh release upload <tag> <file>      # upload asset
gh release delete <tag> --confirm
gh release download <tag>
```

### GitHub Actions / Workflows
```bash
gh workflow list
gh workflow view <workflow>
gh workflow run <workflow>
gh workflow run <workflow> --ref <branch>
gh run list
gh run list --workflow <workflow>
gh run view <run-id>
gh run watch <run-id>               # stream logs live
gh run rerun <run-id>
gh run cancel <run-id>
gh run download <run-id>            # download artifacts
```

### Gists
```bash
gh gist list
gh gist create <file>
gh gist create <file> --public
gh gist view <id>
gh gist edit <id>
gh gist delete <id>
```

### Searching
```bash
gh search repos <query>
gh search issues <query>
gh search prs <query>
gh search code <query>
```

### API (raw GitHub API)
```bash
gh api repos/{owner}/{repo}
gh api repos/{owner}/{repo}/issues --jq '.[].title'
gh api graphql -f query='{ viewer { login } }'
```

## Best practices

1. **Always use `--repo owner/repo`** when not inside the target git repo to avoid acting on the wrong repo.
2. **Use `--json` + `--jq`** for scripting: `gh pr list --json number,title --jq '.[].title'`
3. **Use `gh pr create --fill`** when commits have good messages — it auto-populates title and body.
4. **Prefer `gh run watch`** to monitor CI rather than polling.
5. **Use `gh release create --generate-notes`** for automatic changelog from merged PRs.
6. **Never use MCP GitHub tools** (`github_create_pull_request`, `github_create_issue`, etc.) when `gh` CLI can do the same thing — `gh` is preferred.

## Output formats

Most commands support:
- `--json <fields>` — output JSON
- `--jq <expr>` — filter JSON with jq
- `--template <tmpl>` — Go template formatting
- `-w` / `--web` — open in browser

Example:
```bash
gh pr list --json number,title,state --jq '.[] | "\(.number): \(.title) [\(.state)]"'
```
