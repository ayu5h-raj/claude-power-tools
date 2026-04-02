# Claude Power Tools

Unlocked skills, agents, and hooks extracted from Claude Code's source code that are normally restricted to Anthropic internal employees (`ant` users) or hidden behind feature flags.

## What's Inside

### Hidden Skills (ant-only, now available to everyone)

| Skill | Source | What It Does |
|-------|--------|-------------|
| `/verify` | `src/skills/bundled/verify.ts` | Launches an adversarial verification agent that tries to **break** your implementation, producing PASS/FAIL/PARTIAL verdicts with command evidence |
| `/skillify` | `src/skills/bundled/skillify.ts` | 4-round interview that extracts a session's repeatable process into a reusable SKILL.md file |
| `/remember` | `src/skills/bundled/remember.ts` | Reviews all memory layers (auto-memory, CLAUDE.md, CLAUDE.local.md, team memory) and proposes promotions, cleanups, and deduplication |
| `/dep-audit` | *New* | Audits dependencies for security vulnerabilities, outdated packages, unused deps, and license compliance |
| `/session-summary` | *New (replicates KAIROS_DREAM)* | Generates structured session summaries for handoffs, end-of-day reviews, or resuming work |
| `/security-review` | `src/commands/security-review.ts` | Security-focused code review with 90+ vulnerability patterns, false-positive filtering, and confidence scoring (8+/10 threshold) |
| `/dream` | `src/services/autoDream/consolidationPrompt.ts` | 4-phase memory consolidation (Orient/Gather/Consolidate/Prune) — replicates the KAIROS_DREAM auto-dream system |

### Custom Agents

| Agent | Source | What It Does |
|-------|--------|-------------|
| `verification-agent` | `src/tools/AgentTool/built-in/verificationAgent.ts` | Battle-tested 128-line adversarial verification prompt — runs builds, tests, linters, curls endpoints, probes concurrency/boundaries/idempotency |
| `research-scout` | *New* | Deep codebase research with parallel search vectors, call graph tracing, and synthesized briefs |
| `pr-shepherd` | *New* | End-to-end PR lifecycle — branch, commit, push, create PR, monitor CI |
| `dependency-auditor` | *New* | Background security/health audit across Node.js, Rust, Python, Go ecosystems |
| `session-archivist` | *New (replicates KAIROS_DREAM)* | Session summary generator with decisions, files modified, unfinished work, next steps |
| `security-reviewer` | `src/commands/security-review.ts` | Full security review pipeline with 3-phase analysis, parallel false-positive filtering, and confidence-scored findings |
| `memory-consolidator` | `src/services/autoDream/consolidationPrompt.ts` | Background memory consolidation agent — 4-phase dream process for organizing knowledge |

### Power Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| Post-Commit Check | `PostToolUse` | Scans commits for debug statements, secrets, and .gitignore violations |
| Memory Restore | `PostCompact` | Reminds agent to re-read CLAUDE.md and memory files after context compaction |
| Subagent Logger | `SubagentStop` | Logs subagent completions to `~/.claude/logs/subagent-completions.log` |

## Installation

### Option A: Clone & Install (simplest)

```bash
git clone https://github.com/ayushraj/claude-power-tools.git
cd claude-power-tools
./install.sh
```

This copies agents to `~/.claude/agents/` and skills to `~/.claude/skills/`. Hooks are optional (prompted during install).

To uninstall: `./uninstall.sh`

### Option B: Cherry-pick individual files

```bash
# Just the verification agent
cp plugins/hidden-skills/agents/verification-agent.md ~/.claude/agents/

# Just the /skillify skill
mkdir -p ~/.claude/skills/skillify
cp plugins/hidden-skills/skills/skillify/SKILL.md ~/.claude/skills/skillify/

# Just the /remember skill
mkdir -p ~/.claude/skills/remember
cp plugins/hidden-skills/skills/remember/SKILL.md ~/.claude/skills/remember/
```

### Option C: Marketplace Install (auto-updates)

```bash
# Register the marketplace
claude plugins marketplace add ayushraj/claude-power-tools

# Install plugins
claude plugins install hidden-skills@claude-power-tools
claude plugins install power-hooks@claude-power-tools
```

### Option D: Local Directory Plugin

