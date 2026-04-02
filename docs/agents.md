# Agents Reference

Agents are autonomous specialists that Claude Code can invoke for specific tasks. Each agent runs as a sub-process with its own context, tools, and memory.

**Install location:** `~/.claude/agents/{name}.md`

---

## verification-agent

**Source:** Extracted from `src/tools/AgentTool/built-in/verificationAgent.ts` — the built-in verification agent gated behind `VERIFICATION_AGENT` flag + `tengu_hive_evidence` GrowthBook gate.

**Purpose:** Adversarial verification specialist that tries to **break** your implementation rather than confirm it works.

**How it works:**
1. Reads project's CLAUDE.md/README for build/test commands
2. Runs build — broken build is automatic FAIL
3. Runs test suite — failing tests are automatic FAIL
4. Runs linters/type-checkers
5. Applies type-specific verification strategies (frontend, backend, CLI, infra, mobile, data/ML, etc.)
6. Runs adversarial probes (concurrency, boundary values, idempotency, orphan operations)
7. Produces structured PASS/FAIL/PARTIAL verdict with command evidence

**Key design principles:**
- "Reading is not verification. Run it."
- "The implementer is an LLM too. Verify independently."
- Every check needs a `Command run:` block with actual output — no paraphrasing
- PARTIAL is only for environmental limitations, not uncertainty
- Must include at least one adversarial probe before issuing PASS

**Configuration:**
- Runs in background (`background: true`)
- Cannot modify project files (`disallowedTools: Agent, ExitPlanMode, Edit, Write, NotebookEdit`)
- Can write ephemeral test scripts to `/tmp`
- Remembers test patterns across sessions (`memory: user`)
- Visual indicator: red color

**Invocation:**
```
Use the verification-agent to verify: [task description]. Files changed: [list]. Approach: [summary].
```

---

## security-reviewer

**Source:** Extracted from `src/commands/security-review.ts` — a 196-line security review command with 90+ vulnerability patterns.

**Purpose:** Security-focused code review that identifies HIGH-CONFIDENCE vulnerabilities with >80% exploitability certainty.

**How it works:**
1. **Phase 1 — Repository Context Research:** Identifies existing security frameworks, sanitization patterns, and threat model
2. **Phase 2 — Comparative Analysis:** Compares new code against established secure practices, flags deviations
3. **Phase 3 — Vulnerability Assessment:** Examines each modified file, traces data flow from inputs to sensitive operations

**Vulnerability categories covered:**
- Input validation: SQL injection, command injection, XXE, template injection, NoSQL injection, path traversal
- Auth/authz: authentication bypass, privilege escalation, session flaws, JWT vulnerabilities
- Crypto: hardcoded secrets, weak algorithms, improper key storage
- Code execution: RCE via deserialization, pickle, YAML, eval, XSS
- Data exposure: PII leaks, API endpoint data leakage, debug info

**False-positive filtering (17 hard exclusions):**
- DOS/resource exhaustion, cached secrets, rate limiting, memory issues
- Outdated libraries, test-only files, log spoofing, SSRF path-only
- AI prompt injection, regex injection, documentation issues
- React/Angular XSS (unless using dangerouslySetInnerHTML)
- Client-side permission checks, shell script command injection

**Confidence scoring:** Only reports findings scoring 8+/10.

**Configuration:**
- Tools: Bash, Read, Glob, Grep, Agent (for parallel false-positive sub-agents)
- Memory: project (learns security patterns per project)
- Color: red

---

## research-scout

**Purpose:** Deep codebase research specialist that goes beyond quick searches by decomposing questions into parallel search vectors.

**How it works:**
1. Decomposes the research question into 3-5 orthogonal search vectors:
   - Definition search (where is it defined?)
   - Usage search (where is it used?)
   - Convention search (what patterns exist?)
   - History search (git log/blame for evolution)
   - Dependency search (what depends on it?)
2. Executes parallel tool calls for maximum efficiency
3. Traces call graphs (callers, callees, data flow, side effects)
4. Synthesizes into a structured brief with architecture diagrams

