#!/usr/bin/env bash
set -euo pipefail

REPO="dalandro/skill-swindler"
BRANCH="main"
SKILL="skill-swindler"
DEST="$HOME/.claude/skills/$SKILL"

mkdir -p "$DEST"
curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/.claude/skills/$SKILL/SKILL.md" \
  -o "$DEST/SKILL.md"

echo "Installed $SKILL to $DEST"
echo "Read the quality bar: https://github.com/$REPO/blob/$BRANCH/ADVISORY.md"
