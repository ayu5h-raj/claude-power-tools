# Hooks Reference

Hooks are automated behaviors triggered by Claude Code events. They run shell commands, prompts, or agent checks at specific points during a session.

**Install location:** Merged into `~/.claude/settings.json` under the `hooks` key.

---

## PostToolUse: Post-Commit Verification

**Event:** `PostToolUse` with matcher `Bash` and condition `Bash(git commit*)`

**What it does:** After every `git commit`, automatically scans the committed diff for common issues:
- **Debug statements:** `console.log`, `debugger`, `print(`, `TODO.*HACK`, `FIXME`
- **Secrets/credentials:** AWS keys (`AKIA`), API keys (`sk-`), hardcoded passwords, `API_KEY` assignments

**Type:** `command` (shell)
**Timeout:** 10 seconds
**Blocking:** Yes (runs synchronously, output shown to user)

**How it works:**
1. Gets the list of changed files from `git diff HEAD~1 --name-only`
2. Greps each file for debug patterns
3. Greps the diff for secret patterns
4. Reports any issues found, or "Post-commit check: clean"

**Configuration:**
```json
{
  "PostToolUse": [{
    "matcher": "Bash",
    "hooks": [{
      "type": "command",
      "if": "Bash(git commit*)",
      "command": "...",
      "timeout": 10,
      "statusMessage": "Post-commit verification"
    }]
  }]
}
```

---

## PostCompact: Memory Restoration

**Event:** `PostCompact`

**What it does:** After context compaction (when Claude's conversation is summarized to fit within the context window), injects a prompt reminding the agent to re-read critical files.

**Why this matters:** Compaction drops older conversation context. Without this hook, Claude can "forget" project conventions, accumulated knowledge, and the contents of CLAUDE.md after a long session. This hook ensures critical context is re-loaded immediately.

**Type:** `prompt` (injected into Claude's context)
**Message:** "Context was compacted. Re-read CLAUDE.md, any active plan files, and auto-memory entries from ~/.claude/projects/ for project-specific memory before continuing."

**Configuration:**
```json
{
  "PostCompact": [{
    "hooks": [{
      "type": "prompt",
      "prompt": "Context was compacted. Re-read CLAUDE.md...",
      "statusMessage": "Restoring context after compaction"
    }]
  }]
}
```

---

## SubagentStop: Agent Completion Logging

**Event:** `SubagentStop`

**What it does:** Logs a timestamped entry to `~/.claude/logs/subagent-completions.log` whenever any subagent completes.

**Why this matters:** When running parallel agents (via `/batch`, manual spawning, or agent swarms), this provides a centralized log of what completed and when. Useful for:
- Tracking parallel work progress
- Post-session analysis of agent activity
- Debugging agent orchestration issues

**Type:** `command` (shell, async)
**Async:** Yes (non-blocking, doesn't slow down the session)
**Timeout:** 5 seconds

**Log format:**
```
[2026-04-02 14:30:15] Subagent completed in /path/to/project
```

**Configuration:**
```json
{
  "SubagentStop": [{
    "hooks": [{
      "type": "command",
      "command": "bash -c 'mkdir -p ~/.claude/logs && echo \"[$(date +\"%Y-%m-%d %H:%M:%S\")] Subagent completed in $(pwd)\" >> ~/.claude/logs/subagent-completions.log'",
      "async": true,
      "timeout": 5
    }]
  }]
}
```

---

## Available Hook Events

These are all the hook events Claude Code supports (from `src/entrypoints/sdk/coreSchemas.ts`):

| Event | When It Fires |
|-------|--------------|
| `PreToolUse` | Before a tool executes (can modify input or block) |
| `PostToolUse` | After a tool succeeds |
| `PostToolUseFailure` | After a tool fails |
| `UserPromptSubmit` | When user submits a message |
| `SessionStart` | When a session begins |
| `SessionEnd` | When a session ends |
| `Stop` | When Claude stops generating |
| `SubagentStart` | When a subagent is spawned |
| `SubagentStop` | When a subagent completes |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction |
| `PermissionRequest` | When a permission is requested |
| `PermissionDenied` | When a permission is denied |
| `TaskCreated` | When a task is created |
| `TaskCompleted` | When a task completes |
| `FileChanged` | When a watched file changes |
| `CwdChanged` | When the working directory changes |
| `ConfigChange` | When settings change |
| `WorktreeCreate` | When a git worktree is created |
| `WorktreeRemove` | When a git worktree is removed |
| `TeammateIdle` | When a teammate agent goes idle |
| `Setup` | One-time initialization |
| `Elicitation` | MCP authentication request |
| `ElicitationResult` | MCP authentication response |
| `InstructionsLoaded` | When CLAUDE.md files are loaded |

## Hook Types

| Type | What It Does |
|------|-------------|
| `command` | Runs a shell command. Stdout is shown to user. |
| `prompt` | Injects text into Claude's context (like a system message). |
| `agent` | Spawns a forked agent to evaluate the hook. |
| `http` | POSTs the hook input as JSON to a URL (webhook). |