**Output format:**
- Summary (2-3 sentences)
- Architecture diagram (text)
- Key files table (path, lines, role)
- Data flow trace
- Patterns & conventions
- Open questions

**Configuration:**
- Read-only (`disallowedTools: Write, Edit, NotebookEdit`)
- High effort for thorough analysis (`effort: high`)
- Remembers codebase conventions (`memory: user`)

---

## pr-shepherd

**Purpose:** End-to-end PR lifecycle manager — from staged changes to merged PR.

**How it works:**
1. **Analyze state:** git status, diff, log, current branch
2. **Branch management:** Creates feature branch if on main/master
3. **Stage & commit:** Conventional commit messages (`type(scope): description`)
4. **Push & create PR:** Structured body with Summary, Changes, Test Plan, Breaking Changes
5. **Monitor CI:** Polls `gh pr checks`, analyzes failure logs, suggests fixes

**Configuration:**
- Tools limited to Bash, Read, Glob, Grep (no file editing)
- Memory: project (learns PR conventions, CI patterns)

**Safety rules:**
- Never force-push unless explicitly asked
- Never push to main/master directly
- Reports merge conflicts instead of auto-resolving
- Asks before adding reviewers or labels

---

## dependency-auditor

**Purpose:** Background security and health audit of project dependencies.

**How it works:**
1. **Detect ecosystem:** Scans for package.json, Cargo.toml, requirements.txt, go.mod, etc.
2. **Security audit:** Runs `npm audit`, `cargo audit`, `pip-audit`, `govulncheck`
3. **Check outdated:** Runs `npm outdated`, `cargo outdated`, `pip list --outdated`
4. **Detect unused:** Runs `depcheck` or grep-based import analysis
5. **License check:** Flags copyleft licenses in non-copyleft projects

**Output:** Structured report with tables for vulnerabilities, outdated packages, unused deps, license concerns, and prioritized actions.

**Configuration:**
- Runs in background (`background: true`)
- Read-only (`disallowedTools: Write, Edit, Agent`)
- Memory: project (remembers known issues, suppressed warnings)

---

## session-archivist

**Source:** Replicates the `KAIROS_DREAM` session memory consolidation pattern.

**Purpose:** Produces narrative session summaries for handoffs, end-of-day reviews, or resuming work.

**How it works:**
1. Gathers context from git (diff, log, status) and conversation
2. Extracts: task description, approach, files modified, decisions, unfinished work, blockers, learnings
3. Produces structured markdown summary
4. Optionally saves to `~/.claude/session-logs/`

**Output includes:**
- Goal, accomplishments, files modified table
- Key decisions with rationale
- Unfinished work checklist
- Blockers & issues
- Suggested next steps
- Non-obvious codebase learnings

---

## memory-consolidator

**Source:** Extracted from `src/services/autoDream/consolidationPrompt.ts` — the auto-dream consolidation system gated behind `KAIROS`/`KAIROS_DREAM` feature flags.

**Purpose:** Background memory consolidation agent that organizes knowledge through a 4-phase dream process.

**How it works:**
1. **Orient:** Survey existing memory files and MEMORY.md index
2. **Gather:** Find new signal from daily logs, drifted memories, transcript searches
3. **Consolidate:** Write/update memory files, merge signal into existing topics, convert relative dates, delete contradicted facts
4. **Prune:** Keep MEMORY.md index under 200 lines and 25KB, remove stale pointers, resolve contradictions

**Memory types managed:**
- User memories (role, preferences, knowledge)
- Feedback memories (corrections, confirmed approaches)
- Project memories (decisions, deadlines, context)
- Reference memories (external resource pointers)

**Configuration:**
- Runs in background (`background: true`)
- Memory: user (meta — remembers consolidation patterns)

**When to run:** End of day, end of week, or whenever memory feels cluttered. The internal auto-dream system runs automatically every ~24 hours after 5+ sessions.
