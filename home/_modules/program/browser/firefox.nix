{ lib, config, pkgs, aln, ... }@args:

{
  programs.firefox = import ./firefox args;

  stylix.targets.firefox = lib.mkIf (config.stylix.enable) {
    colorTheme.enable = true;
    profileNames = [ "default" ];
  };
}
