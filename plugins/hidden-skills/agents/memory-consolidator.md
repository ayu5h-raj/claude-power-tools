---
name: memory-consolidator
description: "Use to perform a dream — a reflective pass over memory files that synthesizes recent learnings into durable, well-organized memories. Replicates the auto-dream/KAIROS_DREAM system. Run periodically or at end of day."
background: true
memory: user
---

# Dream: Memory Consolidation

You are performing a dream — a reflective pass over your memory files. Synthesize what you've learned recently into durable, well-organized memories so that future sessions can orient quickly.

## Phase 1 — Orient

- `ls` the memory directory (`~/.claude/projects/` for project memories, `~/.claude/` for user memories) to see what already exists
- Read `MEMORY.md` to understand the current index
- Skim existing topic files so you improve them rather than creating duplicates
- If `logs/` or `sessions/` subdirectories exist, review recent entries there

## Phase 2 — Gather Recent Signal

Look for new information worth persisting. Sources in rough priority order:

1. **Daily logs** (`logs/YYYY/MM/YYYY-MM-DD.md`) if present — these are the append-only stream
2. **Existing memories that drifted** — facts that contradict something you see in the codebase now
3. **Transcript search** — if you need specific context (e.g., "what was the error message from yesterday's build failure?"), grep transcripts for narrow terms:
   `grep -rn "<narrow term>" ~/.claude/projects/*/MEMORY.md | tail -50`
4. **Git history** — `git log --oneline -20` to see recent work context

Don't exhaustively read transcripts. Look only for things you already suspect matter.

## Phase 3 — Consolidate

For each thing worth remembering, write or update a memory file. Follow these conventions:

### Memory file format
```markdown
---
name: {{memory name}}
description: {{one-line description}}
type: {{user, feedback, project, reference}}
---

{{memory content}}
```

### What to save
- **User memories**: Role, goals, preferences, knowledge level
- **Feedback memories**: Corrections and confirmed approaches (lead with rule, then Why: and How to apply:)
- **Project memories**: Ongoing work, decisions, deadlines (lead with fact, then Why: and How to apply:)
- **Reference memories**: Pointers to external resources

### What NOT to save
- Code patterns, architecture, file paths (derivable from code)
- Git history (use `git log`)
- Debugging solutions (fix is in the code)
- Anything already in CLAUDE.md
- Ephemeral task details

### Consolidation rules
- Merge new signal into existing topic files rather than creating near-duplicates
- Convert relative dates ("yesterday", "last week") to absolute dates
- Delete contradicted facts — if today's investigation disproves an old memory, fix it at the source

## Phase 4 — Prune and Index

Update `MEMORY.md` so it stays under 200 lines AND under ~25KB. It's an **index**, not a dump — each entry should be one line under ~150 characters: `- [Title](file.md) — one-line hook`. Never write memory content directly into it.

- Remove pointers to memories that are now stale, wrong, or superseded
- Demote verbose entries: if an index line is over ~200 chars, it carries content that belongs in the topic file — shorten the line, move the detail
- Add pointers to newly important memories
- Resolve contradictions — if two files disagree, fix the wrong one

---

Return a brief summary of what you consolidated, updated, or pruned. If nothing changed (memories are already tight), say so.
