---
name: security-review
description: "Perform a security-focused code review of pending changes on the current branch, identifying high-confidence vulnerabilities"
when_to_use: "Use when the user wants a security review of their code changes, PR, or branch. Triggers: 'security review', 'check for vulnerabilities', 'security audit code', 'review security', 'find security issues'"
context: fork
---

# Security Review

Launch the `security-reviewer` agent to perform a comprehensive security audit of pending code changes.

## Goal
Identify HIGH-CONFIDENCE security vulnerabilities (>80% exploitability) in the current branch's changes, with structured findings including severity, exploit scenarios, and fix recommendations.

## Steps

### 1. Launch Security Review
Spawn the `security-reviewer` agent with the current branch context. The agent will:
- Gather git diff, status, and commit history
- Research existing security patterns in the codebase
- Compare new code against established secure practices
- Assess each change for vulnerability categories (injection, auth bypass, crypto, XSS, data exposure)
- Filter false positives using parallel sub-agents with confidence scoring

**Success criteria**: Security reviewer agent launched and running.

### 2. Report Results
Present the filtered findings with:
- Only vulnerabilities scoring 8+/10 confidence
- Structured format: file:line, severity, category, exploit scenario, fix recommendation
- Summary of files reviewed and categories checked

**Success criteria**: User has actionable security findings with no false positive noise.
