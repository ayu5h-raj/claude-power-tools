# Feature Flags Guide

Claude Code uses a feature flag system that controls access to experimental and internal capabilities. This guide documents how it works and which flags can be overridden.

## How Feature Flags Work

**Source:** `src/_shims/bun-bundle.ts`

```typescript
function feature(name: string): boolean {
  // 1. Explicit env var override (highest priority)
  if (process.env[`FEATURE_${name}`] === '1') return true
  if (process.env[`FEATURE_${name}`] === '0') return false
  
  // 2. Master override
  if (process.env.ENABLE_ALL_FEATURES === '1') return true
  
  // 3. Category-based defaults
  if (ANT_ONLY.has(name)) return false    // Internal features — blocked
  if (SAFE_EXTERNAL.has(name)) return true // External features — enabled
  
  return false
}
```

## Enabling Features

### Enable all safe-external features
```bash
ENABLE_ALL_FEATURES=1 claude
```

### Enable specific features
```bash
FEATURE_WEB_BROWSER_TOOL=1 claude
FEATURE_AGENT_TRIGGERS=1 claude
```

### Make it permanent (add to shell profile)
```bash
# ~/.zshrc or ~/.bashrc
export FEATURE_WEB_BROWSER_TOOL=1
export FEATURE_AGENT_TRIGGERS=1
```

### Disable a specific feature
```bash
FEATURE_QUICK_SEARCH=0 claude
```

## Safe-External Features

These features are designed for external users and are enabled by default in most builds. If they're not active for you, enable them explicitly:

| Flag | What It Does | How to Enable |
|------|-------------|---------------|
| `WEB_BROWSER_TOOL` | Browser automation tool for web testing | `FEATURE_WEB_BROWSER_TOOL=1` |
| `WORKFLOW_SCRIPTS` | Bundled multi-step workflow execution | `FEATURE_WORKFLOW_SCRIPTS=1` |
| `AGENT_TRIGGERS` | `/loop` command for cron-scheduled tasks | `FEATURE_AGENT_TRIGGERS=1` |
| `AGENT_TRIGGERS_REMOTE` | Remote scheduled agents on claude.ai | `FEATURE_AGENT_TRIGGERS_REMOTE=1` |
| `MCP_SKILLS` | MCP server prompts exposed as slash commands | `FEATURE_MCP_SKILLS=1` |
| `QUICK_SEARCH` | Ctrl+Shift+F global codebase search | `FEATURE_QUICK_SEARCH=1` |
| `HISTORY_PICKER` | Enhanced conversation history picker | `FEATURE_HISTORY_PICKER=1` |
| `MESSAGE_ACTIONS` | Shift+Up message action menu | `FEATURE_MESSAGE_ACTIONS=1` |
| `EXTRACT_MEMORIES` | Auto memory extraction from sessions | `FEATURE_EXTRACT_MEMORIES=1` |
| `TOKEN_BUDGET` | Intelligent token budget continuation | `FEATURE_TOKEN_BUDGET=1` |
| `CONTEXT_COLLAPSE` | Context collapse for deep hierarchies | `FEATURE_CONTEXT_COLLAPSE=1` |
| `REACTIVE_COMPACT` | Reactive compaction on context errors | `FEATURE_REACTIVE_COMPACT=1` |
| `HISTORY_SNIP` | History snipping (SnipTool) for context | `FEATURE_HISTORY_SNIP=1` |
| `FORK_SUBAGENT` | Fork subagent execution model | `FEATURE_FORK_SUBAGENT=1` |
| `FILE_PERSISTENCE` | File state persistence across turns | `FEATURE_FILE_PERSISTENCE=1` |
| `TEMPLATES` | Project templates support | `FEATURE_TEMPLATES=1` |
| `TREE_SITTER_BASH` | Tree-sitter AST parsing for Bash security | `FEATURE_TREE_SITTER_BASH=1` |
| `AUTO_THEME` | Automatic theme detection | `FEATURE_AUTO_THEME=1` |
| `PROMPT_CACHE_BREAK_DETECTION` | Detect and handle prompt cache invalidation | `FEATURE_PROMPT_CACHE_BREAK_DETECTION=1` |
| `TRANSCRIPT_CLASSIFIER` | Transcript-based command classification | `FEATURE_TRANSCRIPT_CLASSIFIER=1` |
| `CACHED_MICROCOMPACT` | Cached micro-compaction for efficiency | `FEATURE_CACHED_MICROCOMPACT=1` |
| `COMPACTION_REMINDERS` | Post-compaction context reminders | `FEATURE_COMPACTION_REMINDERS=1` |
| `STREAMLINED_OUTPUT` | Streamlined output formatting | `FEATURE_STREAMLINED_OUTPUT=1` |
| `HOOK_PROMPTS` | Prompt-type hooks support | `FEATURE_HOOK_PROMPTS=1` |
| `BUILTIN_EXPLORE_PLAN_AGENTS` | Built-in Explore and Plan agent types | `FEATURE_BUILTIN_EXPLORE_PLAN_AGENTS=1` |

