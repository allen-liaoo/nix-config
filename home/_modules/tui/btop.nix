{
  config,
  lib,
  pkgs-aln,
  ...
}:

let
  # out of store (a string, not a path) so matugen can rewrite it
  theme = "${config.xdg.stateHome}/matugen/btop/matugen.theme";
in
{
  aln.matugen.template."btop" = {
    enable = config.aln.de.enable;
    content = {
      input_path = config.aln.matugen.themesPath "btop.theme";
      output_path = theme;
      post_hook = "pkill -USR2 btop || true";
    };
  };

  aln.shell.module = lib.mkIf config.aln.de.enable {
    tools.btop = pkgs-aln.btop.wrap { inherit theme; };
  };
}