```bash
git clone https://github.com/ayushraj/claude-power-tools.git ~/claude-power-tools
claude plugins marketplace add --source directory --path ~/claude-power-tools
claude plugins install hidden-skills@claude-power-tools
```

## Usage

### `/verify` — Adversarial Verification

After implementing a feature or fix:
```
/verify Check that the new auth middleware correctly rejects expired tokens
```

The verification agent runs in the background and produces a structured report:
- Runs build, tests, linters
- Applies type-specific verification (frontend, backend, CLI, infra, etc.)
- Runs adversarial probes (concurrency, boundary values, idempotency)
- Produces PASS/FAIL/PARTIAL verdict with command evidence

### `/skillify` — Session-to-Skill Extractor

After completing a repeatable workflow:
```
/skillify Deploy hotfix to production
```

Walks you through 4 interview rounds to capture the process as a reusable SKILL.md:
1. High-level confirmation (name, description, goals)
2. Step breakdown and arguments
3. Detailed per-step analysis
4. Trigger phrases and gotchas

### `/remember` — Memory Layer Review

```
/remember
```

Scans all memory layers and proposes:
- **Promotions**: auto-memory entries that belong in CLAUDE.md or CLAUDE.local.md
- **Cleanup**: duplicates, outdated entries, conflicts
- **Ambiguous**: entries needing your input on destination

### `/dep-audit` — Dependency Audit

```
/dep-audit
/dep-audit --fix
/dep-audit lodash
```

Runs security audit, checks for outdated/unused packages, verifies license compliance.

### `/session-summary` — Session Summary

```
/session-summary
```

Generates a structured summary of what was accomplished, decisions made, files modified, and next steps.

### `/security-review` — Security Code Review

```
/security-review
```

Performs a 3-phase security review of your current branch:
1. Repository context research (existing security patterns)
2. Comparative analysis (new code vs established practices)
3. Vulnerability assessment with parallel false-positive filtering

Only reports findings with confidence 8+/10. Covers SQL injection, XSS, command injection, auth bypass, crypto issues, deserialization, path traversal, and more.

### `/dream` — Memory Consolidation

```
/dream
```

Runs a 4-phase memory consolidation pass (replicates the internal KAIROS_DREAM system):
1. **Orient** — Survey existing memory files
2. **Gather** — Find new signal from logs, transcripts, git history
3. **Consolidate** — Merge learnings, fix stale facts, convert relative dates
4. **Prune** — Keep MEMORY.md index under 200 lines

## Feature Flags (Unlock Hidden Features)

Claude Code has a feature flag system that can be overridden via environment variables. This was found in `src/_shims/bun-bundle.ts`:

```bash
# Enable ALL safe-external features at once
ENABLE_ALL_FEATURES=1 claude

# Enable specific features individually
FEATURE_WEB_BROWSER_TOOL=1 claude        # Browser automation tool
FEATURE_WORKFLOW_SCRIPTS=1 claude         # Bundled workflow scripts
FEATURE_AGENT_TRIGGERS=1 claude           # /loop cron scheduling
FEATURE_AGENT_TRIGGERS_REMOTE=1 claude    # Remote scheduled agents
FEATURE_MCP_SKILLS=1 claude              # MCP prompts as slash commands
FEATURE_QUICK_SEARCH=1 claude            # Ctrl+Shift+F global search
FEATURE_MESSAGE_ACTIONS=1 claude         # Shift+Up message actions
FEATURE_HOOK_PROMPTS=1 claude            # Prompt-type hooks
```

### Safe-External Features (enabled by default, but may need explicit activation)

| Flag | What It Unlocks |
|------|----------------|
| `WEB_BROWSER_TOOL` | Browser automation tool for web testing |
| `WORKFLOW_SCRIPTS` | Bundled multi-step workflow scripts |
| `AGENT_TRIGGERS` | `/loop` cron scheduling for recurring tasks |
| `AGENT_TRIGGERS_REMOTE` | Remote scheduled agents on claude.ai |
| `MCP_SKILLS` | MCP server prompts exposed as slash commands |
| `QUICK_SEARCH` | Ctrl+Shift+F global search |
| `HISTORY_PICKER` | Enhanced history picker UI |
| `MESSAGE_ACTIONS` | Shift+Up message action menu |
| `EXTRACT_MEMORIES` | Auto memory extraction |
| `TOKEN_BUDGET` | Token budget continuation system |
| `CONTEXT_COLLAPSE` | Context collapse for deep hierarchies |
| `REACTIVE_COMPACT` | Reactive compaction on errors |
| `HISTORY_SNIP` | History snipping for context truncation |

