# OpenCode Global Rules

## N8N Access

**The agent MUST ALWAYS use the N8N MCP tools for any N8N workflow automation operations.**

The N8N MCP server is connected as a **native remote MCP endpoint**. The connection is configured via two environment variables in the OpenCode container:
- `N8N_MCP_URL` - Full URL to the N8N MCP server (e.g. `http://192.168.0.177:5678/mcp-server/http`)
- `N8N_API_KEY` - JWT API key generated from N8N Settings > API > API Keys (audience: `mcp-server-api`)

### Available N8N MCP tools

- `n8n_search_workflows` - Search/list workflows (supports `query` and `limit` filters)
- `n8n_get_workflow_details` - Get full details of a workflow by ID
- `n8n_execute_workflow` - Execute a workflow by ID with inputs (chat, form, or webhook type)

### How to use

**List workflows:**
```
n8n_search_workflows(query="keyword", limit=10)
```

**Get workflow details (always do this before executing to understand inputs):**
```
n8n_get_workflow_details(workflowId="abc123")
```

**Execute a workflow:**
- Chat-based: `inputs: { type: "chat", chatInput: "message" }`
- Form-based: `inputs: { type: "form", formData: { key: "value" } }`
- Webhook-based: `inputs: { type: "webhook", webhookData: { method: "POST", body: {}, headers: {}, query: {} } }`

### Important rules
- ALWAYS call `n8n_get_workflow_details` before `n8n_execute_workflow` to understand the expected input schema and workflow description.
- NEVER guess workflow IDs — always search first with `n8n_search_workflows`.
- Use N8N MCP tools instead of direct HTTP calls to the N8N API.

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

### Public API Endpoints (No Authentication Required)

The Portainer MCP Server also exposes public HTTP endpoints for Docker image management. These endpoints do NOT require authentication and can be accessed directly via HTTP.

**Base URL:**
```
http://localhost:3000  (configurable via PUBLIC_PORT environment variable)
```

**Available Public Endpoints:**

1. **GET /api/images** - List all Docker images
   ```
   curl http://localhost:3000/api/images?environmentId=1
   ```
   Response: List of all Docker images with tags, size, creation date

2. **GET /api/images/unused** - List unused Docker images
   ```
   curl http://localhost:3000/api/images/unused?environmentId=1
   ```
   Response: List of images not used by any container (dangling images)

3. **POST /api/images/cleanup** - Delete unused Docker images
   ```
   curl -X POST http://localhost:3000/api/images/cleanup?environmentId=1&force=false
   ```
   Response: Report of deleted and failed images

**Query Parameters:**
- `environmentId` (optional): Portainer environment ID (default: 1)
- `force` (optional, cleanup only): Force delete even if image is in use (default: false)

**When to use Public API vs MCP tools:**
- Use **MCP tools** for programmatic operations within OpenCode workflows
- Use **Public API endpoints** for direct HTTP requests from external tools/scripts
- The public API is ideal for CI/CD pipelines, webhooks, and standalone utilities

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

