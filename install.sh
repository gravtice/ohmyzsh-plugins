#!/usr/bin/env bash
# AI CLI Tools Zsh Completion Auto-Installation Script
# Supports Claude Code, Codex, Gemini CLI
#
# Copyright (c) 2024 ohmyzsh-plugins contributors
# Licensed under the MIT License
# See LICENSE file in the project root for full license information

set -e

# Check Bash version
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash to run"
    echo "Please use: bash install.sh"
    exit 1
fi

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMZ_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"

# Plugin definitions - using arrays instead of associative arrays for better compatibility
PLUGIN_NAMES=("claude" "codex" "gemini")
PLUGIN_DESCS=("Anthropic Claude Code CLI" "OpenAI Codex CLI" "Google Gemini CLI")
PLUGIN_CMDS=("claude" "codex" "gemini")

# Get plugin description
get_plugin_desc() {
    local plugin="$1"
    case "$plugin" in
        claude) echo "Anthropic Claude Code CLI" ;;
        codex) echo "OpenAI Codex CLI" ;;
        gemini) echo "Google Gemini CLI" ;;
        *) echo "Unknown" ;;
    esac
}

# Get plugin command
get_plugin_cmd() {
    local plugin="$1"
    case "$plugin" in
        claude) echo "claude" ;;
        codex) echo "codex" ;;
        gemini) echo "gemini" ;;
        *) echo "" ;;
    esac
}

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  AI CLI Tools Zsh Completion Installer    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# ==================== Environment Check ====================

echo -e "${CYAN}━━━ Environment Check ━━━${NC}"
echo ""

# Check oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo -e "${RED}✗ Error: oh-my-zsh not found${NC}"
    echo -e "${YELLOW}Please install oh-my-zsh first: https://ohmyz.sh/${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} oh-my-zsh detected"

# Check zsh
if ! command -v zsh &> /dev/null; then
    echo -e "${RED}✗ Error: zsh not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} zsh detected ($(zsh --version | awk '{print $2}'))"

# ==================== CLI Tools Detection ====================

echo ""
echo -e "${CYAN}━━━ Detecting Installed CLI Tools ━━━${NC}"
echo ""

INSTALLED_PLUGINS=()
MISSING_TOOLS=()

