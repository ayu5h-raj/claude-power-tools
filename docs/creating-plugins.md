# Creating Your Own Claude Code Plugins

This guide covers how to create, structure, and publish your own Claude Code plugins and marketplaces — based on the source code analysis of `src/utils/plugins/schemas.ts`.

## Plugin Structure

A plugin is a directory with a `.claude-plugin/plugin.json` manifest:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Required manifest
├── agents/
│   └── my-agent.md          # Agent definitions (markdown + YAML frontmatter)
├── skills/
│   └── my-skill/
│       └── SKILL.md          # Skill definitions
├── commands/
│   └── my-command.md         # Slash commands
└── hooks/
    └── hooks.json            # Hook configurations
```

## plugin.json Reference

```json
{
  "name": "my-plugin",              // Required: kebab-case identifier
  "version": "1.0.0",               // Semver
  "description": "What it does",
  "author": {
    "name": "Your Name",            // Required if author field present
    "email": "you@example.com",
    "url": "https://github.com/you"
  },
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/you/plugin",
  "license": "MIT",                  // SPDX identifier
  "keywords": ["tag1", "tag2"],

  // Components — paths relative to plugin root (must start with ./)
  "agents": [                        // Must be .md files (not directories)
    "./agents/agent-one.md",
    "./agents/agent-two.md"
  ],
  "skills": "./skills/",            // Can be directory path
  "commands": "./commands/",          // .md files or directory
  "hooks": "./hooks/hooks.json",     // .json file or inline object

  // MCP/LSP servers
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["server.js"],
      "env": { "PORT": "3000" }
    }
  },
  "lspServers": {
    "my-lsp": {
      "command": "my-language-server",
      "args": ["--stdio"],
      "extensionToLanguage": { ".xyz": "xyz-lang" }
    }
  },

  // User configuration (prompted on install)
  "userConfig": {
    "apiKey": {
      "type": "string",
      "title": "API Key",
      "description": "Your service API key",
      "required": true,
      "sensitive": true            // Stored in keychain
    }
  }
}
```

### Path Rules
- All paths must start with `./` (relative to plugin root, NOT .claude-plugin/)
- No `..` allowed (security: prevents path traversal)
- Agent paths must end in `.md`
- Skills paths can be directories (scanner finds SKILL.md inside)

## Agent File Format

Agents are markdown files with YAML frontmatter:

```markdown
---
name: my-agent                          # 3-50 chars, alphanumeric + hyphens
description: "When to use this agent"   # Required
tools: Bash, Read, Glob, Grep          # Optional: comma-separated (omit for all)
disallowedTools: Write, Edit            # Optional: tools to deny
model: inherit                          # Optional: inherit or model ID
effort: high                            # Optional: low/medium/high
memory: user                           # Optional: user/project/local
background: true                        # Optional: run as background task
isolation: worktree                     # Optional: worktree for git isolation
maxTurns: 30                            # Optional: max agentic turns
color: red                              # Optional: display color
hooks:                                  # Optional: session-scoped hooks
  PostToolUse:
    - hooks:
        - type: command
          command: "echo done"
skills: skill1, skill2                  # Optional: preload skills
initialPrompt: "/skill-x"              # Optional: prepended to first turn
---

System prompt goes here as the markdown body.
This is what the agent "sees" as its instructions.
```

### Available Colors
red, blue, green, yellow, magenta, cyan, orange, purple

### Memory Scopes
- `user`: `~/.claude/agent-memory/{agent-name}/MEMORY.md` — persists across all projects
- `project`: `.claude/agent-memory/{agent-name}/MEMORY.md` — per-project
- `local`: `.claude/agent-memory-local/{agent-name}/MEMORY.md` — per-session

## Skill File Format

Skills are SKILL.md files with YAML frontmatter:

```markdown
---
name: my-skill
description: "One-line description"
when_to_use: "Use when the user wants to X. Triggers: 'do X', 'run X'"
allowed-tools:
  - Read
  - Bash(git:*)
  - Grep
argument-hint: "<target> [--flag]"
arguments:
  - target
  - flag
context: fork                           # Optional: fork for sub-agent, omit for inline
---

# Skill Title

Description of what this skill does.

## Goal
Clear success criteria.

## Steps

### 1. First Step
Instructions...

**Success criteria**: What proves this step is done.

### 2. Second Step
Instructions using `$target` argument...

**Success criteria**: What proves this step is done.
```

### Key Frontmatter Fields
- `when_to_use`: CRITICAL — tells Claude when to auto-invoke. Include trigger phrases.
- `allowed-tools`: Use patterns like `Bash(git:*)` for scoped permissions
- `context: fork`: Run as independent sub-agent (best for self-contained tasks)
- `arguments`: Names used as `$name` in the body for substitution

## Marketplace Structure

A marketplace is a GitHub repo that indexes multiple plugins:

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # Required index
└── plugins/
    ├── plugin-a/
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   └── ...
    └── plugin-b/
        └── ...
```

### marketplace.json

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name",
    "url": "https://github.com/you"
  },
  "plugins": [
    {
      "name": "plugin-a",
      "description": "What plugin A does",
      "source": "./plugins/plugin-a",
      "version": "1.0.0",
      "category": "productivity",
      "tags": ["tag1", "tag2"]
    },
    {
      "name": "plugin-b",
      "description": "External plugin from another repo",
      "source": {
        "source": "github",
        "repo": "other-user/other-repo"
      }
    }
  ]
}
```

### Plugin Source Types

Plugins can be sourced from:

| Type | Format |
|------|--------|
| Relative path | `"./plugins/my-plugin"` |
| GitHub | `{"source": "github", "repo": "owner/repo", "ref": "main"}` |
| Git | `{"source": "git", "url": "https://...", "ref": "main"}` |
| npm | `{"source": "npm", "package": "@org/plugin", "version": "^1.0"}` |
| pip | `{"source": "pip", "package": "plugin", "version": ">=1.0"}` |
| URL | `{"source": "url", "url": "https://..."}` |
| Local dir | `{"source": "directory", "path": "/path/to/plugin"}` |
| Monorepo | `{"source": "git-subdir", "url": "owner/repo", "path": "tools/plugin"}` |

## Publishing

1. Push your marketplace repo to GitHub
2. Users register it: `claude plugins marketplace add your-user/your-marketplace`
3. Users install plugins: `claude plugins install plugin-name@your-marketplace`

### Reserved Names
These marketplace names are reserved for Anthropic:
`claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `life-sciences`, `knowledge-work-plugins`

## CLI Commands

```bash
# Marketplace management
claude plugins marketplace add owner/repo
claude plugins marketplace remove marketplace-name
claude plugins marketplace update [marketplace-name]

# Plugin management
claude plugins install plugin@marketplace [--scope user|project]
claude plugins uninstall plugin@marketplace
claude plugins enable plugin@marketplace
claude plugins disable plugin@marketplace
claude plugins list
```

### Installation Scopes
- `user`: `~/.claude/settings.json` (global, follows you everywhere)
- `project`: `./.claude/settings.json` (current project only)
