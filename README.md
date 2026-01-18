# Safe Delete Protection for Claude Code

> **Protect your codebase from accidental deletions — install once, stay safe forever.**

Stop AI agents from accidentally deleting `.env` files, git-tracked code, or critical system files. This plugin adds automatic safety checks to every `rm` command in Claude Code sessions.

**Zero configuration. Zero learning curve. Just install and forget.**

## The Problem

AI agents are powerful, but they can make costly mistakes:

```bash
# Claude executes: rm .env
# 💥 Your API keys are gone

# Claude executes: rm -rf ../important-project
# 💥 Wrong directory deleted

# Claude executes: rm src/config.ts
# 💥 Git-tracked file removed without confirmation
```

**One accidental deletion can cost hours of recovery work.**

## The Solution

This plugin automatically blocks dangerous deletions **before they happen**:
- ✅ Install once in 30 seconds
- ✅ Works transparently (no commands to learn)
- ✅ Protects all Claude Code sessions
- ✅ Zero performance impact

## Why This Plugin, Not Other Solutions?

You might be using these common approaches to protect your files:

### ❌ Approach 1: Deny `rm` in settings.json

```json
{
  "permissions": {
    "deny": ["Bash(rm *)"]
  }
}
```

**Problem:** Pattern matching is fragile and can be bypassed:
- `rm file.txt` → ❌ Blocked
- `rm  file.txt` (extra space) → ✅ Bypassed
- `/bin/rm file.txt` → ✅ Bypassed
- Known bug: [deny permissions not enforced](https://github.com/anthropics/claude-code/issues/6699)

### ❌ Approach 2: Instructions in CLAUDE.md

```markdown
IMPORTANT: Never use the rm command to delete files.
```

**Problem:** LLM instructions are unreliable:
- Claude may ignore instructions under certain contexts
- No guaranteed enforcement
- [Real incidents](https://github.com/anthropics/claude-code/issues/12489): "rm -rf executed on home directory despite explicit instructions"

### ✅ This Plugin: Shell-Layer Protection

This plugin works at the **shell execution layer** — below the LLM:

```
User Request → Claude (LLM) → Shell Command → [🛡️ THIS PLUGIN] → System
```

**Why it's bulletproof:**
1. **Physical layer enforcement** — runs BEFORE the system executes `rm`
2. **Cannot be bypassed** — all `rm` commands go through it
3. **LLM-agnostic** — works regardless of what Claude decides
4. **Zero regex patterns** — direct command interception

**Inspired by:** [claude-code-safety-net](https://github.com/kenryu42/claude-code-safety-net) PreToolUse hooks, but simplified for deletion protection only.

## Quick Start

### Installation

```bash
# Add the marketplace
/plugin marketplace add github:TeXmeijin/safe-rm-claude-plugin

# Install the plugin
/plugin install safe-rm@safe-rm-marketplace
```

**That's it!** Every Claude Code session now has automatic deletion protection.

## How It Works

After installation, all `rm` commands in Claude Code are transparently protected:

```bash
# You use rm normally
rm .env

# But the plugin automatically blocks dangerous operations
# ❌ FORBIDDEN: You are trying to remove dotfile: .env
```

**You don't need to learn new commands or change your workflow.** The protection works invisibly in the background.

## What's Protected

The plugin enforces 6 critical safety checks:

| Protection | What It Does |
|------------|--------------|
| 🔒 **Dotfiles** | Blocks deletion of configuration files (`.env`, `.gitignore`, etc.) |
| 🔒 **Git-managed files** | Requires confirmation before removing tracked files |
| 🔒 **Outside project scope** | Prevents deleting files outside your current directory |
| 🔒 **System directories** | Blocks removal of `/`, `~`, and other critical paths |
| 🔒 **Gitignored files** | Protects important files like `node_modules`, build outputs |
| 🔒 **Large directories** | Limits recursive deletion to 10 files (configurable) |

## Examples

### Protected Scenarios

```bash
# ❌ Blocked: Dotfile
rm .env
# Error: FORBIDDEN: You are trying to remove dotfile: .env

# ❌ Blocked: Outside current directory
rm ../important-file
# Error: Cannot remove files outside current directory

# ❌ Blocked: System directory
rm -rf /
# Error: Cannot remove special directory: /

# ❌ Blocked: Too many files
rm -r large-directory/  # contains 50+ files
# Error: Directory contains 50 files (limit: 10)
```

### Safe Operations

```bash
# ✅ Allowed: Regular file in current directory
rm temp-file.txt

# ✅ Allowed: Small directory
rm -r test-folder/  # contains 5 files

# ✅ Allowed: With explicit override
rm --forbidden-dotfiles false .temporary-cache
```

## Advanced Configuration

Most users won't need to change anything, but you can customize protection rules when needed:

```bash
# Temporarily allow dotfile removal
rm --forbidden-dotfiles false .temporary-cache

# Increase file count limit for large directories
rm --forbidden-file-count 50 build-output/

# Allow deletion outside current directory (use with caution!)
rm --forbidden-outside-cwd false /path/to/file
```

### All Available Options

| Option | Default | Override Example |
|--------|---------|------------------|
| `--forbidden-dotfiles` | `true` | `rm --forbidden-dotfiles false .env` |
| `--forbidden-outside-cwd` | `true` | `rm --forbidden-outside-cwd false ../file` |
| `--forbidden-file-count` | `10` | `rm --forbidden-file-count 50 dir/` |
| `--forbidden-special-dirs` | `true` | Cannot be overridden |
| `--forbidden-gitignored` | `true` | `rm --forbidden-gitignored false node_modules/` |
| `--only-git-new-file` | `false` | `rm --only-git-new-file true newfile.txt` |

## Technical Details

The plugin works by installing a SessionStart hook that creates a transparent alias: `rm` → `safe-rm`.

When Claude runs `rm`, it actually executes the protection script which:
1. Validates the operation against all safety rules
2. If safe, calls the system's `/bin/rm`
3. If unsafe, blocks the operation with a clear error message

**This happens automatically — no manual configuration required.**

## For Developers

### Local Testing

```bash
# Test without installing
claude --plugin-dir ~/path/to/safe-rm-claude-plugin

# Or install locally
/plugin marketplace add ~/path/to/safe-rm-claude-plugin
/plugin install safe-rm@safe-rm-marketplace
```

### Project Structure

```
.claude-plugin/      # Plugin configuration
├── plugin.json      # Metadata
└── marketplace.json # Marketplace definition
hooks/hooks.json     # Auto-setup on session start
bin/safe-rm          # Protection script
```

## License & Contributing

MIT License • Contributions welcome!

Created by [meijin](https://github.com/TeXmeijin)
