{ lib, config, aln, ... }:

{
  imports = aln.lib.listDirFiles ./.;

  programs.firefox.enable = true;

  stylix.targets.firefox = lib.mkIf (config.stylix.enable) {
    colorTheme.enable = true;
    profileNames = [ "default" ];
  };
}
