{ config, aln, ... }:

{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile."zellij/config.kdl".source = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./zellij_config.kdl);
}
