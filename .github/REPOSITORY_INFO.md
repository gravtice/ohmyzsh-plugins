# Repository Information

## Project Details

**Repository Name:** `ohmyzsh-plugins`

**Description:** A collection of intelligent Zsh completion plugins for popular AI CLI tools (Anthropic Claude Code CLI, OpenAI Codex CLI, and Google Gemini CLI)

**Topics/Tags:**
- `zsh`
- `oh-my-zsh`
- `completion`
- `auto-completion`
- `claude`
- `claude-code`
- `codex`
- `gemini`
- `ai-tools`
- `cli-tools`
- `shell`
- `productivity`

**Primary Language:** Shell

**License:** MIT

**Version:** 1.0.0

## Repository Configuration

### About Section

**Short Description:**
```
Intelligent Zsh auto-completion plugins for AI CLI tools: Anthropic Claude Code CLI, OpenAI Codex CLI, and Google Gemini CLI
```

**Website:** (Optional - add if you have documentation site)

### Repository Settings

**Features to Enable:**
- ✅ Issues
- ✅ Discussions (optional, for community support)
- ✅ Wiki (optional, for extended documentation)
- ✅ Projects (optional, for roadmap)

**Default Branch:** `main`

### Branch Protection Rules (Recommended)

For `main` branch:
- Require pull request reviews before merging
- Require status checks to pass before merging
- Include administrators

### Social Preview

**Suggested Preview Image Dimensions:** 1280x640 pixels

**Preview Text:**
```
🚀 Oh My Zsh AI CLI Plugins

Intelligent auto-completion for:
• Anthropic Claude Code CLI
• OpenAI Codex CLI
• Google Gemini CLI

Easy installation • Smart completions • Convenient aliases
```

## Release Information

### Initial Release (v1.0.0)

**Release Title:** Initial Release - AI CLI Auto-completion Suite

**Release Notes:**
```markdown
# 🎉 Initial Release v1.0.0

A comprehensive collection of Oh My Zsh plugins providing intelligent auto-completion for popular AI CLI tools.

## 🌟 Features

- **Complete Auto-completion** for Anthropic Claude Code CLI, OpenAI Codex CLI, and Google Gemini CLI
- **Context-Aware Suggestions** with dynamic server/extension listings
- **Convenient Aliases** for frequently used commands
- **Automated Installation** with environment detection
- **Easy Uninstallation** with backup preservation

## 📦 Supported Tools

### Anthropic Claude Code CLI
- Full command and subcommand completion
- MCP server management
- Plugin system support

### OpenAI Codex CLI
- Interactive and non-interactive mode completion
- Sandbox environment support
- Cloud integration commands

### Google Gemini CLI
- MCP server configuration
- Extension management system
- Multiple approval modes

## 🚀 Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/ohmyzsh-plugins.git
cd ohmyzsh-plugins
bash install.sh
exec zsh
```

## 📚 Documentation

See [README.md](../README.md) for complete installation and usage instructions.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

MIT License - see [LICENSE](../LICENSE) for details.
```

## GitHub Actions (Optional)

### Suggested Workflows

Create `.github/workflows/` directory with these workflows:

#### 1. Validation Workflow (`validate.yml`)
```yaml
name: Validate Plugins

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Zsh
        run: sudo apt-get update && sudo apt-get install -y zsh

      - name: Validate Zsh Syntax
        run: |
          for plugin in claude-code codex gemini-cli; do
            echo "Validating $plugin..."
            zsh -n ${plugin}/${plugin}.plugin.zsh
          done

      - name: Check Script Permissions
        run: |
          test -x install.sh
          test -x uninstall.sh
```

#### 2. Release Workflow (`release.yml`)
```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          draft: false
          prerelease: false
```

## Issue Templates

### Bug Report Template (`.github/ISSUE_TEMPLATE/bug_report.md`)

```markdown
---
name: Bug Report
about: Report a bug or issue
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. Press Tab on '...'
3. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Environment:**
 - OS: [e.g. macOS 13.0, Ubuntu 22.04]
 - Zsh version: [output of `zsh --version`]
 - Oh My Zsh version: [from `~/.oh-my-zsh/` git log]
 - Plugin version: [from VERSION file]
 - AI CLI tool version: [e.g. `claude --version`]

**Additional context**
Add any other context about the problem here.
```

### Feature Request Template (`.github/ISSUE_TEMPLATE/feature_request.md`)

```markdown
---
name: Feature Request
about: Suggest an enhancement or new feature
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

**Is your feature request related to a problem?**
A clear and concise description of what the problem is.

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

## Pull Request Template

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Description

Please include a summary of the changes and the related issue.

Fixes # (issue)

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing

Please describe the tests you ran to verify your changes:

- [ ] Tested with Claude Code
- [ ] Tested with Codex
- [ ] Tested with Gemini CLI
- [ ] Installation script tested
- [ ] Uninstallation script tested

**Test Environment:**
- OS:
- Zsh version:
- Oh My Zsh version:

## Checklist

- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have tested that completion works correctly
```

## Repository Metadata

### `.gitattributes` (Recommended)

```gitattributes
# Auto detect text files and perform LF normalization
* text=auto

# Shell scripts
*.sh text eol=lf
*.zsh text eol=lf
*.bash text eol=lf

# Documentation
*.md text
*.txt text

# Git files
.gitattributes text
.gitignore text
```

### `.gitignore` Additions

```gitignore
# Backup files
*.backup.*
*~

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Linux
*~
.directory

# Temporary files
*.tmp
*.temp
.*.swp
.*.swo

# IDE
.vscode/
.idea/
*.iml
```

## Maintainer Notes

### Release Process

1. Update VERSION file
2. Update CHANGELOG (if maintained)
3. Create git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. Create GitHub release from tag
6. Attach any release assets if needed

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality additions
- PATCH version for backwards-compatible bug fixes

### Community Guidelines

- Respond to issues within 48 hours
- Review pull requests within 1 week
- Keep documentation up-to-date
- Maintain backward compatibility when possible
- Provide migration guides for breaking changes

## Support Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and community support
- **README**: Primary documentation
- **Wiki**: Extended guides and tutorials (optional)

---

**Last Updated:** 2024-11-20
**Maintainer:** @YOUR_GITHUB_USERNAME
