{ config, constants, ... }:

{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile."zellij/config.kdl".source = config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + constants.NIX_CONFIG_REL_PATH + "/home/modules/term/zellij_config.kdl");
}
