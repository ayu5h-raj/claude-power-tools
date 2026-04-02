#!/usr/bin/env bash
set -euo pipefail

# Claude Power Tools — Uninstaller
# Removes agents and skills installed by install.sh

CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
SKILLS_DIR="$CLAUDE_DIR/skills"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Agents to remove
AGENTS=(
    "verification-agent"
    "research-scout"
    "pr-shepherd"
    "dependency-auditor"
    "session-archivist"
    "security-reviewer"
    "memory-consolidator"
)

# Skills to remove
SKILLS=(
    "verify"
    "skillify"
    "remember"
    "dep-audit"
    "session-summary"
    "security-review"
    "dream"
)

echo -e "${BLUE}=== Claude Power Tools Uninstaller ===${NC}"
echo ""

# --- Remove Agents ---
echo -e "${YELLOW}Removing agents...${NC}"
REMOVED_AGENTS=0
for agent in "${AGENTS[@]}"; do
    if [ -f "$AGENTS_DIR/$agent.md" ]; then
        rm "$AGENTS_DIR/$agent.md"
        echo -e "  ${RED}-${NC} $agent.md"
        REMOVED_AGENTS=$((REMOVED_AGENTS + 1))
    fi
done
echo -e "  Removed ${RED}$REMOVED_AGENTS${NC} agents"
echo ""

# --- Remove Skills ---
echo -e "${YELLOW}Removing skills...${NC}"
REMOVED_SKILLS=0
for skill in "${SKILLS[@]}"; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        rm -rf "$SKILLS_DIR/$skill"
        echo -e "  ${RED}-${NC} /$skill"
        REMOVED_SKILLS=$((REMOVED_SKILLS + 1))
    fi
done
echo -e "  Removed ${RED}$REMOVED_SKILLS${NC} skills"
echo ""

# --- Restore Settings (optional) ---
LATEST_BACKUP=$(ls -t "$SETTINGS_FILE".backup.* 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    echo -e "${YELLOW}Found settings backup: $LATEST_BACKUP${NC}"
    read -p "  Restore settings.json from backup? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$LATEST_BACKUP" "$SETTINGS_FILE"
        echo -e "  ${GREEN}Restored settings.json from backup${NC}"
    else
        echo -e "  ${BLUE}Skipped — hooks remain in settings.json${NC}"
        echo -e "  ${BLUE}To manually remove, edit ~/.claude/settings.json and remove the hooks entries${NC}"
    fi
    echo ""
fi

echo -e "${GREEN}=== Uninstall Complete ===${NC}"
echo "Removed $REMOVED_AGENTS agents and $REMOVED_SKILLS skills."
