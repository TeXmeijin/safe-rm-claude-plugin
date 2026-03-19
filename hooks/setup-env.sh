#!/bin/bash
# Writes shell functions to $CLAUDE_ENV_FILE that intercept rm and its bypass vectors.
# This runs at SessionStart; $CLAUDE_PLUGIN_ROOT and $CLAUDE_ENV_FILE are provided by Claude Code.

SAFE_RM="${CLAUDE_PLUGIN_ROOT}/bin/safe-rm"

cat >> "$CLAUDE_ENV_FILE" << EOF
# --- safe-rm protection layer ---

# 1) Shell function overrides alias: catches 'rm' and '\rm' (backslash bypass)
function rm() { "${SAFE_RM}" "\$@"; }

# 2) Intercept 'unlink' (POSIX file removal command)
function unlink() { "${SAFE_RM}" "\$@"; }

# 3) Override 'command' builtin: catches 'command rm/unlink ...'
#    Falls through to real 'command' for everything else.
function command() {
  case "\$1" in
    rm|unlink) shift; "${SAFE_RM}" "\$@" ;;
    *) builtin command "\$@" ;;
  esac
}

# 3) Intercept direct-path calls (zsh-only: zsh allows '/' in function names)
#    In bash these declarations are silently ignored.
if [[ -n "\$ZSH_VERSION" ]]; then
  function /bin/rm()        { "${SAFE_RM}" "\$@"; }
  function /usr/bin/rm()    { "${SAFE_RM}" "\$@"; }
  function /bin/unlink()    { "${SAFE_RM}" "\$@"; }
  function /usr/bin/unlink(){ "${SAFE_RM}" "\$@"; }
fi

# --- end safe-rm ---
EOF
