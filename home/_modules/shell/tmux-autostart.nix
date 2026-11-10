{
  config,
  lib,
  ...
}:

# terminals set ALN_TMUX_AUTOSTART=1 in their env to open each window in a new tmux session,
# back in fish once tmux exits/detaches; `<terminal> -e <cmd>` still bypasses this since fish
# isn't started. Erased first so nested shells don't start tmux
lib.mkIf config.aln.app.enable {
  aln.shell.module.integrations.tmux-autostart.interactiveInit = ''
    if set -q ALN_TMUX_AUTOSTART; and not set -q TMUX
      set -e ALN_TMUX_AUTOSTART
      tmux new-session
    end
  '';
}
