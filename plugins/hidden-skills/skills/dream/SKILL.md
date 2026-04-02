---
name: dream
description: "Run a memory consolidation pass — synthesizes recent learnings into organized, durable memories. Replicates the KAIROS_DREAM auto-dream system."
when_to_use: "Use when the user wants to consolidate, organize, or clean up their memories. Also useful periodically (end of day, end of week). Triggers: 'dream', 'consolidate memory', 'organize memories', 'clean up memory', 'memory consolidation', 'end of day'"
context: fork
---

# Dream — Memory Consolidation

Launch the `memory-consolidator` agent to perform a reflective pass over memory files.

## Goal
Synthesize recent learnings into durable, well-organized memories through a 4-phase process: Orient, Gather, Consolidate, Prune.

## Steps

### 1. Launch Consolidation
Spawn the `memory-consolidator` agent in the background. It will:
- Survey existing memory files and index
- Gather recent signal from logs, transcripts, and git history
- Merge new learnings into existing topic files (avoiding duplicates)
- Convert relative dates to absolute dates
- Delete contradicted facts
- Prune and update the MEMORY.md index

**Success criteria**: Consolidation agent launched and running.

### 2. Report Results
When the agent completes, report what was consolidated, updated, or pruned.

**Success criteria**: User knows what changed in their memory files.
