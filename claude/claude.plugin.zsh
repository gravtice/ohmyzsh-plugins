# Claude Code Zsh autocompletion plugin
# Supports intelligent completion for claude-code commands, including subcommands and parameters

# Main completion function
_claude_code() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a commands claude_opts

    # Define main commands (based on claude --help)
    commands=(
        'mcp:Configure and manage MCP servers'
        'plugin:Manage Claude Code plugins'
        'migrate-installer:Migrate from global npm installation to local installation'
        'setup-token:Set up long-term authentication token'
        'doctor:Check health of Claude Code auto-updater'
        'update:Check and install available updates'
        'install:Install Claude Code native version'
        'help:Display help information'
    )

    # Claude Code common options (based on actual command-line arguments)
    claude_opts=(
        '--model:Specify model (sonnet, opus, haiku or full model name)'
        '--fallback-model:Enable automatic fallback model'
        '--system-prompt:System prompt'
        '--append-system-prompt:Append system prompt'
        '--permission-mode:Permission mode (acceptEdits, bypassPermissions, default, dontAsk, plan)'
        '-c:Continue most recent conversation'
        '--continue:Continue most recent conversation'
        '-r:Resume session'
        '--resume:Resume session (optional sessionId)'
        '--fork-session:Create new session ID when resuming'
        '--session-id:Use specific session ID (must be valid UUID)'
        '-p:Print response and exit'
        '--print:Print response and exit (for piping)'
        '--output-format:Output format (text, json, stream-json)'
        '--input-format:Input format (text, stream-json)'
        '--include-partial-messages:Include partial message blocks'
        '--replay-user-messages:Replay user messages'
        '--tools:Specify available tool list'
        '--allowed:Allowed tool list'
        '--allowed-tools:Allowed tool list'
        '--disallowed:Disallowed tool list'
        '--disallowed-tools:Disallowed tool list'
        '--mcp-config:Load MCP servers from JSON file or string'
        '--mcp-debug:Enable MCP debug mode'
        '--strict-mcp-config:Use only MCP servers from --mcp-config'
        '--dangerously-skip-permissions:Bypass all permission checks'
        '--allow-dangerously-skip-permissions:Allow bypass permission check option'
        '--settings:Load settings from JSON file or string'
        '--setting-sources:Setting source list (user, project, local)'
        '--add-dir:Additional directories for tool access'
        '--plugin-dir:Directory to load plugins for this session'
        '--agents:JSON object for custom agents'
        '--ide:Automatically connect to IDE on startup'
        '--json-schema:JSON schema file or string'
        '-d:Enable debug mode'
        '--debug:Enable debug mode (optional category filter)'
        '-e:Extra parameters'
        '-i:Input related options'
        '-j:JSON related options'
        '-o:Output related options'
        '-s:Settings related options'
        '--verbose:Override verbose mode setting in config'
        '-v:Show version number'
        '--version:Show version number'
        '-h:Show help'
        '--help:Show help'
    )

    _arguments -C \
        '(- *)'{-h,--help}'[Show help]' \
        '(- *)'{-v,--version}'[Show version number]' \
        '--model[Specify model]' \
        '--fallback-model[Enable automatic fallback model]' \
        '--system-prompt[System prompt]' \
        '--append-system-prompt[Append system prompt]' \
        '--permission-mode[Permission mode]:mode:(acceptEdits bypassPermissions default dontAsk plan)' \
        {-c,--continue}'[Continue most recent conversation]' \
        {-r,--resume}'[Resume session]:session_id:' \
        '--fork-session[Create new session ID when resuming]' \
        '--session-id[Use specific session ID]:uuid:' \
        {-p,--print}'[Print response and exit]' \
        '--output-format[Output format]:format:(text json stream-json)' \
        '--input-format[Input format]:format:(text stream-json)' \
        '--include-partial-messages[Include partial message blocks]' \
        '--replay-user-messages[Replay user messages]' \
        '--tools[Specify available tool list]:tools:' \
        '--allowed[Allowed tool list]:tools:' \
        '--allowed-tools[Allowed tool list]:tools:' \
        '--disallowed[Disallowed tool list]:tools:' \
        '--disallowed-tools[Disallowed tool list]:tools:' \
        '--mcp-config[Load MCP servers from JSON file or string]:config:_files' \
        '--mcp-debug[Enable MCP debug mode]' \
        '--strict-mcp-config[Use only MCP servers from --mcp-config]' \
        '--dangerously-skip-permissions[Bypass all permission checks]' \
        '--allow-dangerously-skip-permissions[Allow bypass permission check option]' \
        '--settings[Load settings from JSON file or string]:settings:_files' \
        '--setting-sources[Setting source list]:sources:(user project local)' \
        '--add-dir[Additional directories for tool access]:directory:_files -/' \
        '--plugin-dir[Directory to load plugins for this session]:directory:_files -/' \
        '--agents[JSON object for custom agents]:json:' \
        '--ide[Automatically connect to IDE on startup]' \
        '--json-schema[JSON schema file or string]:schema:_files' \
        {-d,--debug}'[Enable debug mode]:category:' \
        '-e[Extra parameters]:param:' \
        '-i[Input related options]:param:' \
        '-j[JSON related options]:param:' \
        '-o[Output related options]:param:' \
        '-s[Settings related options]:param:' \
        '--verbose[Override verbose mode setting in config]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            _describe -t commands 'claude-code commands' commands
            ;;
        args)
            case $line[1] in
                plugin)
                    _claude_code_plugin
                    ;;
                mcp)
                    _claude_code_mcp
                    ;;
                doctor)
                    _claude_code_doctor
                    ;;
                install)
                    _claude_code_install
                    ;;
                migrate-installer)
                    _claude_code_migrate_installer
                    ;;
                setup-token)
                    _claude_code_setup_token
                    ;;
                update)
                    _claude_code_update
                    ;;
                *)
                    _describe -t claude_opts 'claude-code options' claude_opts
                    _files
                    ;;
            esac
            ;;
    esac
}

