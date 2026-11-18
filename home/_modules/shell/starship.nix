{
  lib,
  ctx,
  pkgs-aln,
  ...
}:

{
  # the packaged nix_shell symbol is a nerd-font glyph
  aln.shell.module = lib.mkIf (!ctx.host.is.gui) {
    tools.starship = pkgs-aln.starship.wrap {
      settings.nix_shell.symbol = lib.mkForce "❄️";
    };
  };
}