### Ant-Only Features (internal, cannot be enabled externally)

These are compiled out at build time and cannot be enabled via env vars:
`KAIROS`, `KAIROS_DREAM`, `BUDDY`, `REVIEW_ARTIFACT`, `ULTRAPLAN`, `ULTRATHINK`, `CHICAGO_MCP` (computer use), `VERIFICATION_AGENT`, and more.

That's why this project exists — we replicate these capabilities as custom agents/skills that work without feature flags.

## Other Hidden Capabilities Found in Source

These were discovered during source analysis but are not yet replicated as skills:

| Capability | Gate | What It Does |
|-----------|------|--------------|
| Computer Use MCP | `CHICAGO_MCP` | macOS screen control (mouse, keyboard, screenshots) |
| GitHub Webhooks | `KAIROS_GITHUB_WEBHOOKS` | `SubscribePRTool` — react to repo events automatically |
| Push Notifications | `KAIROS` | `PushNotificationTool` — OS push notifications |
| Send User Files | `KAIROS` | `SendUserFileTool` — push files to user's machine |
| Sleep/Delay | `PROACTIVE` or `KAIROS` | `SleepTool` — scheduled delays for background tasks |
| Peer Discovery | `UDS_INBOX` | `ListPeersTool` — find collaborative sessions |
| Terminal Capture | ant-only | `TerminalCaptureTool` — stream terminal output |
| Process Monitor | hidden | `MonitorTool` — health checks and resource monitoring |
| Ultraplan | `ULTRAPLAN` | Multi-agent planning via Claude Code on the web (30-min timeout) |
| Brief Mode | `KAIROS_BRIEF` | Hide all output except structured messages |
| Advisor Model | model-dependent | Configure a secondary model to guide the main model |
| Buddy System | `BUDDY` | Companion pets (18 species, stats, rarity system) |
| Bash Classifier | ant-only | ML-based semantic Bash command auto-approval |
| `/insights` | ant-only | Massive session analytics with remote host aggregation |
| `/stuck` | ant-only | Diagnose frozen/stuck Claude Code sessions |
| `/think-back` | gated | Your Claude Code year-in-review |

## How It Works

Claude Code's source code contains capabilities gated behind three mechanisms:
1. **Ant-only checks** (`process.env.USER_TYPE !== 'ant'`) — restricted to Anthropic employees
2. **Build-time feature flags** (`feature('KAIROS')`) — compiled out for external builds
3. **Server-side gates** (GrowthBook) — A/B testing, gradual rollouts

This project extracts the prompts and patterns from these hidden features and packages them as standard Claude Code agents (`.md` files in `~/.claude/agents/`) and skills (`SKILL.md` files in `~/.claude/skills/`), which work without any feature flags.

## Creating Your Own Marketplace

Want to publish your own skills/agents? Claude Code supports third-party marketplaces:

1. Create a GitHub repo with this structure:
   ```
   your-marketplace/
   ├── .claude-plugin/
   │   └── marketplace.json
   └── plugins/
       └── your-plugin/
           ├── .claude-plugin/
           │   └── plugin.json
           ├── agents/
           │   └── your-agent.md
           └── skills/
               └── your-skill/
                   └── SKILL.md
   ```

2. `marketplace.json` format:
   ```json
   {
     "name": "your-marketplace",
     "owner": { "name": "Your Name" },
     "plugins": [
       {
         "name": "your-plugin",
         "description": "What it does",
         "source": "./plugins/your-plugin",
         "version": "1.0.0"
       }
     ]
   }
   ```

3. Users install with:
   ```bash
   claude plugins marketplace add your-github-user/your-marketplace
   claude plugins install your-plugin@your-marketplace
   ```

## Contributing

1. Fork this repo
2. Add your agent/skill to `plugins/hidden-skills/agents/` or `plugins/hidden-skills/skills/`
3. Update `plugin.json` if adding new paths
4. Submit a PR

## License

MIT
