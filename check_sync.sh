#!/bin/bash
# check_sync_recursive.sh - True recursive command detection script
# Detects all subcommands and parameters through recursive command execution
#
# Copyright (c) 2024 ohmyzsh-plugins contributors
# Licensed under the MIT License
# See LICENSE file in the project root for full license information

set -e

# Check bash version
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash to run"
    echo "Please use: bash check_sync_recursive.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
MAX_DEPTH=3                 # Maximum recursion depth
TIMEOUT_SECONDS=5           # Command execution timeout

# Temporary files
ISSUES_FILE=$(mktemp)
CHECKED_CMDS_FILE=$(mktemp)
trap "rm -f $ISSUES_FILE $CHECKED_CMDS_FILE" EXIT

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    Zsh Completion Plugin True Recursive Detection Tool${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${MAGENTA}Configuration:${NC}"
echo -e "  Maximum recursion depth: ${MAX_DEPTH}"
echo -e "  Command timeout: ${TIMEOUT_SECONDS} seconds"
echo ""

# ========================================
# Helper function: Execute command and get help output (with timeout)
# ========================================
get_help_output() {
    local cmd="$1"
    local output

    # Try --help
    output=$(timeout $TIMEOUT_SECONDS bash -c "$cmd --help 2>&1" 2>/dev/null || true)

    # If --help fails or output is empty, try -h
    if [[ -z "$output" ]] || [[ "$output" == *"unknown option"* ]]; then
        output=$(timeout $TIMEOUT_SECONDS bash -c "$cmd -h 2>&1" 2>/dev/null || true)
    fi

    # If still fails, try without arguments
    if [[ -z "$output" ]] || [[ "$output" == *"unknown option"* ]]; then
        output=$(timeout $TIMEOUT_SECONDS bash -c "$cmd 2>&1" 2>/dev/null || true)
    fi

    echo "$output"
}

# ========================================
# Helper function: Extract subcommands from help output
# ========================================
extract_commands_from_help() {
    local help_output="$1"
    local full_cmd="$2"  # Optional: full command (e.g., "gemini" or "gemini mcp")

    # Extract Commands: or Subcommands: section
    # Supports multiple formats:
    #   Traditional format:
    #     command        description
    #     command [args] description
    #   yargs format (level 1):
    #     basecommand subcommand  description
    #   yargs format (level 2):
    #     basecommand subcommand subsubcommand  description
    # Supports Chinese: 命令：, 子命令：

    local commands_section
    commands_section=$(echo "$help_output" | sed -n '/^Commands:/,/^Options:/p; /^Subcommands:/,/^Options:/p; /^Available Commands:/,/^Options:/p; /^命令：/,/^选项：/p; /^子命令：/,/^选项：/p')

    # Calculate command hierarchy depth (by counting spaces)
    local depth=$(echo "$full_cmd" | awk '{print NF}')

    # Detect if it's yargs format (line starts with full command)
    if [[ -n "$full_cmd" ]] && echo "$commands_section" | grep -qE "^  $full_cmd "; then
        # yargs format: extract next column (subcommand)
        # Subcommand is at depth + 1 column
        local col=$((depth + 1))
        echo "$commands_section" | \
            grep -E "^  $full_cmd " | \
            awk -v col="$col" '{print $col}' | \
            sed 's/\[.*//g; s/<.*//g' | \
            grep -v "^$" | \
            grep -v "^help$" | \
            sort -u
    else
        # Traditional format: extract first column
        echo "$commands_section" | \
            grep -E "^  [a-z][a-z0-9|_-]*" | \
            sed 's/\[.*//g; s/<.*//g' | \
            awk '{print $1}' | \
            grep -v "^$" | \
            grep -v "^help$" | \
            sort -u
    fi
}

# ========================================
# Helper function: Extract options from help output
# ========================================
extract_options_from_help() {
    local help_output="$1"

    # Extract Options: or Flags: section
    # Supports formats:
    #   -x, --xxx    description
    #   --xxx        description
    #   -x           description
    # Supports Chinese: 选项：, 标志：
    # Only extract from option definition part (first two fields of each line) to avoid extracting from description text
    {
        # Extract long options: only from first two fields of each line
        echo "$help_output" | sed -n '/^Options:/,/^$/p; /^Flags:/,/^$/p; /^Global Options:/,/^$/p; /^选项：/,/^$/p; /^标志：/,/^$/p' | \
            grep -E '^[[:space:]]+-' | \
            awk '{print $1, $2}' | \
            grep -oE -- '--[a-z][a-z0-9_-]*'
        # Extract short options: only from first two fields of each line
        echo "$help_output" | sed -n '/^Options:/,/^$/p; /^Flags:/,/^$/p; /^Global Options:/,/^$/p; /^选项：/,/^$/p; /^标志：/,/^$/p' | \
            grep -E '^[[:space:]]+-' | \
            awk '{print $1, $2}' | \
            grep -oE -- '-[a-z]([^a-z]|$)' | \
            sed 's/[^-a-z]//g'
    } | sort -u
}

# ========================================
# Helper function: Extract command list from plugin file
# ========================================
extract_commands_from_plugin() {
    local plugin_file="$1"
    local cmd_path="$2"
    local tool_name="$3"

    # Determine variable name and function name based on command path
    local var_name func_name

    if [[ -z "$cmd_path" ]]; then
        # Main command
        var_name="commands"
        func_name="_${tool_name//-/_}"
    else
        # Subcommand
        local normalized_path=$(echo "$cmd_path" | tr ' ' '_' | tr '-' '_')
        var_name="${normalized_path}_cmds"
        func_name="_${tool_name//-/_}_${normalized_path}"
    fi

    # Extract commands from plugin (supports multiple formats)
    {
        # Format 1: Find var=(...) directly within function
        sed -n "/^${func_name}() {/,/^}/p" "$plugin_file" 2>/dev/null | \
            sed -n "/${var_name}=(/,/^[[:space:]]*)/p" | \
            grep -E "^[[:space:]]*'" | \
            sed -E "s/^[[:space:]]*'([a-z][a-z0-9|_-]*):.*'/\1/"

        # Format 2: Find array assignment block containing the variable name (regardless of local -a declaration)
        sed -n "/^${func_name}() {/,/^}/p" "$plugin_file" 2>/dev/null | \
            awk "BEGIN { in_array=0; found=0 }
                 /${var_name}=\(/ && !found { in_array=1; next }
                 in_array {
                     if (/^[[:space:]]*\)/) {
                         in_array=0
                         found=1
                         exit
                     } else {
                         print
                     }
                 }" | \
            grep -E "^[[:space:]]*'" | \
            sed -E "s/^[[:space:]]*'([a-z][a-z0-9|_-]*):.*'/\1/"
    } | \
        grep -v "^help$" | \
        grep -v "^$" | \
        sort -u
}

# ========================================
# Helper function: Extract option list from plugin file
# ========================================
extract_options_from_plugin() {
    local plugin_file="$1"
    local cmd_path="$2"
    local tool_name="$3"

    # Determine function name and subcommand name based on command path
    local func_name parent_func subcmd

    if [[ -z "$cmd_path" ]]; then
        # Main command
        func_name="_${tool_name//-/_}"
    else
        # Subcommand - try independent function first, then parent function's case statement
        local normalized_path=$(echo "$cmd_path" | tr ' ' '_' | tr '-' '_')
        func_name="_${tool_name//-/_}_${normalized_path}"

        # Extract parent function and subcommand name (supports multi-level subcommands)
        if [[ "$cmd_path" =~ ^(.+)[[:space:]]([a-z][a-z0-9|_-]+)$ ]]; then
            local parent_path="${BASH_REMATCH[1]}"
            subcmd="${BASH_REMATCH[2]}"
            # Parent function name
            local parent_normalized=$(echo "$parent_path" | tr ' ' '_' | tr '-' '_')
            parent_func="_${tool_name//-/_}_${parent_normalized}"
        fi
    fi

    {
        # Method 1: Extract from independent function
        if sed -n "/^${func_name}() {/,/^}/p" "$plugin_file" 2>/dev/null | grep -q "_arguments"; then
            # Extract {-x,--xxx} format options
            sed -n "/^${func_name}() {/,/^}/p" "$plugin_file" 2>/dev/null | \
                sed -n '/_arguments/,/case \$state/p' | \
                grep -oE '\{-[a-zA-Z],--[a-z][a-z0-9_-]*\}' | \
                sed 's/{//g; s/}//g; s/,/\n/g'

            # Extract standalone --xxx options
            sed -n "/^${func_name}() {/,/^}/p" "$plugin_file" 2>/dev/null | \
                sed -n '/_arguments/,/case \$state/p' | \
                grep -oE '(^|[^{-])--[a-z][a-z0-9_-]*' | \
                grep -oE -- '--[a-z][a-z0-9_-]*'

            # Extract standalone -x options
            sed -n "/^${func_name}() {/,/^}/p" "$plugin_file" 2>/dev/null | \
                sed -n '/_arguments/,/case \$state/p' | \
                grep -oE '(^|[^{a-zA-Z])-[a-zA-Z]([^a-zA-Z]|$)' | \
                grep -oE -- '-[a-zA-Z]' | \
                grep -v -- '-C'
        # Method 2: Extract from parent function's case statement
        elif [[ -n "$parent_func" ]] && [[ -n "$subcmd" ]]; then
            # Extract _arguments block for corresponding subcommand from parent function
            # Supports subcmd) and xxx|subcmd|yyy) formats
            # First find the starting line number of the case branch containing the command
            local start_line=$(sed -n "/^${parent_func}() {/,/^}/=" "$plugin_file" 2>/dev/null | \
                sed -n "/^${parent_func}() {/=")

            # Extract entire parent function, then find branch containing target command in case statement
            local func_body=$(sed -n "/^${parent_func}() {/,/^}/p" "$plugin_file" 2>/dev/null)

            # Use grep to find case branch containing the command (supports | separator)
            echo "$func_body" | awk -v cmd="$subcmd" '
                # Find case branch containing target command
                $0 ~ "^[[:space:]]*.*" cmd "[)|]" {
                    in_case = 1
                }
                # Collect content within case branch
                in_case {
                    print
                    # End when encountering ;;
                    if (/;;/) {
                        in_case = 0
                    }
                }
            ' | grep -oE '\{-[a-zA-Z],--[a-z][a-z0-9_-]*\}' | \
                sed 's/{//g; s/}//g; s/,/\n/g'

            echo "$func_body" | awk -v cmd="$subcmd" '
                $0 ~ "^[[:space:]]*.*" cmd "[)|]" { in_case = 1 }
                in_case {
                    print
                    if (/;;/) { in_case = 0 }
                }
            ' | grep -oE '(^|[^{-])--[a-z][a-z0-9_-]*' | \
                grep -oE -- '--[a-z][a-z0-9_-]*'

            echo "$func_body" | awk -v cmd="$subcmd" '
                $0 ~ "^[[:space:]]*.*" cmd "[)|]" { in_case = 1 }
                in_case {
                    print
                    if (/;;/) { in_case = 0 }
                }
            ' | grep -oE '(^|[^{a-zA-Z])-[a-zA-Z]([^a-zA-Z]|$)' | \
                grep -oE -- '-[a-zA-Z]' | \
                grep -v -- '-C'
        fi
    } | sort -u
}

# ========================================
# Recursively check command tree
# ========================================
check_command_recursive() {
    local base_cmd="$1"         # Base command (e.g., claude)
    local cmd_path="$2"         # Current command path (e.g., "mcp add")
    local plugin_file="$3"      # Plugin file path
    local tool_name="$4"        # Tool name (e.g., claude-code)
    local depth="$5"            # Current depth

    # Depth limit
    if [[ $depth -gt $MAX_DEPTH ]]; then
        return
    fi

    # Build full command
    local full_cmd
    if [[ -z "$cmd_path" ]]; then
        full_cmd="$base_cmd"
    else
        full_cmd="$base_cmd $cmd_path"
    fi

    # Loop detection (use file instead of associative array, compatible with Bash 3.x)
    if grep -Fxq "$full_cmd" "$CHECKED_CMDS_FILE" 2>/dev/null; then
        return
    fi
    echo "$full_cmd" >> "$CHECKED_CMDS_FILE"

    # Indentation
    local indent=""
    for ((i=0; i<depth; i++)); do
        indent="  ${indent}"
    done

    # Get help output
    local help_output=$(get_help_output "$full_cmd")

    # Check if command is valid
    if [[ -z "$help_output" ]] || \
       [[ "$help_output" == *"command not found"* ]] || \
       [[ "$help_output" == *"No such file"* ]]; then
        return
    fi

    # Extract subcommands and options (pass full command for yargs format detection)
    local cmds_from_help=$(extract_commands_from_help "$help_output" "$full_cmd")
    local opts_from_help=$(extract_options_from_help "$help_output")

    # Extract from plugin
    local cmds_from_plugin=$(extract_commands_from_plugin "$plugin_file" "$cmd_path" "$tool_name")
    local opts_from_plugin=$(extract_options_from_plugin "$plugin_file" "$cmd_path" "$tool_name")

    # Display current command being checked
    echo -e "${indent}${CYAN}[$depth] ${full_cmd}${NC}"

    local has_issue=0

    # Check subcommands
    if [[ -n "$cmds_from_help" ]]; then
        local missing_cmds=$(comm -23 <(echo "$cmds_from_help") <(echo "$cmds_from_plugin" | grep -v "^$"))

        if [[ -n "$missing_cmds" ]]; then
            local count=$(echo "$missing_cmds" | wc -l | tr -d ' ')
            echo -e "${indent}  ${RED}✗ Missing ${count} subcommand(s):${NC}"
            while IFS= read -r cmd; do
                [[ -z "$cmd" ]] && continue
                echo -e "${indent}    - ${cmd}"
                echo "1" >> "$ISSUES_FILE"
            done <<< "$missing_cmds"
            has_issue=1
        else
            if [[ -n "$cmds_from_plugin" ]]; then
                local count=$(echo "$cmds_from_plugin" | grep -v "^$" | wc -l | tr -d ' ')
                echo -e "${indent}  ${GREEN}✓ Subcommands complete (${count})${NC}"
            fi
        fi
    fi

    # Check options
    if [[ -n "$opts_from_help" ]]; then
        local missing_opts=$(comm -23 <(echo "$opts_from_help") <(echo "$opts_from_plugin" | grep -v "^$"))

        if [[ -n "$missing_opts" ]]; then
            local count=$(echo "$missing_opts" | wc -l | tr -d ' ')
            echo -e "${indent}  ${RED}✗ Missing ${count} option(s):${NC}"

            # Only show first 10 to avoid excessive output
            local shown=0
            while IFS= read -r opt; do
                [[ -z "$opt" ]] && continue
                if [[ $shown -lt 10 ]]; then
                    echo -e "${indent}    - ${opt}"
                fi
                shown=$((shown + 1))
                echo "1" >> "$ISSUES_FILE"
            done <<< "$missing_opts"

            if [[ $shown -gt 10 ]]; then
                echo -e "${indent}    ${YELLOW}... and $((shown - 10)) more option(s) not shown${NC}"
            fi
            has_issue=1
        else
            if [[ -n "$opts_from_plugin" ]]; then
                local count=$(echo "$opts_from_plugin" | grep -v "^$" | wc -l | tr -d ' ')
                echo -e "${indent}  ${GREEN}✓ Options complete (${count})${NC}"
            fi
        fi
    fi

    # Show warning if no content found
    if [[ -z "$cmds_from_help" ]] && [[ -z "$opts_from_help" ]]; then
        echo -e "${indent}  ${YELLOW}⚠ Unable to extract commands or options from help output${NC}"
    fi

    echo ""

    # Recursively check subcommands
    if [[ -n "$cmds_from_help" ]] && [[ $depth -lt $MAX_DEPTH ]]; then
        while IFS= read -r subcmd; do
            [[ -z "$subcmd" ]] && continue

            # Skip subcommands with same name as base command (avoid loops)
            if [[ "$subcmd" == "$base_cmd" ]]; then
                continue
            fi

            # Build new command path
            local new_cmd_path
            if [[ -z "$cmd_path" ]]; then
                new_cmd_path="$subcmd"
            else
                new_cmd_path="$cmd_path $subcmd"
            fi

            # Detect simple loops (command path already contains this subcommand)
            if [[ " $cmd_path " == *" $subcmd "* ]]; then
                continue
            fi

            # Recursive call
            check_command_recursive "$base_cmd" "$new_cmd_path" "$plugin_file" "$tool_name" $((depth + 1))
        done <<< "$cmds_from_help"
    fi
}

# ========================================
# Check single CLI tool
# ========================================
check_cli_tool() {
    local tool_name="$1"
    local tool_cmd="$2"
    local plugin_file="$3"

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Checking ${tool_name} (command: ${tool_cmd})${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if ! command -v "$tool_cmd" &> /dev/null; then
        echo -e "${YELLOW}⚠ ${tool_cmd} not installed, skipping check${NC}"
        echo ""
        return
    fi

    if [[ ! -f "$plugin_file" ]]; then
        echo -e "${RED}✗ Plugin file not found: $plugin_file${NC}"
        echo ""
        return
    fi

    # Clear loop detection file
    > "$CHECKED_CMDS_FILE"

    # Start recursive check from root command
    check_command_recursive "$tool_cmd" "" "$plugin_file" "$tool_name" 0

    echo ""
}

# ========================================
# Main check process
# ========================================

# Check each tool
check_cli_tool "claude" "claude" "$SCRIPT_DIR/claude/claude.plugin.zsh"
check_cli_tool "codex" "codex" "$SCRIPT_DIR/codex/codex.plugin.zsh"
check_cli_tool "gemini" "gemini" "$SCRIPT_DIR/gemini/gemini.plugin.zsh"

# ========================================
# Summary
# ========================================
TOTAL_ISSUES=$(wc -l < "$ISSUES_FILE" | tr -d ' ')

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    Check Complete${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

if [[ $TOTAL_ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✓ All plugins are fully synchronized, no issues found${NC}"
else
    echo -e "${RED}✗ Found ${TOTAL_ISSUES} missing command(s)/option(s) in total${NC}"
    echo ""
    echo -e "${YELLOW}Recommendations:${NC}"
    echo "1. Update the corresponding .plugin.zsh files based on the report above"
    echo "2. For each missing subcommand, you need to:"
    echo "   - Add command definition to the corresponding command array"
    echo "   - Create corresponding completion function (if the command has its own options)"
    echo "   - Add branch handling in the case statement"
    echo "3. For each missing option, add definition in the _arguments call"
    echo "4. Re-run this script to verify the fix"
    echo "5. Run 'exec zsh' to reload the shell"
fi
echo ""
echo -e "${CYAN}Tips:${NC}"
echo "- Adjust MAX_DEPTH to control recursion depth (current: ${MAX_DEPTH})"
echo "- Adjust TIMEOUT_SECONDS to control command timeout (current: ${TIMEOUT_SECONDS} seconds)"
echo "- Not all detected missing items need to be fixed, decide based on actual usage"
echo ""
