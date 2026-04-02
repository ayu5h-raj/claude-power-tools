---
name: dep-audit
description: "Run a comprehensive dependency audit for security vulnerabilities, outdated packages, unused dependencies, and license compliance"
when_to_use: "Use when the user wants to check dependencies for security issues, outdated packages, or license compliance. Triggers: 'audit dependencies', 'check for vulnerabilities', 'security audit', 'outdated packages', 'dep audit', 'dependency check'"
argument-hint: "[--fix | package-name]"
arguments:
  - mode
context: fork
---

# Dependency Audit

Launch the `dependency-auditor` agent to analyze the project's dependencies.

## Goal
Produce a structured security and health report covering vulnerabilities, outdated packages, unused dependencies, and license compliance.

## Steps

### 1. Launch Audit
Spawn the `dependency-auditor` agent with the current project context.

If `$mode` is `--fix`, after the audit completes, propose specific fix commands (e.g., `npm audit fix`, version bumps in package.json) for user approval.

If `$mode` is a package name, focus the audit on that specific package and its transitive dependencies.

**Success criteria**: Audit agent launched and report generated.

### 2. Present Results
Display the audit report with:
- Security vulnerabilities (Critical/High/Medium/Low)
- Outdated packages with available updates
- Unused dependencies
- License concerns
- Prioritized recommended actions

**Success criteria**: User has a clear, actionable audit report.
