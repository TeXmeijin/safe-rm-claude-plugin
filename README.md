# safe-rm Claude Code Plugin

A safe remove command wrapper for AI coding agents that prevents accidental deletion of important files.

## Overview

`safe-rm` is a Claude Code plugin that replaces the `rm` command with a safety-enhanced version. It enforces multiple protective checks to prevent AI agents from accidentally deleting critical files and directories.

## Features

### Protection Mechanisms

- **Dotfile Protection**: Prevents removal of dotfiles (files starting with `.`) by default
- **Directory Scope Enforcement**: Blocks deletion of files outside the current working directory
- **Special Directory Protection**: Prevents removal of critical system directories (`/`, `~`)
- **Gitignored File Protection**: Blocks deletion of files listed in `.gitignore`
- **File Count Limits**: Restricts recursive directory deletion to a maximum file count (default: 10 files)
- **Git-Managed File Confirmation**: Requires explicit confirmation for removing git-tracked files

### Configurable Options

All safety checks can be customized using command-line options:

```bash
# Allow dotfile removal
safe-rm --forbidden-dotfiles false .env

# Allow files outside current directory
safe-rm --forbidden-outside-cwd false /path/to/file

# Only allow removal of git new/unstaged files
safe-rm --only-git-new-file true newfile.txt

# Increase directory file count limit
safe-rm --forbidden-file-count 20 large-directory/
```

### Advanced Features

- **Base64 Encoded Confirmation**: For git-managed files, confirmation uses base64-encoded filenames to prevent accidental execution
- **Force Option for /tmp**: The `-f` (force) flag is only allowed for files under `/tmp`
- **Recursive Removal**: Use `-r` or `-R` for directories (with file count protection)

## Installation

### From Marketplace

```bash
# Add the marketplace
/plugin add-marketplace github:yourusername/safe-rm-claude-plugin

# Install the plugin
/plugin install safe-rm@safe-rm-marketplace
```

### Local Installation

```bash
# Install from local directory
/plugin install /path/to/safe-rm-claude-plugin
```

## Usage

Once installed, the `rm` command in Claude Code sessions is automatically aliased to `safe-rm`. You can use it just like the regular `rm` command:

```bash
# Basic usage
rm file.txt

# Remove directory
rm -r directory/

# View help
rm --help
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `--forbidden-dotfiles` | `true` | Prevent removal of dotfiles |
| `--only-git-new-file` | `false` | Only allow removal of git new/unstaged files |
| `--forbidden-file-count` | `10` | Max files allowed in directory removal |
| `--forbidden-special-dirs` | `true` | Prevent removal of `/` and `~` |
| `--forbidden-outside-cwd` | `true` | Prevent removal of files outside current directory |
| `--forbidden-gitignored` | `true` | Prevent removal of gitignored files |

## Examples

### Protected Scenarios

```bash
# This will be blocked (dotfile)
rm .env
# Error: FORBIDDEN: You are trying to remove dotfile: .env

# This will be blocked (outside cwd)
rm ../parent-file
# Error: FORBIDDEN: Cannot remove files outside current directory

# This will be blocked (special directory)
rm -rf /
# Error: FORBIDDEN: Cannot remove special directory: /
```

### Safe Operations

```bash
# Remove a regular file in current directory
rm temp-file.txt

# Remove a directory with few files
rm -r small-dir/

# Remove with explicit permission override
rm --forbidden-dotfiles false .temporary-cache
```

## How It Works

The plugin uses Claude Code's SessionStart hook to set up an alias that redirects `rm` commands to the `safe-rm` script. The script performs multiple safety checks before executing the actual file removal using the system's `/bin/rm` command.

## Development

### Project Structure

```
safe-rm-claude-plugin/
├── .claude-plugin/
│   ├── plugin.json          # Plugin metadata
│   └── marketplace.json     # Marketplace definition
├── hooks/
│   └── hooks.json           # SessionStart hook configuration
├── bin/
│   └── safe-rm              # Safe-rm script
├── README.md                # This file
└── LICENSE                  # MIT License
```

### Testing

Test the plugin locally before publishing:

```bash
# Install locally
/plugin install ~/path/to/safe-rm-claude-plugin

# Start a new Claude Code session and test
rm --help
```

## License

MIT License - See LICENSE file for details

## Author

Created by meijin

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
