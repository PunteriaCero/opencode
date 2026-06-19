# QDRANT Integration Configuration

## Current Status

✅ **QDRANT MCP Server**: Implemented and enabled  
✅ **OpenCode Integration**: Configured in opencode.json  
✅ **Environment Variables**: Ready to configure  

---

## Quick Setup

### 1. Add Environment Variables

Edit `.env.opencode` and add:

```bash
# QDRANT Vector Database
QDRANT_URL=http://localhost:6333
QDRANT_API_KEY=hernan-qdrant-key-2026
```

### 2. Verify QDRANT is Running

Test the connection:

```bash
curl -H "api-key: hernan-qdrant-key-2026" http://localhost:6333/collections
```

Expected response (empty collections initially):
```json
{
  "result": {
    "collections": []
  },
  "status": "ok"
}
```

### 3. Restart OpenCode Container

To load the new environment variables:

```bash
docker-compose restart opencode
```

---

## QDRANT Details

- **Server URL**: http://localhost:6333
- **Management UI**: http://localhost:6334
- **REST API Port**: 6333
- **Web UI Port**: 6334
- **API Key**: hernan-qdrant-key-2026

---

## Available MCP Tools

The QDRANT MCP server provides 9 tools for memory management:

### Collection Management
- `qdrant_list_collections` - View all collections
- `qdrant_create_collection` - Create new memory storage
- `qdrant_get_collection_info` - Check collection stats
- `qdrant_delete_collection` - Remove collections

### Vector Operations
- `qdrant_upsert_points` - Store embeddings with metadata
- `qdrant_search` - Semantic similarity search
- `qdrant_get_point` - Retrieve specific embeddings
- `qdrant_delete_points` - Remove embeddings
- `qdrant_scroll_collection` - Browse paginated results

---

## Example Usage in OpenCode

### Store a Conversation Memory

```javascript
// This is pseudocode showing how the tools would be used
const embedding = await generateEmbedding("Hello, how are you?");

await qdrant_upsert_points({
  collection_name: "conversations",
  points: [{
    id: 1,
    vector: embedding,  // 1536 dimensions for OpenAI
    payload: {
      text: "Hello, how are you?",
      timestamp: "2026-06-16T10:30:00Z",
      source: "user_input",
      user_id: "user123"
    }
  }]
});
```

### Retrieve Relevant Context

```javascript
const query = "Tell me about our previous conversations";
const queryEmbedding = await generateEmbedding(query);

const results = await qdrant_search({
  collection_name: "conversations",
  vector: queryEmbedding,
  limit: 5,
  score_threshold: 0.7
});

// Results contain the most similar stored conversations
```

---

## Docker Compose Alternative (Optional)

If you want to run QDRANT in Docker instead of localhost:

```bash
# Start QDRANT with Docker Compose
docker-compose --profile qdrant up -d qdrant

# Check logs
docker logs qdrant

# Stop QDRANT
docker-compose --profile qdrant down
```

Then update `.env.opencode`:
```bash
QDRANT_URL=http://qdrant:6333
QDRANT_API_KEY=hernan-qdrant-key-2026
```

---

## File Structure

```
/data/opencode/root_config/
├── opencode.json                    # ✅ Updated with QDRANT config
├── docker-compose.yml               # ✅ Updated with QDRANT service
├── mcp-servers/
│   └── qdrant-server.js             # ✅ New QDRANT MCP server
└── skills/
    └── qdrant/
        └── SKILL.md                 # ✅ QDRANT skill documentation
```

---

## Testing the Integration

### 1. Create a Memory Collection

```bash
# Using the QDRANT MCP tool
curl -X POST http://localhost:6333/collections/test-memory \
  -H "api-key: hernan-qdrant-key-2026" \
  -H "Content-Type: application/json" \
  -d '{
    "vectors": {
      "size": 1536,
      "distance": "Cosine"
    }
  }'
```

### 2. Store Sample Data

```bash
curl -X PUT http://localhost:6333/collections/test-memory/points \
  -H "api-key: hernan-qdrant-key-2026" \
  -H "Content-Type: application/json" \
  -d '{
    "points": [
      {
        "id": 1,
        "vector": [0.1, 0.2, 0.3, ..., 0.1536],
        "payload": {
          "text": "Sample memory",
          "created_at": "2026-06-16"
        }
      }
    ]
  }'
```

### 3. Search for Similar Data

```bash
curl -X POST http://localhost:6333/collections/test-memory/points/search \
  -H "api-key: hernan-qdrant-key-2026" \
  -H "Content-Type: application/json" \
  -d '{
    "vector": [0.1, 0.2, 0.3, ..., 0.1536],
    "limit": 10
  }'
```

---

## Use Cases

### 1. **Conversation Memory**
Store and retrieve conversation history for context-aware responses.

### 2. **Document Memory**
Index document embeddings for semantic document search.

### 3. **User Preferences**
Store user interaction patterns for personalization.

### 4. **Knowledge Base**
Index FAQ or documentation for similarity-based retrieval.

### 5. **Meeting Transcripts**
Store meeting embeddings for quick retrieval of past discussions.

---

## Troubleshooting

### QDRANT Connection Fails

```bash
# Check if QDRANT is running
curl -H "api-key: hernan-qdrant-key-2026" http://localhost:6333/collections

# If connection refused, ensure QDRANT is started on port 6333
# Check your system services or Docker containers
```

### API Key Rejected

```bash
# Verify the API key in environment variables
echo $QDRANT_API_KEY

# Should output: hernan-qdrant-key-2026
```

### Vector Dimension Mismatch

When upserting points, ensure the vector dimension matches the collection:
- OpenAI embeddings: 1536
- Other models: check your embedding service documentation

---

## Next Steps

1. ✅ Verify QDRANT is running on http://localhost:6333
2. ✅ Confirm environment variables are set
3. ✅ Test connection with curl command
4. ✅ Create first memory collection
5. ✅ Implement embedding generation (OpenAI API, local model, etc.)
6. ✅ Start storing and retrieving memories through OpenCode

---

## Documentation References

- **QDRANT Docs**: https://qdrant.tech/documentation/
- **OpenCode MCP**: https://opencode.ai/docs
- **QDRANT Python Client**: https://github.com/qdrant/qdrant-client
- **QDRANT REST API**: https://qdrant.tech/api-reference/

---

## Support

For issues:
1. Check QDRANT logs: `docker logs qdrant`
2. Verify API key and URL configuration
3. Ensure collection exists before upserting points
4. Review QDRANT official documentation
