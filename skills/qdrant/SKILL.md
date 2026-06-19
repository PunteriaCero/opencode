# QDRANT Vector Memory Service Skill

## Overview

This skill provides integration with QDRANT, a high-performance vector database for semantic memory and similarity search. It enables storing and retrieving embeddings for AI-powered memory and context understanding.

**Status**: Integrated  
**Version**: 1.0.0  
**API Endpoint**: http://localhost:6333  
**Management UI**: http://localhost:6334

---

## Configuration

### Environment Variables

Add these to your `.env.opencode` file:

```bash
QDRANT_URL=http://localhost:6333
QDRANT_API_KEY=hernan-qdrant-key-2026
```

### OpenCode Integration

QDRANT is registered as an MCP server in `opencode.json`:

```json
"qdrant": {
  "type": "local",
  "command": ["node", "/root/.config/opencode/mcp-servers/qdrant-server.js"],
  "enabled": true,
  "environment": {
    "QDRANT_URL": "{env:QDRANT_URL}",
    "QDRANT_API_KEY": "{env:QDRANT_API_KEY}"
  }
}
```

---

## Available Tools

### Collection Management

#### `qdrant_list_collections`
List all vector collections in QDRANT.

**Parameters**: None

**Example**:
```
List all collections to see what memory storage is available.
```

---

#### `qdrant_create_collection`
Create a new vector collection for storing embeddings.

**Parameters**:
- `collection_name` (string, required): Name for the new collection
- `vector_size` (number, required): Dimension of vectors (e.g., 1536 for OpenAI embeddings)
- `distance` (string, optional): Distance metric: `Cosine`, `Euclid`, `Manhattan`, `Dot` (default: `Cosine`)

**Example**:
```
Create a collection named "conversation-memory" with 1536-dimensional vectors for storing conversation embeddings.
```

---

#### `qdrant_get_collection_info`
Get detailed information about a specific collection.

**Parameters**:
- `collection_name` (string, required): Name of the collection

**Example**:
```
Get info about the "conversation-memory" collection to see how many embeddings are stored.
```

---

#### `qdrant_delete_collection`
Delete a collection and all its data.

**Parameters**:
- `collection_name` (string, required): Name of the collection to delete

**Example**:
```
Delete the "old-memory" collection.
```

---

### Vector Operations

#### `qdrant_upsert_points`
Add or update vector points in a collection (insert or update embeddings).

**Parameters**:
- `collection_name` (string, required): Target collection name
- `points` (array, required): Array of point objects with:
  - `id` (number): Unique point ID
  - `vector` (array): Vector embedding (array of numbers)
  - `payload` (object, optional): Metadata (text, timestamp, source, etc.)

**Example**:
```
Store a conversation embedding in the "conversation-memory" collection with metadata about the speaker and timestamp.
```

---

#### `qdrant_search`
Perform semantic similarity search using vector embeddings.

**Parameters**:
- `collection_name` (string, required): Collection to search
- `vector` (array, required): Query vector embedding
- `limit` (number, optional): Max results to return (default: 10)
- `score_threshold` (number, optional): Minimum similarity score (0-1)

**Example**:
```
Search the "conversation-memory" collection for embeddings similar to a new conversation, returning the top 5 matches with a minimum similarity of 0.7.
```

---

#### `qdrant_get_point`
Retrieve a specific point by its ID.

**Parameters**:
- `collection_name` (string, required): Collection name
- `point_id` (number, required): ID of the point to retrieve

**Example**:
```
Get the details of point 42 from the "conversation-memory" collection.
```

---

#### `qdrant_delete_points`
Delete specific points from a collection.

**Parameters**:
- `collection_name` (string, required): Collection name
- `point_ids` (array, required): IDs of points to delete

**Example**:
```
Delete points 1, 2, and 3 from the "conversation-memory" collection.
```

---

#### `qdrant_scroll_collection`
Scroll through all points in a collection with pagination.

**Parameters**:
- `collection_name` (string, required): Collection name
- `limit` (number, optional): Points per page (default: 10)
- `offset` (number, optional): Pagination offset

**Example**:
```
Get the first 20 points from the "conversation-memory" collection, then page 2 with offset 20.
```

---

## Typical Workflows

### 1. Store Conversation Memory

```
1. Generate embedding for user input using an embedding model
2. Use `qdrant_upsert_points` to store it with metadata:
   - id: unique identifier
   - vector: the embedding
   - payload: {text, timestamp, source, user_id, etc.}
```

### 2. Retrieve Relevant Context

```
1. Generate embedding for current query
2. Use `qdrant_search` to find similar stored embeddings
3. Extract metadata from top results
4. Pass results to AI model for context-aware responses
```

### 3. Memory Cleanup

```
1. Use `qdrant_get_collection_info` to check collection size
2. Use `qdrant_scroll_collection` to view old entries
3. Use `qdrant_delete_points` to remove outdated memories
```

---

## API Reference

**REST Endpoints** (Direct HTTP access):
- `GET /collections` - List collections
- `GET /collections/{name}` - Get collection info
- `PUT /collections/{name}` - Create collection
- `DELETE /collections/{name}` - Delete collection
- `PUT /collections/{name}/points` - Upsert points
- `POST /collections/{name}/points/search` - Search
- `POST /collections/{name}/points/delete` - Delete points

**Headers**:
```
api-key: hernan-qdrant-key-2026
Content-Type: application/json
```

---

## Management UI

Access the QDRANT management console:
- **URL**: http://localhost:6334
- **API Key**: hernan-qdrant-key-2026

Here you can:
- View all collections and their stats
- Inspect individual points and their payloads
- Monitor performance metrics
- Run test queries

---

## Best Practices

1. **Vector Dimension Consistency**: All vectors in a collection must have the same dimension (e.g., 1536)
2. **Unique IDs**: Ensure each point has a unique ID within the collection
3. **Meaningful Payloads**: Store relevant metadata (text, source, timestamp) for context retrieval
4. **Score Thresholds**: Use `score_threshold` in search to filter low-relevance results
5. **Collection Organization**: Use separate collections for different types of memories (conversations, documents, etc.)

---

## Troubleshooting

**Connection Issues**:
```bash
# Test QDRANT connectivity
curl -H "api-key: hernan-qdrant-key-2026" http://localhost:6333/collections
```

**Memory Not Persisting**:
- Verify QDRANT_URL and QDRANT_API_KEY are correct
- Check QDRANT server logs
- Ensure collection exists before upserting points

**Search Returns No Results**:
- Lower the `score_threshold` to include less-similar results
- Verify vectors have correct dimensions
- Check that points exist in the collection

---

## Integration Examples

### Python Client (External)
```python
from qdrant_client import QdrantClient

client = QdrantClient(url="http://localhost:6333", api_key="hernan-qdrant-key-2026")
results = client.search(collection_name="memory", query_vector=embedding, limit=5)
```

### Node.js Client (External)
```javascript
import { QdrantClient } = from "@qdrant/js-client";

const client = new QdrantClient({
  url: "http://localhost:6333",
  apiKey: "hernan-qdrant-key-2026",
});

const results = await client.search("memory", { vector: embedding, limit: 5 });
```

---

## Related Skills

- `n8n-cli` - Automate memory workflows
- `github-ops` - Store memory-related configurations

---

## Support

For issues or feature requests:
- Check QDRANT official docs: https://qdrant.tech/documentation/
- Monitor server logs: `docker logs qdrant` (if running in Docker)