## Ant-Only Features (Cannot Be Enabled)

These are compiled out at build time for external users. Setting `FEATURE_KAIROS=1` will NOT work because the code paths don't exist in the external build:

| Flag | What It Is |
|------|-----------|
| `KAIROS` | Assistant mode (persistent background agent) |
| `KAIROS_BRIEF` | Brief-only output mode |
| `KAIROS_DREAM` | Auto-dream memory consolidation |
| `KAIROS_CHANNELS` | Custom communication channels |
| `KAIROS_GITHUB_WEBHOOKS` | GitHub event subscriptions |
| `KAIROS_PUSH_NOTIFICATION` | OS push notifications |
| `BUDDY` | Companion pet system (18 species) |
| `REVIEW_ARTIFACT` | Hunter skill (bug hunting) |
| `ULTRAPLAN` | Multi-agent planning via web |
| `ULTRATHINK` | Extended thinking mode |
| `CHICAGO_MCP` | Computer use (macOS screen control) |
| `VERIFICATION_AGENT` | Built-in verification agent |
| `LODESTONE` | Internal navigation system |
| `TORCH` | Internal debugging tool |
| `ABLATION_BASELINE` | A/B testing baseline |
| `SKILL_IMPROVEMENT` | Skill auto-improvement system |
| `RUN_SKILL_GENERATOR` | Automated skill generation |
| `BUILDING_CLAUDE_APPS` | Claude API skill |
| `CONNECTOR_TEXT` | MCP connector text |
| `ANTI_DISTILLATION_CC` | Anti-distillation protections |
| `ENHANCED_TELEMETRY_BETA` | Extended telemetry |
| `SHOT_STATS` | Usage statistics |

**This is why claude-power-tools exists** — we replicate these ant-only capabilities as custom agents and skills that work without any feature flags.

## Other Useful Environment Variables

| Variable | What It Does |
|----------|-------------|
| `CLAUDE_CODE_COORDINATOR_MODE=1` | Enable multi-agent coordinator mode |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Disable telemetry and registry checks |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1` | Disable CLAUDE.md loading |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=80` | Override auto-compaction threshold |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW=50000` | Override compact window size |
| `CLAUDE_CODE_BRIEF=1` | Enable brief mode (dev bypass) |
| `CLAUDE_CODE_ENABLE_THINKING=false` | Disable extended thinking |
| `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=1` | Enable prompt suggestions |

## GrowthBook Server-Side Gates

Some features are controlled server-side via GrowthBook (A/B testing). These cannot be overridden locally:

| Gate | Feature |
|------|---------|
| `tengu_hive_evidence` | Verification agent eligibility |
| `tengu_amber_stoat` | Explore/Plan agent eligibility |
| `tengu_surreal_dali` | Remote triggers eligibility |
| `tengu_kairos_brief` | Brief mode entitlement |
| `tengu_onyx_plover` | Auto-dream timing config |
| `tengu_amber_quartz_disabled` | Voice mode kill-switch |
| `tengu_thinkback` | Year-in-review feature |
