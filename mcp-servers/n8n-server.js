#!/usr/bin/env node

/**
 * N8N MCP Server
 * Provides Model Context Protocol tools for N8N workflow automation
 * Endpoints: search, get details, execute, create, update, delete, activate/deactivate,
 * list executions, get execution, delete execution
 */

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const {
  ListToolsRequestSchema,
  CallToolRequestSchema,
} = require("@modelcontextprotocol/sdk/types.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");

const N8N_API_URL = process.env.N8N_API_URL || "http://localhost:5678";
const N8N_API_KEY = process.env.N8N_API_KEY;

if (!N8N_API_KEY) {
  console.error("Error: N8N_API_KEY environment variable is required");
  process.exit(1);
}

const server = new Server({
  name: "n8n-mcp-server",
  version: "2.0.0",
});

/**
 * Helper function to make API calls to N8N
 */
async function callN8NAPI(method, endpoint, body = null) {
  const url = `${N8N_API_URL}/api/v1${endpoint}`;
  const options = {
    method,
    headers: {
      "X-N8N-API-KEY": N8N_API_KEY,
      "Content-Type": "application/json",
    },
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  const response = await fetch(url, options);

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`N8N API Error (${response.status}): ${error}`);
  }

  return response.json();
}

/**
 * Tool Definitions
 */
