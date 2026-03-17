import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { registerAllTools } from './tools/registry.js';
import { initConfig } from './config.js';

const config = initConfig();

const server = new McpServer({
  name: 'billingo',
  version: '1.0.0',
});

registerAllTools(server, config);

if (config.mockMode) {
  console.error('[billingo-mcp] Running in MOCK mode — no API calls will be made');
} else {
  console.error('[billingo-mcp] Connected to Billingo API');
}

const transport = new StdioServerTransport();
await server.connect(transport);
