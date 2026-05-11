# OpenCode Global Rules

## Docker & Container Operations

**CRITICAL RULE: The agent MUST NEVER attempt to install, use, or execute Docker locally. Docker is NOT available in the OpenCode environment.**

**For ANY Docker operations (containers, images, networks, volumes, stacks), the agent MUST use the Portainer CLI.**

For detailed documentation on using `portainerctl`, load the Portainer CLI skill:

```bash
skill load portainer-cli
```

---

## N8N Access

**The agent MUST ALWAYS use the `n8n-cli` skill for any N8N workflow automation operations.**

Load the n8n-cli skill when working with N8N workflows, executions, or credentials:

```bash
skill load n8n-cli
```

This skill provides comprehensive documentation and best practices for all n8n-cli operations.

---

## GitHub Operations

**The agent MUST ALWAYS use `git` with the `GITHUB_PAT` token for uploading changes to any GitHub repository.**

For detailed documentation on GitHub authentication, push operations, and best practices, load the GitHub Operations skill:

```bash
skill load github-ops
```

### Key Rules

- **NEVER** use MCP GitHub tools for pushing code changes
- ONLY use MCP GitHub tools for read-only operations (listing, searching, getting information)
- Always use `GITHUB_PAT` environment variable for authentication
- All push operations MUST go through git CLI

---

## OpenCode Configuration Management

When modifying files in `/root/.config/opencode`, you MUST follow the configuration management workflow:

1. Make changes to configuration files
2. Commit changes with descriptive messages
3. Push changes to GitHub
4. Restart the OpenCode container

For detailed documentation on this workflow, including auto-commit procedures and container restart commands, load the OpenCode Configuration Management skill:

```bash
skill load opencode-config
```

---

## Summary of Skills

| Skill | Purpose | Load Command |
|-------|---------|--------------|
| `portainer-cli` | Docker/container operations via Portainer CLI | `skill load portainer-cli` |
| `n8n-cli` | N8N workflow automation operations | `skill load n8n-cli` |
| `github-ops` | GitHub authentication and push operations | `skill load github-ops` |
| `opencode-config` | OpenCode configuration management and deployment | `skill load opencode-config` |

---

## Quick Reference

### Load a Skill

```bash
skill load <skill-name>
```

### Available Skills in OpenCode

- `portainer-cli` - Portainer CLI commands and usage
- `n8n-cli` - N8N CLI commands and usage  
- `github-ops` - GitHub operations and authentication
- `opencode-config` - Configuration management and deployment
- `gh-cli` - GitHub CLI operations (existing skill)

### Help

For additional help or feedback, report issues at:
https://github.com/anomalyco/opencode
