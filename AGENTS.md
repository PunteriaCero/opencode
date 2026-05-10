# OpenCode Global Rules

## N8N Access

**The agent MUST ALWAYS use the N8N MCP tools for any N8N workflow automation operations.**

The N8N MCP server connects to `http://192.168.0.177:5678` and requires the `N8N_API_KEY` environment variable to be set in the OpenCode container.

## Portainer Access

**The agent MUST ALWAYS use the Portainer MCP tools for any Docker/Portainer operations.** NEVER use direct curl/bash commands to access Portainer.

Available Portainer MCP tools:
- `list_environments` - List all Portainer environments
- `list_containers` - List containers in an environment
- `inspect_container` - Get detailed container info
- `get_container_logs` - Get container logs
- `start_container` - Start a stopped container
- `stop_container` - Stop a running container
- `restart_container` - Restart a container
- `pull_image` - Pull a Docker image
- `delete_image` - Delete a Docker image
- `recreate_container` - Recreate a container with updated image
- `list_stacks` - List all stacks
- `inspect_stack` - Get stack details
- `get_stack_file` - Get docker-compose file content
- `list_images` - List Docker images
- `list_networks` - List Docker networks
- `list_volumes` - List Docker volumes

## GitHub Authentication

The agent MUST use the `GITHUB_PAT` environment variable for all git operations. Configure git to use the PAT token by setting the git credential helper:

```bash
git config --global credential.helper store
echo "https://:${GITHUB_PAT}@github.com" >> ~/.git-credentials
```

Or use the PAT directly in git commands:

```bash
git -c credential.helper='!echo "username=git"; echo "password=${GITHUB_PAT}"' push
```

## Auto-commit on changes

Whenever you modify any file inside `/root/.config/opencode`, you MUST immediately run:

```bash
cd /root/.config/opencode && git add -A && git commit -m "config: <brief description of change>"
```

After committing, you MUST push the changes to GitHub using:

```bash
cd /root/.config/opencode && git -c credential.helper='!echo "username=git"; echo "password=${GITHUB_PAT}"' push
```

## Restart OpenCode after config changes

After successfully pushing changes to GitHub from `/root/.config/opencode`, you MUST restart the OpenCode container via Portainer MCP using the `restart_container` tool with:
- environmentId: 3
- containerId: opencode

## Push changes to GitHub (General Rule)

**CRITICAL: The agent MUST ALWAYS use `git push` with the `GITHUB_PAT` token to upload changes to any repository.**

NEVER use MCP GitHub tools (`github_push_files`, `github_create_or_update_file`, `github_create_pull_request`, etc.) for pushing code changes. ONLY use these tools for read-only operations like listing, searching, or getting information.

For all push operations, use the git CLI with the PAT token:

```bash
git add -A && git commit -m "message" && git -c credential.helper='!echo "username=git"; echo "password=${GITHUB_PAT}"' push
```

Or configure git to use the PAT permanently:

```bash
git config --global user.name "OpenCode Agent"
git config --global user.email "opencode@anomaly.co"
echo "https://:${GITHUB_PAT}@github.com" >> ~/.git-credentials
git config --global credential.helper store
```

Then use standard git commands:

```bash
git add -A && git commit -m "message" && git push
```

