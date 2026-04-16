# Tool Usage Rules

## Disabled Tools
- **NEVER** use the Web Search tool as it does not work in my setup.
- **NEVER** use `perplexity_search`, `perplexity_reason`, or
  `perplexity_research` - these models are not available.

## Web Search
- **ALWAYS** use the Perplexity MCP server for web searches, exclusively via the
  `perplexity_ask` tool.
- Use `perplexity_ask` for all search needs: factual questions, research,
  reasoning, and general Q&A.

## Tool Preferences
- **ALWAYS** prefer built-in tools for reading / writing / finding / ... files
  instead of using bash with some CLI.

## Explore Agent
- Before launching an Explore agent, always check that the current working
  directory is non-empty (e.g. contains actual files or subdirectories). Do not
  launch an Explore agent in an empty directory.
