#!/usr/bin/env node
/**
 * Portainer MCP Server - Uses Portainer REST API
 * This is a wrapper that uses the published portainer-mcp-server package
 * Env vars required: PORTAINER_URL, PORTAINER_PAT
 */

import { spawn } from "child_process";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Start the portainer-mcp-server package with the same environment variables
const child = spawn("npx", ["-y", "portainer-mcp-server"], {
  env: {
    ...process.env,
    PORTAINER_URL: process.env.PORTAINER_URL || "http://192.168.0.214:9000",
    PORTAINER_PAT: process.env.PORTAINER_PAT,
  },
  stdio: "inherit",
});

child.on("error", (error) => {
  console.error("Error spawning portainer-mcp-server:", error);
  process.exit(1);
});

child.on("exit", (code) => {
  process.exit(code);
});
