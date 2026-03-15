{ config, pkgs, ... }:

{
  imports = [
    ./../modules/home.nix

    ./sops.nix
  ];

  home.username = "pig";
  home.homeDirectory = "/home/pig";

  home.packages = with pkgs; [
    cowsay
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "Allen Liao (from VM)";
      email = "wcliaw610@gmail.com";
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        identityFile = config.sops.secrets.nixos_config_deploy.path;
      };
    };
  };
}
