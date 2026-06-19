#!/usr/bin/env node

/**
 * QDRANT MCP Server
 * Provides Model Context Protocol tools for vector database operations
 * Supports: collection management, document storage/retrieval, semantic search
 */

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const {
  ListToolsRequestSchema,
  CallToolRequestSchema,
} = require("@modelcontextprotocol/sdk/types.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");

const QDRANT_URL = process.env.QDRANT_URL || "http://localhost:6333";
const QDRANT_API_KEY = process.env.QDRANT_API_KEY;

if (!QDRANT_API_KEY) {
  console.error("Error: QDRANT_API_KEY environment variable is required");
  process.exit(1);
}

const server = new Server({
  name: "qdrant-mcp-server",
  version: "1.0.0",
});

/**
 * Helper function to make API calls to QDRANT
 */
async function callQdrantAPI(method, endpoint, body = null) {
  const url = `${QDRANT_URL}${endpoint}`;
  const options = {
    method,
    headers: {
      "api-key": QDRANT_API_KEY,
      "Content-Type": "application/json",
    },
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  const response = await fetch(url, options);

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`QDRANT API Error (${response.status}): ${error}`);
  }

  return response.json();
}

/**
 * Tool Definitions
 */
const tools = [
  {
    name: "qdrant_list_collections",
    description: "List all vector collections in QDRANT",
    inputSchema: {
      type: "object",
      properties: {},
    },
  },
  {
    name: "qdrant_get_collection_info",
    description:
      "Get detailed information about a specific QDRANT collection",
    inputSchema: {
      type: "object",
      properties: {
        collection_name: {
          type: "string",
          description: "Name of the collection",
        },
      },
      required: ["collection_name"],
    },
  },
  {
    name: "qdrant_create_collection",
    description: "Create a new vector collection in QDRANT",
    inputSchema: {
      type: "object",
      properties: {
        collection_name: {
          type: "string",
          description: "Name for the new collection",
        },
        vector_size: {
          type: "number",
          description: "Dimension of vectors (e.g., 1536 for embeddings)",
        },
        distance: {
          type: "string",
          enum: ["Cosine", "Euclid", "Manhattan", "Dot"],
          description: "Distance metric for similarity (default: Cosine)",
        },
      },
      required: ["collection_name", "vector_size"],
    },
  },
  {
    name: "qdrant_delete_collection",
    description: "Delete a vector collection from QDRANT",
    inputSchema: {
      type: "object",
      properties: {
        collection_name: {
          type: "string",
          description: "Name of the collection to delete",
        },
      },
      required: ["collection_name"],
    },
  },
  {
    name: "qdrant_upsert_points",
    description:
      "Add or update vector points in a collection (for storing embeddings)",
    inputSchema: {
      type: "object",
      properties: {
        collection_name: {
          type: "string",
          description: "Name of the collection",
        },
        points: {
          type: "array",
          description:
            "Array of points with id, vector, and payload properties",
          items: {
            type: "object",
            properties: {
              id: {
                type: "number",
                description: "Unique point ID",
              },
              vector: {
                type: "array",
                description: "Vector embedding (array of numbers)",
                items: {
                  type: "number",
                },
              },
              payload: {
                type: "object",
                description: "Metadata associated with the point",
              },
            },
            required: ["id", "vector"],
          },
        },
      },
      required: ["collection_name", "points"],
    },
  },
  {
    name: "qdrant_search",
    description:
      "Perform semantic search in a collection using vector similarity",
    inputSchema: {
      type: "object",
      properties: {
        collection_name: {
          type: "string",
          description: "Name of the collection to search",
        },
        vector: {
          type: "array",
          description: "Query vector embedding",
          items: {
            type: "number",
          },
        },
        limit: {
          type: "number",
          description: "Maximum number of results to return (default: 10)",
        },
        score_threshold: {
          type: "number",
          description: "Minimum similarity score (0-1) to include results",
        },
      },
      required: ["collection_name", "vector"],
    },
  },
  {
    name: "qdrant_delete_points",
    description: "Delete specific points from a collection",
    inputSchema: {
      type: "object",
      properties: {
        collection_name: {
          type: "string",
          description: "Name of the collection",
        },
        point_ids: {
          type: "array",
          description: "IDs of points to delete",
          items: {
            type: "number",
          },
        },
      },
      required: ["collection_name", "point_ids"],
    },
  },
  {
    name: "qdrant_get_point",
    description: "Retrieve a specific point by ID",
    inputSchema: {
      type: "object",
      properties: {
        collection_name: {
          type: "string",
          description: "Name of the collection",
        },
        point_id: {
          type: "number",
          description: "ID of the point to retrieve",
        },
      },
      required: ["collection_name", "point_id"],
    },
  },
  {
    name: "qdrant_scroll_collection",
    description:
      "Scroll through all points in a collection with pagination",
    inputSchema: {
      type: "object",
      properties: {
        collection_name: {
          type: "string",
          description: "Name of the collection",
        },
        limit: {
          type: "number",
          description: "Number of points per page (default: 10)",
        },
        offset: {
          type: "number",
          description: "Offset for pagination",
        },
      },
      required: ["collection_name"],
    },
  },
];

