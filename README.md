# opencode-custom

[![Build and Publish Docker Image](https://github.com/hlavrencic/opencode-custom/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/hlavrencic/opencode-custom/actions/workflows/docker-publish.yml)
[![Base Image](https://img.shields.io/badge/base%20image-anomalyco%2Fopencode-blue?logo=docker)](https://github.com/anomalyco/opencode)
[![Docker Image Version](https://img.shields.io/badge/docker%20image-ghcr.io%2Fhlavrencic%2Fopencode--custom:latest-green?logo=docker)](https://github.com/hlavrencic/opencode-custom/pkgs/container/opencode-custom)

Custom Docker image based on `ghcr.io/anomalyco/opencode:latest` with additional tools pre-installed for MCP server support and extended development environment.

## What's added

- **Node.js & npm** — required to run local MCP servers via `npx`
- **git** — version control and git operations
- **gh** — GitHub CLI for repository operations (v2.92.0)
- **Python3 & pip** — Python runtime and package manager
- **curl & wget** — HTTP requests and file downloads
- **jq** — JSON processing in shell
- **ripgrep** — fast code search
- **openssh-client** — SSH connections and git over SSH
- **ca-certificates** — TLS certificates for HTTPS
- **build-base** — C/C++ compiler for native dependencies
- **@leonardsellem/n8n-mcp-server** — pre-installed globally for N8N workflow management

## Image

Published to GitHub Container Registry:

```
ghcr.io/hlavrencic/opencode-custom:latest
```

## Usage

Replace the image in your docker-compose:

```yaml
services:
  opencode:
    image: ghcr.io/hlavrencic/opencode-custom:latest
    # ... rest of your config
```

## CI/CD

The image is automatically built and published via GitHub Actions on every push to `main`.
