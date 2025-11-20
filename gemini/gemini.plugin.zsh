# Gemini CLI Zsh autocompletion plugin
# Supports intelligent completion for gemini commands, including mcp and extensions subcommands

# Main completion function
_gemini_cli() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a commands
    commands=(
        'mcp:Manage MCP servers'
        'extensions:Manage Gemini CLI extensions'
    )

    _arguments -C \
        {-d,--debug}'[Debug mode]' \
        {-m,--model}'[Specify model]:model:' \
        {-p,--prompt}'[Prompt (deprecated)]:prompt:' \
        {-i,--prompt-interactive}'[Continue interactive mode after executing prompt]:prompt:' \
        {-s,--sandbox}'[Run in sandbox]' \
        {-y,--yolo}'[Automatically accept all actions (YOLO mode)]' \
        '--approval-mode[Set approval mode]:mode:(default auto_edit yolo)' \
        '--experimental-acp[Start agent in ACP mode]' \
        '--allowed-mcp-server-names[Allowed MCP server names]:servers:' \
        '--allowed-tools[Tools that can run without confirmation]:tools:' \
        {-e,--extensions}'[List of extensions to use]:extensions:' \
        {-l,--list-extensions}'[List all available extensions and exit]' \
        {-r,--resume}'[Resume previous session]:session:(latest)' \
        '--list-sessions[List available sessions for current project and exit]' \
        '--delete-session[Delete session by index number]:index:' \
        '--include-directories[Additional directories to include in workspace]:dir:_files -/' \
        '--screen-reader[Enable screen reader mode]' \
        {-o,--output-format}'[CLI output format]:format:(text json stream-json)' \
        {-v,--version}'[Show version number]' \
        {-h,--help}'[Show help information]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            _describe -t commands 'gemini commands' commands
            ;;
        args)
            case $line[1] in
                mcp)
                    _gemini_cli_mcp
                    ;;
                extensions)
                    _gemini_cli_extensions
                    ;;
            esac
            ;;
    esac
}

# mcp subcommand completion
_gemini_cli_mcp() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a mcp_cmds
    mcp_cmds=(
        'add:Add server'
        'remove:Remove server'
        'list:List all configured MCP servers'
    )

    _arguments -C \
        {-d,--debug}'[Debug mode]' \
        {-h,--help}'[Show help]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            _describe -t mcp_cmds 'mcp commands' mcp_cmds
            ;;
        args)
            case $line[1] in
                add)
                    _gemini_cli_mcp_add
                    ;;
                remove)
                    _gemini_cli_mcp_remove
                    ;;
                list)
                    _arguments \
                        {-d,--debug}'[Debug mode]' \
                        {-h,--help}'[Show help]'
                    ;;
            esac
            ;;
    esac
}

# mcp add subcommand completion
_gemini_cli_mcp_add() {
    _arguments \
        {-d,--debug}'[Debug mode]' \
        {-s,--scope}'[Configuration scope]:scope:(user project)' \
        {-t,--transport}'[Transport type]:transport:(stdio sse http)' \
        {-e,--env}'[Set environment variable]:env:' \
        {-H,--header}'[Set HTTP header]:header:' \
        '--timeout[Connection timeout in milliseconds]:timeout:' \
        '--trust[Trust server (skip all confirmations)]' \
        '--description[Server description]:description:' \
        '--include-tools[List of tools to include]:tools:' \
        '--exclude-tools[List of tools to exclude]:tools:' \
        {-h,--help}'[Show help]' \
        '1:name:' \
        '2:commandOrUrl:' \
        '*:args:'
}

