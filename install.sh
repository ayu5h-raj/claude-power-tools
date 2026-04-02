#!/usr/bin/env bash
set -euo pipefail

# Claude Power Tools — Local Installer
# Copies agents and skills to ~/.claude/ without requiring the marketplace system.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$SCRIPT_DIR/plugins/hidden-skills"
HOOKS_DIR="$SCRIPT_DIR/plugins/power-hooks/hooks"

CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
SKILLS_DIR="$CLAUDE_DIR/skills"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Claude Power Tools Installer ===${NC}"
echo ""

# Check if ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${RED}Error: ~/.claude directory not found. Is Claude Code installed?${NC}"
    exit 1
fi

# --- Install Agents ---
echo -e "${YELLOW}Installing agents...${NC}"
mkdir -p "$AGENTS_DIR"

AGENT_COUNT=0
for agent_file in "$PLUGIN_DIR/agents/"*.md; do
    if [ -f "$agent_file" ]; then
        filename=$(basename "$agent_file")
        cp "$agent_file" "$AGENTS_DIR/$filename"
        echo -e "  ${GREEN}+${NC} $filename"
        AGENT_COUNT=$((AGENT_COUNT + 1))
    fi
done
echo -e "  Installed ${GREEN}$AGENT_COUNT${NC} agents to $AGENTS_DIR/"
echo ""

# --- Install Skills ---
echo -e "${YELLOW}Installing skills...${NC}"
mkdir -p "$SKILLS_DIR"

SKILL_COUNT=0
for skill_dir in "$PLUGIN_DIR/skills/"*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p "$SKILLS_DIR/$skill_name"
        cp "$skill_dir"SKILL.md "$SKILLS_DIR/$skill_name/SKILL.md"
        echo -e "  ${GREEN}+${NC} /$(basename "$skill_dir")"
        SKILL_COUNT=$((SKILL_COUNT + 1))
    fi
done
echo -e "  Installed ${GREEN}$SKILL_COUNT${NC} skills to $SKILLS_DIR/"
echo ""

# --- Install Hooks (optional) ---
echo -e "${YELLOW}Install power-hooks? (PostCommit verification, PostCompact memory restore, SubagentStop logging)${NC}"
read -p "  Install hooks into settings.json? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$SETTINGS_FILE" ]; then
        # Backup settings
        BACKUP="$SETTINGS_FILE.backup.$(date +%Y%m%d%H%M%S)"
        cp "$SETTINGS_FILE" "$BACKUP"
        echo -e "  ${BLUE}Backed up settings to $BACKUP${NC}"
    fi

    # Check if jq is available for safe JSON merging
    if command -v jq &> /dev/null; then
        if [ -f "$SETTINGS_FILE" ]; then
            EXISTING_HOOKS=$(jq '.hooks // {}' "$SETTINGS_FILE" 2>/dev/null || echo '{}')
            HOOK_CONFIG=$(cat "$HOOKS_DIR/hooks.json")

            # Merge hooks into settings
            jq --argjson hooks "$HOOK_CONFIG" '.hooks = (.hooks // {} | . * $hooks)' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
            echo -e "  ${GREEN}+${NC} Merged hooks into settings.json"
        else
            echo '{}' | jq --argjson hooks "$(cat "$HOOKS_DIR/hooks.json")" '{hooks: $hooks}' > "$SETTINGS_FILE"
            echo -e "  ${GREEN}+${NC} Created settings.json with hooks"
        fi
    else
        echo -e "  ${RED}jq not found — cannot safely merge hooks into settings.json${NC}"
        echo -e "  ${YELLOW}Manual install: copy the contents of plugins/power-hooks/hooks/hooks.json"
        echo -e "  into the \"hooks\" key of ~/.claude/settings.json${NC}"
    fi
    echo ""
fi

# --- Summary ---
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "Installed:"
echo "  Agents ($AGENT_COUNT):"
for agent_file in "$AGENTS_DIR/"*.md; do
    if [ -f "$agent_file" ]; then
        name=$(basename "$agent_file" .md)
        echo "    - @$name"
    fi
done
echo ""
echo "  Skills ($SKILL_COUNT):"
for skill_dir in "$SKILLS_DIR/"*/; do
    if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
        name=$(basename "$skill_dir")
        echo "    - /$name"
    fi
done
echo ""
echo -e "${BLUE}Usage:${NC}"
echo "  /verify [description]      — Adversarially verify your implementation"
echo "  /skillify [description]    — Capture this session as a reusable skill"
echo "  /remember                  — Review and organize memory layers"
echo "  /dep-audit [--fix]         — Audit dependencies for security issues"
echo "  /session-summary           — Generate a session summary"
echo "  /security-review           — Security-focused code review of current branch"
echo "  /dream                     — Memory consolidation (organize knowledge)"
echo ""
echo -e "${BLUE}To uninstall:${NC} ./uninstall.sh"
