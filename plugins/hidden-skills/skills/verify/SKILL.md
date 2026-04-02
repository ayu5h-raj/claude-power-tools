---
name: verify
description: Verify a code change by launching the adversarial verification agent that tries to break the implementation
when_to_use: Use when implementation is complete and you want to verify it works correctly. Triggers - 'verify this', 'check if this works', 'run verification', 'does this actually work', 'test this implementation'
argument-hint: "[task description or what to verify]"
arguments:
  - description
---

# Verify Implementation

Launch the `verification-agent` to adversarially test the current implementation.

## Goal
Produce a PASS/FAIL/PARTIAL verdict with command-output evidence for every check. The verification agent tries to BREAK the implementation, not confirm it works.

## Steps

### 1. Gather Context
Collect the following information to pass to the verification agent:
- **Task description**: What was the user trying to accomplish? Use `$description` if provided, otherwise infer from recent conversation and git history.
- **Files changed**: Run `git diff --name-only` to get the list of modified files.
- **Approach taken**: Summarize the implementation approach from the conversation context.
- **Plan file**: Check if there's an active plan file that describes success criteria.

**Success criteria**: You have a clear task description, file list, and approach summary.

### 2. Launch Verification Agent
Spawn the `verification-agent` as a background agent with the gathered context:

```
Task: [task description]
Files changed: [file list]
Approach: [approach summary]
Plan/spec: [path to plan if exists]
```

The verification agent will:
- Read CLAUDE.md/README for build/test commands
- Run build, tests, linters
- Apply type-specific verification strategies
- Run adversarial probes (concurrency, boundaries, idempotency)
- Produce a structured report with VERDICT

**Success criteria**: Verification agent launched and running in background.

### 3. Report Results
When the verification agent completes, report its verdict to the user:
- **PASS**: All checks passed, including adversarial probes
- **FAIL**: Include what failed, exact error output, reproduction steps
- **PARTIAL**: What was verified, what couldn't be verified and why

**Success criteria**: User has the verification verdict with full evidence.
