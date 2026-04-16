---
description: MCP Safety Protocol and Global Isolation Rule
---

# FleetMan MCP Isolation Protocol

**CRITICAL RULE**: Whenever you are asked to invoke an MCP server tool (e.g. `supabase-mcp-server_execute_sql` or `vercel-mcp-server_deploy_to_vercel` or anything similar), you MUST utilize the explicitly hardcoded local environment variables to prevent global workspace contamination. 

### Hardcoded Workspace Identifiers
- **Vercel Target Project**: `prj_YEBtNxsQHaXCUoOAdJP0YTJwNXzf` (Team: `team_QvCmtB39fQmCmLF41XnzP5de`)
- **Supabase Target DB**: `mzuippdkhsqifxacssex`

### Instructions for Agent:
1. Do **NOT** list projects to "find" the ID. You already possess the isolated ID.
2. Directly insert `mzuippdkhsqifxacssex` into the `project_id` parameter for Supabase MCP queries.
3. Directly insert `prj_YEBtNxsQHaXCUoOAdJP0YTJwNXzf` into the `projectId` parameter for Vercel MCP workflows.
4. If a task requires deploying or running SQL via MCP without these parameters, you must abort the command and alert the user.
