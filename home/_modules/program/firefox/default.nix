{ lib, config, aln, ... }:

{
  imports = builtins.filter (f: !(lib.hasSuffix "extensions_meta.nix" f)) (aln.lib.listDirFiles ./.);

  programs.firefox.enable = true;

  stylix.targets.firefox = lib.mkIf (config.stylix.enable) {
    colorTheme.enable = true;
    profileNames = [ "default" ];
  };
}