# plugin subcommand completion
_claude_code_plugin() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        {-h,--help}'[Show help]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            local -a plugin_cmds
            plugin_cmds=(
                'install|i:Install plugin'
                'uninstall|remove:Uninstall plugin'
                'validate:Validate plugin or marketplace manifest'
                'marketplace:Manage Claude Code marketplace'
                'enable:Enable disabled plugin'
                'disable:Disable enabled plugin'
            )
            _describe -t plugin_cmds 'plugin commands' plugin_cmds
            ;;
        args)
            case $line[1] in
                marketplace)
                    _claude_code_plugin_marketplace
                    ;;
                install|i)
                    _arguments \
                        {-h,--help}'[Show help]' \
                        '*:plugin:'
                    ;;
                uninstall|remove)
                    _arguments \
                        {-h,--help}'[Show help]' \
                        '*:plugin:'
                    ;;
                disable)
                    _arguments \
                        {-h,--help}'[Show help]'
                    ;;
                enable)
                    _arguments \
                        {-h,--help}'[Show help]'
                    ;;
                validate)
                    _arguments \
                        {-h,--help}'[Show help]' \
                        '*:file:_files'
                    ;;
            esac
            ;;
    esac
}

# plugin marketplace subcommand completion
_claude_code_plugin_marketplace() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        {-h,--help}'[Show help]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            local -a plugin_marketplace_cmds
            plugin_marketplace_cmds=(
                'add:Add marketplace from URL, path or GitHub repository'
                'list:List all configured marketplaces'
                'remove|rm:Remove marketplace'
                'update:Update marketplace from source'
            )
            _describe -t plugin_marketplace_cmds 'marketplace commands' plugin_marketplace_cmds
            ;;
        args)
            case $line[1] in
                add)
                    _arguments \
                        {-h,--help}'[Show help]' \
                        '*:source:'
                    ;;
                list)
                    _arguments \
                        {-h,--help}'[Show help]'
                    ;;
                remove|rm)
                    _arguments \
                        {-h,--help}'[Show help]' \
                        '*:marketplace:'
                    ;;
                update)
                    _arguments \
                        {-h,--help}'[Show help]' \
                        '*:marketplace:'
                    ;;
            esac
            ;;
    esac
}

# mcp subcommand completion
_claude_code_mcp() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        {-h,--help}'[Show help]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            local -a mcp_cmds
            mcp_cmds=(
                'serve:Start Claude Code MCP server'
                'add:Add MCP server to Claude Code'
                'remove:Remove MCP server'
                'list:List configured MCP servers'
                'get:Get MCP server details'
                'add-json:Add MCP server using JSON string'
                'add-from-claude-desktop:Import MCP servers from Claude Desktop'
                'reset-project-choices:Reset all approved and rejected servers in project scope'
            )
            _describe -t mcp_cmds 'mcp commands' mcp_cmds
            ;;
        args)
            case $line[1] in
                add)
                    _arguments \
                        {-s,--scope}'[Configuration scope]:scope:(local user project)' \
                        {-t,--transport}'[Transport type]:transport:(stdio sse http)' \
                        {-e,--env}'[Set environment variable]:env:' \
                        {-H,--header}'[Set WebSocket headers]:header:' \
                        {-h,--help}'[Show help]' \
                        '*:file:_files'
                    ;;
                serve)
                    _arguments \
                        {-d,--debug}'[Enable debug mode]' \
                        '--verbose[Enable verbose output]' \
                        {-h,--help}'[Show help]'
                    ;;
                add-json)
                    _arguments \
                        {-s,--scope}'[Configuration scope]:scope:(local user project)' \
                        {-h,--help}'[Show help]' \
                        '*:file:_files'
                    ;;
                add-from-claude-desktop)
                    _arguments \
                        {-s,--scope}'[Configuration scope]:scope:(local user project)' \
                        {-h,--help}'[Show help]'
                    ;;
                get)
                    _arguments \
                        {-h,--help}'[Show help]' \
                        '*::server:( $(claude mcp list 2>/dev/null | grep -E "^\s+\w+" | awk "{print \$1}") )'
                    ;;
                list)
                    _arguments \
                        {-h,--help}'[Show help]'
                    ;;
                remove)
                    _arguments \
                        {-s,--scope}'[Configuration scope]:scope:(local user project)' \
                        {-h,--help}'[Show help]' \
                        '*::server:( $(claude mcp list 2>/dev/null | grep -E "^\s+\w+" | awk "{print \$1}") )'
                    ;;
                reset-project-choices)
                    _arguments \
                        {-h,--help}'[Show help]'
                    ;;
            esac
            ;;
    esac
}

# doctor subcommand completion
_claude_code_doctor() {
    _arguments \
        {-h,--help}'[Show help]'
}

# install subcommand completion
_claude_code_install() {
    _arguments \
        '--force[Force reinstallation]' \
        {-h,--help}'[Show help]'
}

# migrate-installer subcommand completion
_claude_code_migrate_installer() {
    _arguments \
        {-h,--help}'[Show help]'
}

# setup-token subcommand completion
_claude_code_setup_token() {
    _arguments \
        {-h,--help}'[Show help]'
}

# update subcommand completion
_claude_code_update() {
    _arguments \
        {-h,--help}'[Show help]'
}

# Register completion functions
compdef _claude_code claude-code
compdef _claude_code claude
compdef _claude_code cc

# Add common aliases
alias cc='claude'
alias ccc='claude chat'
alias cca='claude api'
alias cccfg='claude config'
