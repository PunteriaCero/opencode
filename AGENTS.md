# OpenCode Global Rules

## Auto-commit on changes

Whenever you modify any file inside `/root/.config/opencode`, you MUST immediately run:

```bash
cd /root/.config/opencode && git add -A && git commit -m "config: <brief description of change>"
```

The post-commit hook will automatically push to GitHub.

## Restart OpenCode after config changes

After committing any change to `/root/.config/opencode`, you MUST restart the OpenCode container via Portainer so the new config takes effect. Use the Docker API proxy through the Portainer MCP (environment ID 3) to restart the container named `opencode`:

```
POST /containers/opencode/restart
```