for plugin in "${PLUGIN_NAMES[@]}"; do
    cmd=$(get_plugin_cmd "$plugin")
    desc=$(get_plugin_desc "$plugin")

    if command -v "$cmd" &> /dev/null; then
        version=$(${cmd} --version 2>/dev/null || ${cmd} version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✓${NC} ${desc} - ${GREEN}installed${NC} ($version)"
        INSTALLED_PLUGINS+=("$plugin")
    else
        echo -e "${YELLOW}⚠${NC} ${desc} - ${YELLOW}not installed${NC}"
        MISSING_TOOLS+=("$plugin")
    fi
done

if [[ ${#INSTALLED_PLUGINS[@]} -eq 0 ]]; then
    echo ""
    echo -e "${RED}✗ Error: No supported CLI tools detected${NC}"
    echo -e "${YELLOW}Please install at least one of the following tools:${NC}"
    for plugin in "${PLUGIN_NAMES[@]}"; do
        desc=$(get_plugin_desc "$plugin")
        cmd=$(get_plugin_cmd "$plugin")
        echo -e "  - ${desc} (${cmd})"
    done
    exit 1
fi

# ==================== Plugin Selection ====================

echo ""
echo -e "${CYAN}━━━ Plugin Installation Selection ━━━${NC}"
echo ""

if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}The following tools are not installed, their plugins will be skipped:${NC}"
    for plugin in "${MISSING_TOOLS[@]}"; do
        desc=$(get_plugin_desc "$plugin")
        echo -e "  ${YELLOW}⊘${NC} ${desc}"
    done
    echo ""
fi

echo -e "${BLUE}The following plugins will be installed:${NC}"
PLUGINS_TO_INSTALL=()
for plugin in "${INSTALLED_PLUGINS[@]}"; do
    desc=$(get_plugin_desc "$plugin")
    echo -e "  ${GREEN}✓${NC} ${plugin} (${desc})"
    PLUGINS_TO_INSTALL+=("$plugin")
done

# Add interactive confirmation
echo ""
read -p "$(echo -e ${YELLOW}Continue with installation? [Y/n]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
    echo -e "${RED}✗ Installation cancelled${NC}"
    exit 0
fi

# ==================== Install Plugins ====================

echo ""
echo -e "${CYAN}━━━ Installing Plugin Files ━━━${NC}"
echo ""

STEP=1
TOTAL_STEPS=$((${#PLUGINS_TO_INSTALL[@]} + 2))

for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
    echo -e "${BLUE}[$STEP/$TOTAL_STEPS]${NC} Installing ${plugin}..."

    PLUGIN_DIR="$SCRIPT_DIR/$plugin"
    TARGET_DIR="$OMZ_CUSTOM/$plugin"
    PLUGIN_FILE="$PLUGIN_DIR/${plugin}.plugin.zsh"

    # Check plugin file
    if [[ ! -f "$PLUGIN_FILE" ]]; then
        echo -e "${RED}  ✗ Error: Plugin file not found: $PLUGIN_FILE${NC}"
        continue
    fi

    # Create target directory
    mkdir -p "$TARGET_DIR"

    # Copy plugin file
    cp "$PLUGIN_FILE" "$TARGET_DIR/"
    echo -e "${GREEN}  ✓${NC} Copied to: $TARGET_DIR/"

    ((STEP++))
done

# ==================== Update .zshrc ====================

echo ""
echo -e "${BLUE}[$STEP/$TOTAL_STEPS]${NC} Updating .zshrc configuration..."

ZSHRC="$HOME/.zshrc"
PLUGINS_ADDED=0
PLUGINS_SKIPPED=0

for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
    # Check if plugin already exists (supports multi-line format)
    if grep -q "^[[:space:]]*${plugin}[[:space:]]*$" "$ZSHRC" || grep -q "^plugins=(.*${plugin}" "$ZSHRC"; then
        echo -e "${YELLOW}  →${NC} ${plugin} already in .zshrc, skipping"
        ((PLUGINS_SKIPPED++))
    else
        # Check if plugins line exists
        if grep -q "^plugins=(" "$ZSHRC"; then
            # Backup .zshrc (handle symbolic links)
            cp -L "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d_%H%M%S)"

            # Check if single-line or multi-line format
            if grep -q "^plugins=(.*)" "$ZSHRC"; then
                # Single-line format: plugins=(git brew ...)
                TEMP_FILE=$(mktemp)
                sed "s/^plugins=(\(.*\))/plugins=(\1 ${plugin})/" "$ZSHRC" > "$TEMP_FILE"
            else
                # Multi-line format: plugins=(\n git\n brew\n ...)
                # Add plugin before the last )
                TEMP_FILE=$(mktemp)
                awk -v plugin="$plugin" '
                    /^plugins=\(/ { in_plugins=1 }
                    in_plugins && /^\)/ {
                        print plugin
                        in_plugins=0
                    }
                    { print }
                ' "$ZSHRC" > "$TEMP_FILE"
            fi

            # Write back to file
            if [[ -L "$ZSHRC" ]]; then
                # If it's a symbolic link, get the real file path
                REAL_ZSHRC=$(readlink -f "$ZSHRC" 2>/dev/null || readlink "$ZSHRC")
                cat "$TEMP_FILE" > "$REAL_ZSHRC"
            else
                cat "$TEMP_FILE" > "$ZSHRC"
            fi

            rm -f "$TEMP_FILE"
            echo -e "${GREEN}  ✓${NC} Added ${plugin} to plugins array"
            ((PLUGINS_ADDED++))
        else
            echo -e "${RED}  ✗${NC} Cannot find plugins array in .zshrc"
            echo -e "${YELLOW}  Please manually add '${plugin}' to the plugins array in .zshrc${NC}"
        fi
    fi
done

((STEP++))

# ==================== Clean Cache ====================

echo ""
echo -e "${BLUE}[$STEP/$TOTAL_STEPS]${NC} Cleaning completion cache..."
rm -f "$HOME/.zcompdump"*
echo -e "${GREEN}  ✓${NC} Cache cleaned"

# ==================== Verify Installation ====================

echo ""
echo -e "${CYAN}━━━ Verifying Installation ━━━${NC}"
echo ""

VERIFIED=0
for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
    if [[ -f "$OMZ_CUSTOM/$plugin/${plugin}.plugin.zsh" ]]; then
        echo -e "${GREEN}✓${NC} ${plugin} plugin file installed"
        ((VERIFIED++))
    else
        echo -e "${RED}✗${NC} ${plugin} plugin file installation failed"
    fi
done

# ==================== Complete ====================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation Complete!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}━━━ Installation Summary ━━━${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Plugins installed: ${GREEN}${#PLUGINS_TO_INSTALL[@]}${NC}"
echo -e "  ${BLUE}→${NC} Added to .zshrc: ${GREEN}${PLUGINS_ADDED}${NC}"
echo -e "  ${YELLOW}⊘${NC} Skipped (already exists): ${YELLOW}${PLUGINS_SKIPPED}${NC}"

if [[ $PLUGINS_ADDED -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠ .zshrc backup created: ${ZSHRC}.backup.*${NC}"
fi

echo ""
echo -e "${CYAN}━━━ Next Steps ━━━${NC}"
echo ""
echo -e "  ${BLUE}1.${NC} Reload shell ${YELLOW}(recommended)${NC}:"
echo -e "     ${GREEN}exec zsh${NC}"
echo ""
echo -e "  ${BLUE}2.${NC} Or source configuration:"
echo -e "     ${GREEN}source ~/.zshrc${NC}"
echo ""
echo -e "  ${BLUE}3.${NC} Or open a new terminal window"
echo ""

echo -e "${CYAN}━━━ Test Completions ━━━${NC}"
echo ""
for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
    cmd=$(get_plugin_cmd "$plugin")
    echo -e "  ${GREEN}${cmd} [Press Tab]${NC}"
done
echo ""

echo -e "${CYAN}━━━ Using Aliases ━━━${NC}"
echo ""
echo -e "  ${BLUE}Claude Code:${NC} ${GREEN}cc${NC} → claude, ${GREEN}ccc${NC} → claude chat"
echo -e "  ${BLUE}Codex:${NC}       ${GREEN}cdx${NC} → codex, ${GREEN}cdxa${NC} → codex ask"
echo -e "  ${BLUE}Gemini:${NC}      ${GREEN}gm${NC} → gemini, ${GREEN}gmc${NC} → gemini chat"
echo ""

echo -e "View full documentation: ${GREEN}cat $SCRIPT_DIR/README.md${NC}"
echo ""