/**
 * List available tools
 */
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return { tools };
});

/**
 * Tool implementation handlers
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "qdrant_list_collections": {
        const result = await callQdrantAPI("GET", "/collections");
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }

      case "qdrant_get_collection_info": {
        const result = await callQdrantAPI(
          "GET",
          `/collections/${args.collection_name}`
        );
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }

      case "qdrant_create_collection": {
        const distance = args.distance || "Cosine";
        const payload = {
          vectors: {
            size: args.vector_size,
            distance: distance,
          },
        };

        const result = await callQdrantAPI(
          "PUT",
          `/collections/${args.collection_name}`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: `Collection '${args.collection_name}' created successfully`,
            },
          ],
        };
      }

      case "qdrant_delete_collection": {
        await callQdrantAPI("DELETE", `/collections/${args.collection_name}`);
        return {
          content: [
            {
              type: "text",
              text: `Collection '${args.collection_name}' deleted successfully`,
            },
          ],
        };
      }

      case "qdrant_upsert_points": {
        const payload = {
          points: args.points,
        };

        const result = await callQdrantAPI(
          "PUT",
          `/collections/${args.collection_name}/points`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: `Successfully upserted ${args.points.length} points into '${args.collection_name}'`,
            },
          ],
        };
      }

      case "qdrant_search": {
        const params = new URLSearchParams();
        if (args.limit) params.append("limit", args.limit);
        if (args.score_threshold !== undefined) {
          params.append("score_threshold", args.score_threshold);
        }

        const payload = {
          vector: args.vector,
          limit: args.limit || 10,
        };

        if (args.score_threshold !== undefined) {
          payload.score_threshold = args.score_threshold;
        }

        const result = await callQdrantAPI(
          "POST",
          `/collections/${args.collection_name}/points/search`,
          payload
        );
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }

      case "qdrant_delete_points": {
        const payload = {
          points_selector: {
            ids: args.point_ids,
          },
        };

        await callQdrantAPI(
          "POST",
          `/collections/${args.collection_name}/points/delete`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: `Successfully deleted ${args.point_ids.length} points from '${args.collection_name}'`,
            },
          ],
        };
      }

      case "qdrant_get_point": {
        const result = await callQdrantAPI(
          "GET",
          `/collections/${args.collection_name}/points/${args.point_id}`
        );
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }

      case "qdrant_scroll_collection": {
        const params = new URLSearchParams();
        const limit = args.limit || 10;
        const offset = args.offset || 0;
        params.append("limit", limit);
        if (offset > 0) params.append("offset", offset);

        const result = await callQdrantAPI(
          "GET",
          `/collections/${args.collection_name}/points?${params.toString()}`
        );
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }

      default:
        return {
          content: [
            {
              type: "text",
              text: `Unknown tool: ${name}`,
            },
          ],
          isError: true,
        };
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

/**
 * Start the MCP server
 */
const transport = new StdioServerTransport();
server.connect(transport);

console.error("QDRANT MCP Server started on stdio transport");
