FROM ghcr.io/anomalyco/opencode:latest

# Install Node.js, npm and git (required for MCP local servers via npx)
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    python3 \
    py3-pip \
    bash \
    curl \
    wget \
    jq \
    ripgrep \
    openssh-client \
    ca-certificates \
    build-base \
    gcompat

# Install browser and multimedia dependencies (Alpine equivalents)
# These are required for headless browser automation and audio/video support
RUN apk add --no-cache \
    nss \
    xss \
    alsa-lib \
    gconf \
    liberation-fonts \
    libappindicator \
    libindicator \
    libgbm \
    libxkbcommon \
    libcups \
    dbus \
    expat \
    fontconfig \
    gdk-pixbuf \
    mesa \
    glib \
    gtk+3.0 \
    pango \
    libx11 \
    libxcb \
    libxcomposite \
    libxcursor \
    libxdamage \
    libxext \
    libxfixes \
    libxi \
    libxinerama \
    libxrandr \
    libxrender \
    libxshmfence \
    libxtst \
    xdg-utils \
    libstdc++ \
    libavcodec \
    libavformat \
    libavutil

# Install GitHub CLI from binary release
RUN curl -sSL https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_linux_amd64.tar.gz | \
    tar xz -C /usr/local/bin --strip-components=2 gh_2.92.0_linux_amd64/bin/gh

# Pre-install MCP servers globally to avoid npx download on each run
RUN npm install -g @leonardsellem/n8n-mcp-server

# Install n8n-cli
RUN npm install -g n8n-cli

# Install Portainer CLI (official tool for Portainer API)
# Use specific version v1.0.0 with correct tarball naming
RUN curl -sSL https://github.com/portainer/portainerctl/releases/download/v1.0.0/portainerctl_1.0.0_linux_amd64.tar.gz | \
    tar xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/portainerctl
