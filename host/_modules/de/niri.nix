{ inputs, pkgs, ... }:

{
  programs.niri = {
    enable = true;
    package = inputs.niri-git.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  hardware.graphics.enable = true;
}
