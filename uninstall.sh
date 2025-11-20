#!/bin/bash
# AI CLI Tools Zsh Completion Uninstallation Script
#
# Copyright (c) 2024 ohmyzsh-plugins contributors
# Licensed under the MIT License
# See LICENSE file in the project root for full license information

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

OMZ_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
ZSHRC="$HOME/.zshrc"

# Plugin list
PLUGINS=("claude" "codex" "gemini")

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  AI CLI Tools Zsh Completion Uninstaller  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Confirm uninstallation
echo -e "${YELLOW}This operation will uninstall the following plugins:${NC}"
for plugin in "${PLUGINS[@]}"; do
    if [[ -d "$OMZ_CUSTOM/$plugin" ]]; then
        echo -e "  ${RED}✗${NC} ${plugin}"
    fi
done
echo ""

read -p "$(echo -e ${YELLOW}Are you sure you want to uninstall? [y/N]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}✓ Uninstallation cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}━━━ Starting Uninstallation ━━━${NC}"
echo ""

# Backup .zshrc (handle symbolic links)
if [[ -f "$ZSHRC" ]] || [[ -L "$ZSHRC" ]]; then
    BACKUP="${ZSHRC}.backup.$(date +%Y%m%d_%H%M%S)"
    cp -L "$ZSHRC" "$BACKUP"
    echo -e "${GREEN}✓${NC} Backed up .zshrc to: $BACKUP"
fi

# Uninstall each plugin
REMOVED=0
for plugin in "${PLUGINS[@]}"; do
    TARGET_DIR="$OMZ_CUSTOM/$plugin"

    # Remove plugin directory
    if [[ -d "$TARGET_DIR" ]]; then
        rm -rf "$TARGET_DIR"
        echo -e "${GREEN}✓${NC} Removed plugin directory: ${plugin}"
        ((REMOVED++))
    else
        echo -e "${YELLOW}⊘${NC} Plugin directory does not exist: ${plugin}"
    fi

    # Remove plugin from .zshrc
    if [[ -f "$ZSHRC" ]] || [[ -L "$ZSHRC" ]]; then
        if grep -q "${plugin}" "$ZSHRC"; then
            # Use temporary file instead of in-place edit (supports symbolic links)
            TEMP_FILE=$(mktemp)
            sed "s/ ${plugin}//g; s/${plugin} //g" "$ZSHRC" > "$TEMP_FILE"

            # Write back to file
            if [[ -L "$ZSHRC" ]]; then
                # If it's a symbolic link, get the real file path
                REAL_ZSHRC=$(readlink -f "$ZSHRC" 2>/dev/null || readlink "$ZSHRC")
                cat "$TEMP_FILE" > "$REAL_ZSHRC"
            else
                cat "$TEMP_FILE" > "$ZSHRC"
            fi

            rm -f "$TEMP_FILE"
            echo -e "${GREEN}✓${NC} Removed from .zshrc: ${plugin}"
        fi
    fi
done

# Clean completion cache
echo ""
echo -e "${BLUE}Cleaning completion cache...${NC}"
rm -f "$HOME/.zcompdump"*
echo -e "${GREEN}✓${NC} Cache cleaned"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Uninstallation Complete!                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}━━━ Uninstallation Summary ━━━${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Plugins removed: ${GREEN}${REMOVED}${NC}"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo -e "  ${BLUE}1.${NC} Reload shell:"
echo -e "     ${GREEN}exec zsh${NC}"
echo ""
echo -e "  ${BLUE}2.${NC} Or source configuration:"
echo -e "     ${GREEN}source ~/.zshrc${NC}"
echo ""
