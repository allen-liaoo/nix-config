{ config, customLib, ... }:

{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile."zellij/config.kdl".source = config.lib.file.mkOutOfStoreSymlink (customLib.outOfStoreRelToRoot config.home.homeDirectory ./zellij_config.kdl);
}
