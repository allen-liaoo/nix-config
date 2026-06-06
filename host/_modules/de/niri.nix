{
  lib,
  config,
  pkgs-unstable,
  ...
}:

lib.mkIf config.aln.de.enable {
  programs.niri = {
    enable = true;
    package = pkgs-unstable.niri;
  };
  hardware.graphics.enable = true;
}