const tools = [
  {
    name: "n8n_search_workflows",
    description:
      "Search and list N8N workflows with optional query and limit filters",
    inputSchema: {
      type: "object",
      properties: {
        query: {
          type: "string",
          description: "Search query to filter workflows by name",
        },
        limit: {
          type: "number",
          description: "Maximum number of workflows to return",
        },
      },
    },
  },
  {
    name: "n8n_get_workflow_details",
    description:
      "Get full details of a specific workflow including nodes, connections, and settings",
    inputSchema: {
      type: "object",
      properties: {
        workflowId: {
          type: "string",
          description: "The ID of the workflow to retrieve",
        },
      },
      required: ["workflowId"],
    },
  },
  {
    name: "n8n_execute_workflow",
    description: "Execute a workflow with optional input data",
    inputSchema: {
      type: "object",
      properties: {
        workflowId: {
          type: "string",
          description: "The ID of the workflow to execute",
        },
        inputs: {
          type: "object",
          description:
            "Input data for the workflow execution (structure depends on workflow configuration)",
        },
      },
      required: ["workflowId"],
    },
  },
  {
    name: "n8n_create_workflow",
    description: "Create a new N8N workflow",
    inputSchema: {
      type: "object",
      properties: {
        name: {
          type: "string",
          description: "Name of the workflow",
        },
        nodes: {
          type: "array",
          description: "Array of workflow nodes configuration",
        },
        connections: {
          type: "object",
          description: "Node connection mappings",
        },
        active: {
          type: "boolean",
          description: "Whether the workflow should be active (default: false)",
        },
        tags: {
          type: "array",
          description: "Tags to associate with the workflow",
        },
      },
      required: ["name"],
    },
  },
  {
    name: "n8n_update_workflow",
    description: "Update an existing N8N workflow",
    inputSchema: {
      type: "object",
      properties: {
        workflowId: {
          type: "string",
          description: "The ID of the workflow to update",
        },
        name: {
          type: "string",
          description: "New name for the workflow",
        },
        nodes: {
          type: "array",
          description: "Updated array of workflow nodes",
        },
        connections: {
          type: "object",
          description: "Updated node connection mappings",
        },
        active: {
          type: "boolean",
          description: "Whether the workflow should be active",
        },
        tags: {
          type: "array",
          description: "Updated tags for the workflow",
        },
      },
      required: ["workflowId"],
    },
  },
  {
    name: "n8n_delete_workflow",
    description: "Delete a workflow from N8N",
    inputSchema: {
      type: "object",
      properties: {
        workflowId: {
          type: "string",
          description: "The ID of the workflow to delete",
        },
      },
      required: ["workflowId"],
    },
  },
  {
    name: "n8n_activate_workflow",
    description: "Activate a workflow to enable automatic execution",
    inputSchema: {
      type: "object",
      properties: {
        workflowId: {
          type: "string",
          description: "The ID of the workflow to activate",
        },
      },
      required: ["workflowId"],
    },
  },
  {
    name: "n8n_deactivate_workflow",
    description: "Deactivate a workflow to disable automatic execution",
    inputSchema: {
      type: "object",
      properties: {
        workflowId: {
          type: "string",
          description: "The ID of the workflow to deactivate",
        },
      },
      required: ["workflowId"],
    },
  },
  {
    name: "n8n_list_executions",
    description: "List workflow executions with optional filtering",
    inputSchema: {
      type: "object",
      properties: {
        workflowId: {
          type: "string",
          description: "Filter by workflow ID (optional)",
        },
        status: {
          type: "string",
          enum: ["success", "error", "waiting", "running"],
          description: "Filter by execution status",
        },
        limit: {
          type: "number",
          description: "Maximum number of executions to return (default: 20)",
        },
        offset: {
          type: "number",
          description: "Number of executions to skip for pagination (default: 0)",
        },
      },
    },
  },
  {
    name: "n8n_get_execution",
    description: "Get details of a specific workflow execution",
    inputSchema: {
      type: "object",
      properties: {
        executionId: {
          type: "string",
          description: "The ID of the execution to retrieve",
        },
      },
      required: ["executionId"],
    },
  },
  {
    name: "n8n_delete_execution",
    description: "Delete a workflow execution record",
    inputSchema: {
      type: "object",
      properties: {
        executionId: {
          type: "string",
          description: "The ID of the execution to delete",
        },
      },
      required: ["executionId"],
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
      case "n8n_search_workflows": {
        const params = new URLSearchParams();
        if (args.query) params.append("filter", args.query);
        if (args.limit) params.append("take", args.limit);

        const result = await callN8NAPI(
          "GET",
          `/workflows?${params.toString()}`
        );
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_get_workflow_details": {
        const result = await callN8NAPI(
          "GET",
          `/workflows/${args.workflowId}`
        );
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_execute_workflow": {
        const body = { data: args.inputs || {} };
        const result = await callN8NAPI(
          "POST",
          `/workflows/${args.workflowId}/execute`,
          body
        );
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_create_workflow": {
        const body = {
          name: args.name,
          nodes: args.nodes || [],
          connections: args.connections || {},
          active: args.active || false,
          tags: args.tags || [],
        };
        const result = await callN8NAPI("POST", "/workflows", body);
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_update_workflow": {
        const body = {};
        if (args.name !== undefined) body.name = args.name;
        if (args.nodes !== undefined) body.nodes = args.nodes;
        if (args.connections !== undefined) body.connections = args.connections;
        if (args.active !== undefined) body.active = args.active;
        if (args.tags !== undefined) body.tags = args.tags;

        const result = await callN8NAPI(
          "PATCH",
          `/workflows/${args.workflowId}`,
          body
        );
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_delete_workflow": {
        await callN8NAPI("DELETE", `/workflows/${args.workflowId}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                success: true,
                message: `Workflow ${args.workflowId} deleted successfully`,
              }),
            },
          ],
        };
      }

      case "n8n_activate_workflow": {
        const result = await callN8NAPI(
          "PATCH",
          `/workflows/${args.workflowId}`,
          { active: true }
        );
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_deactivate_workflow": {
        const result = await callN8NAPI(
          "PATCH",
          `/workflows/${args.workflowId}`,
          { active: false }
        );
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_list_executions": {
        const params = new URLSearchParams();
        if (args.workflowId) params.append("filter", `workflowId:${args.workflowId}`);
        if (args.status) params.append("status", args.status);
        params.append("take", args.limit || 20);
        params.append("skip", args.offset || 0);

        const result = await callN8NAPI(
          "GET",
          `/executions?${params.toString()}`
        );
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_get_execution": {
        const result = await callN8NAPI(
          "GET",
          `/executions/${args.executionId}`
        );
        return { content: [{ type: "text", text: JSON.stringify(result) }] };
      }

      case "n8n_delete_execution": {
        await callN8NAPI("DELETE", `/executions/${args.executionId}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                success: true,
                message: `Execution ${args.executionId} deleted successfully`,
              }),
            },
          ],
        };
      }

      default:
        return {
          content: [
            {
              type: "text",
              text: `Unknown tool: ${name}`,
              isError: true,
            },
          ],
        };
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
          isError: true,
        },
      ],
    };
  }
});

/**
 * Start the server
 */
const transport = new StdioServerTransport();
server.connect(transport);
