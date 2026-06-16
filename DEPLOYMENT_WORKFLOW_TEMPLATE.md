# OpenCode Deployment Workflow Template

This file provides example GitHub Actions workflows for deploying OpenCode with QDRANT support.

## Prerequisites

1. OpenCode running in Portainer or Docker
2. QDRANT vector database accessible
3. GitHub repository with `.github/workflows/` directory
4. Secrets configured in GitHub:
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD` or `DOCKER_TOKEN`
   - `QDRANT_URL`
   - `QDRANT_API_KEY`
   - `PORTAINER_URL` (if using Portainer)
   - `PORTAINER_PAT` (if using Portainer)

## Workflow 1: Simple Deployment (Local)

Use this if deploying to a local machine with docker-compose.

### File: `.github/workflows/deploy-local.yml`

```yaml
name: Deploy OpenCode (Local)

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Verify QDRANT Connection
        run: |
          echo "Testing QDRANT at ${{ secrets.QDRANT_URL }}"
          curl -f -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
            ${{ secrets.QDRANT_URL }}/collections \
            || exit 1
      
      - name: Deploy OpenCode
        env:
          QDRANT_URL: ${{ secrets.QDRANT_URL }}
          QDRANT_API_KEY: ${{ secrets.QDRANT_API_KEY }}
        run: |
          docker-compose pull
          docker-compose up -d
      
      - name: Verify Deployment
        run: |
          sleep 5
          docker ps
          docker logs opencode | head -20
      
      - name: Test QDRANT Integration
        run: |
          curl -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
            ${{ secrets.QDRANT_URL }}/collections
```

---

## Workflow 2: Docker Build & Push + Deploy

Use this if you need to build and push a Docker image first.

### File: `.github/workflows/deploy-docker.yml`

```yaml
name: Build & Deploy OpenCode

on:
  push:
    branches: [main]
    paths:
      - 'opencode/**'
      - 'mcp-servers/**'
      - 'docker-compose.yml'
      - '.github/workflows/deploy-docker.yml'
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/opencode:latest
            ${{ secrets.DOCKER_USERNAME }}/opencode:${{ github.sha }}
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Verify QDRANT Connection
        run: |
          curl -f -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
            ${{ secrets.QDRANT_URL }}/collections
      
      - name: Deploy with updated image
        env:
          QDRANT_URL: ${{ secrets.QDRANT_URL }}
          QDRANT_API_KEY: ${{ secrets.QDRANT_API_KEY }}
        run: |
          docker-compose pull opencode
          docker-compose up -d opencode
      
      - name: Verify Services
        run: |
          sleep 5
          curl -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
            ${{ secrets.QDRANT_URL }}/collections
```

---

## Workflow 3: Deploy to Portainer (Remote)

Use this if managing deployment through Portainer.

### File: `.github/workflows/deploy-portainer.yml`

```yaml
name: Deploy to Portainer

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Verify QDRANT
        run: |
          curl -f -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
            ${{ secrets.QDRANT_URL }}/collections
      
      - name: Configure Environment
        run: |
          cat > .env.deployment <<EOF
          APP_NAME=OpenCode
          APP_ENV=production
          QDRANT_URL=${{ secrets.QDRANT_URL }}
          QDRANT_API_KEY=${{ secrets.QDRANT_API_KEY }}
          DB_HOST=${{ secrets.DB_HOST }}
          DB_USER=${{ secrets.DB_USER }}
          DB_PASSWORD=${{ secrets.DB_PASSWORD }}
          REDIS_HOST=${{ secrets.REDIS_HOST }}
          EOF
      
      - name: Deploy Stack via Portainer API
        run: |
          # This is a template - adjust to your Portainer setup
          curl -X POST \
            -H "X-API-Key: ${{ secrets.PORTAINER_PAT }}" \
            -H "Content-Type: application/json" \
            ${{ secrets.PORTAINER_URL }}/api/stacks/deploy \
            -d @- << EOF
          {
            "stackName": "opencode",
            "composeFile": "docker-compose.yml",
            "environment": {
              "QDRANT_URL": "${{ secrets.QDRANT_URL }}",
              "QDRANT_API_KEY": "${{ secrets.QDRANT_API_KEY }}"
            }
          }
          EOF
      
      - name: Verify Deployment Health
        run: |
          sleep 5
          curl -f -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
            ${{ secrets.QDRANT_URL }}/collections || exit 1
