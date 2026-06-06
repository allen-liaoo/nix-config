{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.aln.de.enable {
  home.packages = with pkgs; [
    gpu-screen-recorder
    wl-clipboard
  ];
}
