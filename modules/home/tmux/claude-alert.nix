# Turns a tmux pane red while the Claude Code session in it is waiting on the user.
#
# Claude Code hooks call `claude-tmux-alert waiting|clear`, which marks the pane
# (@claude_waiting), paints its window tab red, tints the pane and rings the bell.
# prefix + W jumps to a waiting pane; status-right shows how many are waiting.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  claude-tmux-alert = pkgs.writeShellApplication {
    name = "claude-tmux-alert";
    runtimeInputs = [
      config.programs.tmux.package # same tmux as the server
      pkgs.gnugrep
    ];
    text = builtins.readFile ./claude-tmux-alert.sh;
  };

  hook = arg: [
    {
      type = "command";
      command = "claude-tmux-alert ${arg}";
    }
  ];

  # Written into ~/.claude/settings.json as its whole `hooks` key.
  claudeHooks = pkgs.writeText "claude-hooks.json" (
    builtins.toJSON {
      # permission prompt, MCP elicitation form. Not idle_prompt: it fires 60s after every
      # finished turn, so every idle session would go red.
      Notification = [
        {
          matcher = "permission_prompt|elicitation_dialog";
          hooks = hook "waiting";
        }
      ];
      # Claude's own question / plan-approval dialogs don't send a Notification
      PreToolUse = [
        {
          matcher = "AskUserQuestion|ExitPlanMode";
          hooks = hook "waiting";
        }
      ];
      UserPromptSubmit = [ { hooks = hook "clear"; } ];
      PostToolUse = [ { hooks = hook "clear"; } ];
      PostToolUseFailure = [ { hooks = hook "clear"; } ];
      Stop = [ { hooks = hook "clear"; } ];
      SessionStart = [ { hooks = hook "clear"; } ];
      SessionEnd = [ { hooks = hook "clear"; } ];
    }
  );
in
{
  home.packages = [ claude-tmux-alert ];

  # Runs after dracula's run-shell, so the append survives it.
  programs.tmux.extraConfig = lib.mkAfter ''
    # Claude Code alerts (claude-alert.nix)
    set -ga status-right '#{?@claude_waiting_count,#[fg=#f8f8f2 bg=#ff5555 bold] ⚠ #{@claude_waiting_count} ,}'
    bind W if -F '#{@claude_waiting_count}' "choose-tree -Zw -f '#{@claude_waiting}'" "display 'No Claude waiting'"
  '';

  # ~/.claude/settings.json stays a writable file (Claude edits it itself); only its
  # `hooks` key is owned here and overwritten on every switch.
  home.activation.claudeHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    run mkdir -p "$HOME/.claude"
    [ -f "$settings" ] || run sh -c 'echo "{}" > "$1"' _ "$settings"
    tmp=$(mktemp)
    if ${pkgs.jq}/bin/jq --slurpfile h ${claudeHooks} '.hooks = $h[0]' "$settings" >"$tmp"; then
      if ! ${pkgs.diffutils}/bin/cmp -s "$tmp" "$settings"; then
        run sh -c 'cat "$1" > "$2"' _ "$tmp" "$settings"
      fi
    else
      warnEcho "claude hooks: could not parse $settings, left untouched"
    fi
    rm -f "$tmp"
  '';
}