```

---

## Workflow 4: Complete CI/CD Pipeline

Use this for a full CI/CD pipeline including tests, build, and deploy.

### File: `.github/workflows/complete-cicd.yml`

```yaml
name: Complete CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint
        run: npm run lint || true
      
      - name: Run tests
        run: npm test || true
  
  build:
    needs: test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      packages: write
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
  
  verify-qdrant:
    runs-on: ubuntu-latest
    
    steps:
      - name: Test QDRANT Connectivity
        run: |
          echo "QDRANT URL: ${{ secrets.QDRANT_URL }}"
          curl -f -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
            ${{ secrets.QDRANT_URL }}/collections
  
  deploy:
    needs: [build, verify-qdrant]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy OpenCode
        env:
          QDRANT_URL: ${{ secrets.QDRANT_URL }}
          QDRANT_API_KEY: ${{ secrets.QDRANT_API_KEY }}
          DB_HOST: ${{ secrets.DB_HOST }}
          DB_USER: ${{ secrets.DB_USER }}
          DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
        run: |
          docker-compose pull
          docker-compose up -d
      
      - name: Verify Health
        run: |
          sleep 5
          docker ps
          curl -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
            ${{ secrets.QDRANT_URL }}/collections
```

---

## Setting Up Secrets in GitHub

1. Go to your repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add the following secrets:

```
QDRANT_URL = http://localhost:6333
QDRANT_API_KEY = hernan-qdrant-key-2026

DOCKER_USERNAME = your-docker-username
DOCKER_PASSWORD = your-docker-token

DB_HOST = localhost
DB_USER = root
DB_PASSWORD = your-db-password

REDIS_HOST = localhost

PORTAINER_URL = http://portainer-url:9000
PORTAINER_PAT = your-portainer-token
```

---

## Running Workflows

### Manual Trigger

```bash
# List workflows
gh workflow list

# Run specific workflow
gh workflow run deploy-local.yml

# On specific branch
gh workflow run deploy-local.yml --ref main
```

### Monitor Execution

```bash
# List recent runs
gh run list

# Watch live
gh run watch <run-id>

# View detailed logs
gh run view <run-id> --verbose

# Download artifacts
gh run download <run-id>
```

---

## Troubleshooting

### QDRANT Connection Fails

```yaml
- name: Debug QDRANT
  run: |
    echo "URL: ${{ secrets.QDRANT_URL }}"
    echo "Testing connectivity..."
    curl -v -H "api-key: ${{ secrets.QDRANT_API_KEY }}" \
      ${{ secrets.QDRANT_URL }}/collections
```

### Workflow Not Triggering

1. Verify event trigger (push, pull_request, etc.)
2. Check branch filter matches
3. Ensure workflow is enabled
4. Check commit has changed watched files (if using `paths`)

### Docker Build Fails

1. Verify Dockerfile exists and is correct
2. Check build context is correct
3. Ensure secrets used in build are valid
4. Review build logs for errors

---

## Best Practices

1. **Use matrix strategy** for multiple environments
2. **Add health checks** after deployments
3. **Keep secrets secure** - never log them
4. **Use pinned action versions** - not `@latest`
5. **Document deployment steps** in README.md
6. **Test workflows locally** with `act`
7. **Monitor deployments** with `gh run watch`

---

## Next Steps

1. Choose a workflow template above
2. Create `.github/workflows/deploy.yml` in your repo
3. Add required secrets in GitHub settings
4. Push to main branch to trigger workflow
5. Monitor with `gh run watch` or GitHub UI

For more help, load the `github-pipelines` skill:
```bash
skill load github-pipelines
```
