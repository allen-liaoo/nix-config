{
  config,
  lib,
  pkgs-aln,
  ...
}:

let
  # out of store (a string, not a path) so matugen can rewrite it
  theme = "${config.xdg.stateHome}/matugen/tmux-colors.conf";
  tmux = lib.getExe config.aln.shell.package.configuration.tools.tmux;
in
{
  aln.matugen.template."tmux" = {
    enable = config.aln.de.enable;
    content = {
      input_path = config.aln.matugen.themesPath "tmux-colors.conf";
      output_path = theme;
      post_hook = "${tmux} source-file -q ${theme} 2>/dev/null || true"; # live reload
    };
  };

  aln.shell.module = lib.mkIf config.aln.de.enable {
    tools.tmux = pkgs-aln.tmux.wrap { inherit theme; };
  };
}