# mcp remove subcommand completion
_gemini_cli_mcp_remove() {
    local -a servers
    # Dynamically get list of configured MCP servers
    servers=($(gemini mcp list 2>/dev/null | grep -E '^\s+\w+' | awk '{print $1":Remove MCP server"}'))

    _arguments \
        {-d,--debug}'[Debug mode]' \
        {-s,--scope}'[Configuration scope]:scope:(user project)' \
        {-h,--help}'[Show help]' \
        '1: :->server'

    case $state in
        server)
            if (( ${#servers} > 0 )); then
                _describe -t servers 'MCP servers' servers
            fi
            ;;
    esac
}

# extensions subcommand completion
_gemini_cli_extensions() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a extensions_cmds
    extensions_cmds=(
        'install:Install extension from git repository or local path'
        'uninstall:Uninstall extension'
        'list:List installed extensions'
        'update:Update all extensions or specified extension to latest version'
        'disable:Disable extension'
        'enable:Enable extension'
        'link:Link extension from local path'
        'new:Create new extension from template'
        'validate:Validate extension at local path'
    )

    _arguments -C \
        {-d,--debug}'[Debug mode]' \
        {-h,--help}'[Show help]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            _describe -t extensions_cmds 'extensions commands' extensions_cmds
            ;;
        args)
            case $line[1] in
                install)
                    _gemini_cli_extensions_install
                    ;;
                uninstall)
                    _gemini_cli_extensions_uninstall
                    ;;
                list)
                    _arguments \
                        {-d,--debug}'[Debug mode]' \
                        {-h,--help}'[Show help]'
                    ;;
                update)
                    _gemini_cli_extensions_update
                    ;;
                disable)
                    _gemini_cli_extensions_disable
                    ;;
                enable)
                    _gemini_cli_extensions_enable
                    ;;
                link|new|validate)
                    _arguments \
                        {-d,--debug}'[Debug mode]' \
                        {-h,--help}'[Show help]' \
                        '*:path:_files'
                    ;;
            esac
            ;;
    esac
}

# extensions install subcommand completion
_gemini_cli_extensions_install() {
    _arguments \
        {-d,--debug}'[Debug mode]' \
        '--ref[Git ref to install]:ref:' \
        '--auto-update[Enable auto-update]' \
        '--pre-release[Enable pre-release versions]' \
        '--consent[Confirm security risks and skip confirmation prompts]' \
        {-h,--help}'[Show help]' \
        '1:source:_files'
}

# extensions uninstall subcommand completion
_gemini_cli_extensions_uninstall() {
    local -a extensions
    # Dynamically get list of installed extensions
    extensions=($(gemini extensions list 2>/dev/null | grep -E '^\s+\w+' | awk '{print $1":Uninstall extension"}'))

    _arguments \
        {-d,--debug}'[Debug mode]' \
        {-h,--help}'[Show help]' \
        '1: :->extension'

    case $state in
        extension)
            if (( ${#extensions} > 0 )); then
                _describe -t extensions 'installed extensions' extensions
            fi
            ;;
    esac
}

# extensions update subcommand completion
_gemini_cli_extensions_update() {
    local -a extensions
    extensions=($(gemini extensions list 2>/dev/null | grep -E '^\s+\w+' | awk '{print $1":Update extension"}'))

    _arguments \
        {-d,--debug}'[Debug mode]' \
        '--all[Update all extensions]' \
        {-h,--help}'[Show help]' \
        '1: :->extension'

    case $state in
        extension)
            if (( ${#extensions} > 0 )); then
                _describe -t extensions 'installed extensions' extensions
            fi
            ;;
    esac
}

# extensions disable subcommand completion
_gemini_cli_extensions_disable() {
    local -a extensions
    extensions=($(gemini extensions list 2>/dev/null | grep -E '^\s+\w+' | awk '{print $1":Disable extension"}'))

    _arguments \
        {-d,--debug}'[Debug mode]' \
        '--scope[Scope]:scope:' \
        {-h,--help}'[Show help]' \
        '1: :->extension'

    case $state in
        extension)
            if (( ${#extensions} > 0 )); then
                _describe -t extensions 'installed extensions' extensions
            fi
            ;;
    esac
}

# extensions enable subcommand completion
_gemini_cli_extensions_enable() {
    local -a extensions
    extensions=($(gemini extensions list 2>/dev/null | grep -E '^\s+\w+' | awk '{print $1":Enable extension"}'))

    _arguments \
        {-d,--debug}'[Debug mode]' \
        '--scope[Scope]:scope:' \
        {-h,--help}'[Show help]' \
        '1: :->extension'

    case $state in
        extension)
            if (( ${#extensions} > 0 )); then
                _describe -t extensions 'installed extensions' extensions
            fi
            ;;
    esac
}

# Register completion functions
compdef _gemini_cli gemini
compdef _gemini_cli gm

# Add common aliases
alias gm='gemini'
alias gmm='gemini mcp'
alias gme='gemini extensions'
