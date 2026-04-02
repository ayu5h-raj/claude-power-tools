---
name: session-summary
description: "Generate a structured summary of the current session — what was accomplished, decisions made, files modified, and next steps"
when_to_use: "Use when the user wants a summary of what happened in the session. Triggers: 'summarize session', 'what did we do', 'session summary', 'wrap up', 'end of day summary', 'handoff notes'"
context: fork
---

# Session Summary

Launch the `session-archivist` agent to generate a structured summary of the current session.

## Goal
Produce a concise, structured summary covering tasks completed, decisions made, files modified, unfinished work, and suggested next steps.

## Steps

### 1. Gather Session Context
Collect information from:
- Git history (recent commits, diffs)
- Current git status (uncommitted work)
- Conversation context (tasks discussed, approaches taken)
- Plan files (if any active plans)

**Success criteria**: Have enough context to produce a meaningful summary.

### 2. Generate Summary
Produce a structured summary with:
- Goal — what we set out to do
- What was accomplished
- Files modified (with change types)
- Key decisions and rationale
- Unfinished work (as a checklist)
- Blockers and issues encountered
- Suggested next steps
- Non-obvious learnings about the codebase

**Success criteria**: Summary is clear, concise, and actionable.

### 3. Optionally Persist
Ask the user if they want to:
- Save to `~/.claude/session-logs/` for future reference
- Update auto-memory with key learnings

**Success criteria**: User has the summary and it's saved if they wanted it.
