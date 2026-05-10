FROM ghcr.io/anomalyco/opencode:latest

# Install Node.js, npm and git (required for MCP local servers via npx)
RUN apk add --no-cache nodejs npm git

# Pre-install the N8N MCP server globally so npx doesn't need to download it each time
RUN npm install -g @leonardsellem/n8n-mcp-server
