# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Claude Code plugin that wraps `rm` with `safe-rm` to prevent accidental file deletions by AI agents. Only affects Claude Code's shell environment — the user's terminal is not affected at all.

## Architecture

```
hooks/
  hooks.json       → SessionStart hook: calls setup-env.sh
  setup-env.sh     → Writes shell functions to $CLAUDE_ENV_FILE for bypass-resistant rm interception
bin/safe-rm        → Bash script: parses args, runs 7 safety checks, then calls /bin/rm
.claude-plugin/
  plugin.json      → Plugin metadata
  marketplace.json → Marketplace distribution config
```

**Bypass prevention layers** (setup-env.sh):
1. `function rm()` — shell function, catches `rm` and `\rm` (backslash alias bypass)
2. `function command()` — overrides builtin, catches `command rm`
3. `function /bin/rm()` / `function /usr/bin/rm()` — zsh-only, catches direct path calls

**safe-rm execution flow** (bin/safe-rm):
1. Parse custom flags (`--forbidden-*`, `--only-git-new-file`, `--encoded-file-name`) and standard rm flags (`-r`, `-f`)
2. Run safety checks in order: special dirs → force flag → dotfiles → outside cwd → gitignored → file count → git status
3. If all checks pass, delegate to `/bin/rm` with the original flags and files

## Error message convention

All blocked messages must follow this pattern:
- Explain what was blocked and why
- State "This protection runs in Claude Code's shell only"
- Guide to `NEXT ACTION👉: Ask the user to run in their own terminal: /bin/rm ...`
- Override options reference `rm` (not `safe-rm`) since Claude sees the aliased command

## Testing

No test framework. Test manually:

```bash
# Run with plugin directory
claude --plugin-dir /Users/meijin/Documents/src/private/safe-rm-claude-plugin

# Or test safe-rm directly
./bin/safe-rm file.txt
./bin/safe-rm -r some-dir/
./bin/safe-rm --forbidden-dotfiles false .env
```

## Key Design Decisions

- safe-rm is NOT installed in the user's system and NOT in PATH — it lives only in the plugin directory
- Error messages tell Claude to "ask the user to run in their own terminal" (user's shell has real `rm`)
- `--encoded-file-name` uses base64 encoding to let the agent confirm deletion of git-managed files (two-step removal)
- `-f` flag is restricted to `/tmp` and `/private/tmp` paths only
- `--forbidden-special-dirs` cannot be overridden (always blocks `/` and `~`)
- All checks exit on first failure (no accumulated errors)
