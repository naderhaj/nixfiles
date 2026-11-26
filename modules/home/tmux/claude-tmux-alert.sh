# claude-tmux-alert waiting|clear
#
# Called from Claude Code hooks (see claude-alert.nix). Marks the tmux pane Claude runs in
# as waiting for the user — red window tab, dark-red pane background, terminal bell — or
# clears the mark. No-op outside tmux.

[ -n "${TMUX_PANE:-}" ] || exit 0
pane=$TMUX_PANE

# Hooks pass their event as JSON on stdin; drain it, we only need $1.
cat >/dev/null || true

tint='bg=#451a22'
tab='#[fg=#f8f8f2 bg=#ff5555 bold] #I 🔔 #W '

is_waiting() { [ -n "$(tmux show -pqv -t "$pane" @claude_waiting)" ]; }

# Global count of waiting panes, shown in status-right; unset when zero.
recount() {
  local n
  n=$(tmux list-panes -a -F '#{@claude_waiting}' | grep -c 1 || true)
  if [ "$n" -gt 0 ]; then
    tmux set -g @claude_waiting_count "$n"
  else
    tmux set -gu @claude_waiting_count
  fi
  # Redraw status lines now instead of on the next status-interval tick.
  tmux list-clients -F '#{client_name}' | while read -r c; do
    tmux refresh-client -S -t "$c"
  done
}

case "${1:-}" in
  waiting)
    is_waiting && exit 0 # already marked: don't ring again
    win=$(tmux display -p -t "$pane" '#{window_id}')
    tmux set -p -t "$pane" @claude_waiting 1 \; \
      set -p -t "$pane" window-style "$tint" \; \
      set -p -t "$pane" window-active-style "$tint" \; \
      set -w -t "$win" window-status-format "$tab" \; \
      set -w -t "$win" window-status-current-format "$tab"
    recount
    printf '\a' >"$(tmux display -p -t "$pane" '#{pane_tty}')" 2>/dev/null || true
    ;;
  clear)
    is_waiting || exit 0 # fast path: runs after every tool call
    win=$(tmux display -p -t "$pane" '#{window_id}')
    tmux set -pu -t "$pane" @claude_waiting \; \
      set -pu -t "$pane" window-style \; \
      set -pu -t "$pane" window-active-style
    # Another Claude in the same window may still be waiting.
    if ! tmux list-panes -t "$win" -F '#{@claude_waiting}' | grep -q 1; then
      tmux set -wu -t "$win" window-status-format \; \
        set -wu -t "$win" window-status-current-format
    fi
    recount
    ;;
  *)
    echo "usage: claude-tmux-alert waiting|clear" >&2
    exit 2
    ;;
esac
