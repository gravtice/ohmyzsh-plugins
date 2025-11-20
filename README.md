# Oh My Zsh AI CLI Plugins

A collection of intelligent Zsh completion plugins for popular AI CLI tools, providing comprehensive auto-completion support for Claude Code, Codex, and Gemini CLI.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Oh My Zsh](https://img.shields.io/badge/Oh_My_Zsh-required-blue.svg)](https://ohmyz.sh/)
[![Zsh](https://img.shields.io/badge/Zsh-5.0+-green.svg)](https://www.zsh.org/)

## Features

- **Smart Auto-completion**: Intelligent command and option completion for all supported AI CLI tools
- **Comprehensive Coverage**: Complete support for all commands, subcommands, and parameters
- **Dynamic Context**: Context-aware completions based on available configurations
- **Convenient Aliases**: Pre-configured short aliases for frequently used commands
- **Easy Installation**: Automated installation script with environment detection
- **Clean Uninstallation**: Simple removal with backup preservation

## Supported Tools

### Claude (`claude`)
Complete auto-completion for [Claude Code](https://claude.ai/code), Anthropic's official CLI tool for Claude.

**Supported Commands:**
- `mcp` - Configure and manage MCP servers
- `plugin` - Manage Claude Code plugins
- `migrate-installer` - Migrate from global npm installation
- `setup-token` - Configure long-term authentication token
- `doctor` - Check auto-updater health
- `update` - Check and install updates
- `install` - Install Claude Code native version

**Aliases:**
- `cc` → `claude`
- `ccc` → `claude chat`
- `cca` → `claude api`
- `cccfg` → `claude config`

### Codex (`codex`)
Full auto-completion support for [Codex](https://github.com/stablecaps/codex), an AI-powered coding assistant.

**Supported Commands:**
- `exec` - Run Codex non-interactively
- `mcp` - Manage MCP servers
- `login/logout` - Manage authentication
- `sandbox` - Run commands in Codex-provided sandbox
- `apply` - Apply latest diff to local working tree
- `resume` - Resume previous interactive session
- `cloud` - Browse Codex Cloud tasks

**Aliases:**
- `cdx` → `codex`
- `cdxa` → `codex ask`
- `cdxc` → `codex chat`
- `cdxe` → `codex explain`
- `cdxf` → `codex fix`
- `cdxr` → `codex review`
- `cdxt` → `codex test`
- `cdxrf` → `codex refactor`
- `cdxcfg` → `codex config`

### Gemini (`gemini`)
Intelligent completion for [Gemini CLI](https://github.com/google-gemini/gemini-cli), Google's Gemini command-line interface.

**Supported Commands:**
- `mcp` - Manage MCP servers
- `extensions` - Manage Gemini CLI extensions

**Aliases:**
- `gm` → `gemini`
- `gmm` → `gemini mcp`
- `gme` → `gemini extensions`

## Requirements

- [Oh My Zsh](https://ohmyz.sh/) - Zsh configuration framework
- Zsh 5.0 or higher
- At least one of the following AI CLI tools installed:
  - [Claude Code](https://claude.ai/code)
  - [Codex](https://github.com/stablecaps/codex)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli)

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/ohmyzsh-plugins.git
cd ohmyzsh-plugins

# Run the installation script
bash install.sh
```

The installation script will:
1. Detect your environment and installed AI CLI tools
2. Copy plugin files to `~/.oh-my-zsh/custom/plugins/`
3. Automatically update your `.zshrc` configuration
4. Create a backup of your `.zshrc` file

### Reload Your Shell

After installation, reload your shell configuration:

```bash
# Option 1: Reload shell (recommended)
exec zsh

# Option 2: Source configuration
source ~/.zshrc
```

## Usage

### Auto-completion Examples

Simply type the command and press `Tab` to see available completions:

```bash
# Claude Code
claude [Tab]              # Shows main commands
claude mcp [Tab]          # Shows MCP subcommands
claude plugin [Tab]       # Shows plugin management commands

# Codex
codex [Tab]               # Shows main commands
codex mcp [Tab]           # Shows MCP operations
codex exec [Tab]          # Shows execution options

# Gemini CLI
gemini [Tab]              # Shows main commands
gemini mcp [Tab]          # Shows MCP management
gemini extensions [Tab]   # Shows extension operations
```

### Using Aliases

```bash
# Claude Code shortcuts
cc                        # Instead of 'claude'
ccc "your prompt"         # Quick chat
cccfg                     # Quick config

# Codex shortcuts
cdx                       # Instead of 'codex'
cdxa "explain this code"  # Quick ask
cdxr                      # Quick review

# Gemini CLI shortcuts
gm                        # Instead of 'gemini'
gmm list                  # Quick MCP list
gme list                  # Quick extension list
```

## Advanced Features

### Context-Aware Completions

The plugins provide intelligent, context-aware completions:

- **MCP Server Names**: Dynamically lists configured MCP servers
- **Extension Names**: Shows installed extensions for management commands
- **File Paths**: Provides file completion where appropriate
- **Option Values**: Suggests valid values for enumerated options

### Multi-line Plugin Configuration

The installation script supports both single-line and multi-line `plugins` arrays in `.zshrc`:

```bash
# Single-line format
plugins=(git brew claude codex gemini)

# Multi-line format
plugins=(
  git
  brew
  claude
  codex
  gemini
)
```

## Configuration Scopes

Many commands support configuration scopes:

- `user` - User-level configuration
- `project` - Project-specific configuration
- `local` - Local machine configuration

Example:
```bash
claude mcp add --scope user myserver
gemini mcp add --scope project toolserver
```

## Uninstallation

To remove the plugins:

```bash
bash uninstall.sh
```

The uninstall script will:
1. Remove plugin files from `~/.oh-my-zsh/custom/plugins/`
2. Remove plugin entries from your `.zshrc`
3. Create a backup before making changes
4. Clean up completion cache

## Troubleshooting

### Completions Not Working

If auto-completions don't work after installation:

```bash
# Clear completion cache
rm -f ~/.zcompdump*

# Reload shell
exec zsh
```

### Plugin Not Loading

Check if the plugin is properly added to your `.zshrc`:

```bash
grep "plugins=" ~/.zshrc
```

Ensure your desired plugins are listed in the `plugins` array.

### Command Not Found

Verify that the AI CLI tool is installed and in your PATH:

```bash
# Check Claude Code
which claude

# Check Codex
which codex

# Check Gemini CLI
which gemini
```

## Project Structure

```
ohmyzsh-plugins/
├── claude/
│   └── claude.plugin.zsh
├── codex/
│   └── codex.plugin.zsh
├── gemini/
│   └── gemini.plugin.zsh
├── install.sh
├── uninstall.sh
├── check_sync.sh
├── README.md
├── VERSION
└── LICENSE
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Reporting Issues

If you encounter any problems or have suggestions:
- Open an issue on GitHub
- Include your environment details (OS, Zsh version, plugin version)
- Provide steps to reproduce the problem

## Changelog

See [VERSION](VERSION) for version history.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) - The delightful Zsh framework
- [Claude Code](https://claude.ai/code) - Anthropic's Claude CLI
- [Codex](https://github.com/stablecaps/codex) - AI coding assistant
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) - Google's Gemini CLI

## Related Projects

- [zsh-completions](https://github.com/zsh-users/zsh-completions) - Additional completion definitions
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like autosuggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Syntax highlighting

## Support

For support and questions:
- GitHub Issues: Report bugs and request features
- Documentation: Check this README and plugin source files
- Community: Share your experience with other users

---

Made with ❤️ for the AI CLI community
