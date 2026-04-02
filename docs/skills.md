# Skills Reference

Skills are reusable workflow definitions invoked with `/skill-name`. They guide Claude through multi-step processes with clear success criteria.

**Install location:** `~/.claude/skills/{name}/SKILL.md`

---

## /verify

**Source:** `src/skills/bundled/verify.ts` — gated by `process.env.USER_TYPE !== 'ant'`

**What it does:** Launches the `verification-agent` to adversarially test your implementation.

**Usage:**
```
/verify                                    # Verify recent changes
/verify Check the auth middleware          # Verify specific feature
```

**Workflow:**
1. Gathers context: task description, files changed (from git diff), approach taken
2. Spawns verification-agent in background
3. Reports PASS/FAIL/PARTIAL verdict with command evidence

**Why this exists:** The built-in `/verify` skill silently does nothing for non-Anthropic users. This replica uses a custom agent definition that works for everyone.

---

## /skillify

**Source:** `src/skills/bundled/skillify.ts` — gated by `process.env.USER_TYPE !== 'ant'` (156-line prompt)

**What it does:** Captures a session's repeatable process into a reusable SKILL.md file through a 4-round interview.

**Usage:**
```
/skillify                                  # Analyze current session
/skillify Deploy hotfix to production      # With description
```

**Interview rounds:**
1. **High-level confirmation:** Name, description, goals, success criteria
2. **Details:** Steps, arguments, inline vs forked, save location (repo or personal)
3. **Step breakdown:** Per-step data flow, success criteria, human checkpoints, parallelism, constraints
4. **Final:** Trigger phrases, gotchas, edge cases

**Output:** Complete SKILL.md with frontmatter (name, description, allowed-tools, when_to_use, arguments) and step-by-step instructions with success criteria.

**Key design choices from source:**
- Uses `AskUserQuestion` for ALL questions (never plain text)
- Analyzes session memory and user messages for context
- Pays attention to user corrections during the session
- `disableModelInvocation: true` — must be explicitly invoked, never auto-triggered

---

## /remember

**Source:** `src/skills/bundled/remember.ts` — gated by `process.env.USER_TYPE !== 'ant'`

**What it does:** Reviews all memory layers and proposes organized changes.

**Usage:**
```
/remember                                  # Full memory review
/remember Focus on project conventions     # With context
```

**Classification targets:**

| Destination | What Belongs There |
|---|---|
| CLAUDE.md | Project conventions for all contributors |
| CLAUDE.local.md | Personal Claude instructions (not team-wide) |
| Team memory | Org-wide knowledge across repos |
| Stay in auto-memory | Working notes, temporary context |

**Actions proposed:**
1. **Promotions** — entries to move with rationale
2. **Cleanup** — duplicates, outdated entries, conflicts
3. **Ambiguous** — entries needing user input
4. **No action** — entries that should stay put

**Rules:** Presents ALL proposals before making changes. Never modifies without explicit approval.

---

## /security-review

**Source:** `src/commands/security-review.ts` — 196-line security review command

**What it does:** Performs a 3-phase security audit of pending code changes with parallel false-positive filtering.

**Usage:**
```
/security-review
```

**Phases:**
1. **Repository context research:** Existing security frameworks, sanitization patterns
2. **Comparative analysis:** New code vs established practices
3. **Vulnerability assessment:** Data flow tracing, injection point analysis

**Categories (90+ patterns):** SQL injection, XSS, command injection, XXE, template injection, NoSQL injection, path traversal, auth bypass, privilege escalation, JWT flaws, hardcoded secrets, weak crypto, RCE, deserialization, pickle injection, data exposure, PII leaks

**False-positive filtering:** Each finding gets a parallel sub-agent that validates it against 17 hard exclusion rules and 12 precedents. Only findings scoring 8+/10 confidence make it to the report.

**Output format:**
```markdown
# Vuln N: [Category]: `file.py:line`
* Severity: High/Medium
* Confidence: 8-10/10
* Description: [vulnerability]
* Exploit Scenario: [attack path]
* Recommendation: [fix]
```

---

## /dep-audit

**What it does:** Launches the `dependency-auditor` agent for a comprehensive dependency analysis.

**Usage:**
```
/dep-audit                    # Full audit
/dep-audit --fix              # Audit + propose fix commands
/dep-audit lodash             # Focus on specific package
```

**Covers:** Security vulnerabilities (CVEs), outdated packages, unused dependencies, license compliance.

**Supported ecosystems:** Node.js, Rust, Python, Go, Ruby, PHP, Java/Kotlin.

---

## /session-summary

**What it does:** Generates a structured summary of the current session.

**Usage:**
```
/session-summary
```

**Output includes:** Goal, accomplishments, files modified, key decisions, unfinished work, blockers, next steps, learnings.

**Optionally persists** to `~/.claude/session-logs/` or updates auto-memory.

---

## /dream

**Source:** `src/services/autoDream/consolidationPrompt.ts` — the KAIROS_DREAM auto-dream system

**What it does:** Runs a 4-phase memory consolidation pass.

**Usage:**
```
/dream                        # Full consolidation
/dream Focus on project X     # With context
```

**Phases:**
1. **Orient** — Survey existing memory files and MEMORY.md index
2. **Gather** — Find new signal from logs, transcripts, git history
3. **Consolidate** — Merge learnings, fix stale facts, convert relative dates
4. **Prune** — Keep MEMORY.md under 200 lines / 25KB

**When to use:** End of day, end of week, or when memory feels cluttered. The internal system auto-triggers every ~24 hours after 5+ sessions.

**Rules:** Merge into existing files (don't create duplicates), delete contradicted facts at the source, never write content directly into MEMORY.md (it's an index).
