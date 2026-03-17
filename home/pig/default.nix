{ config, pkgs, lib, customLib, userName, ... }:

{
  imports = customLib.importDir { dir = ./.; } ++ [
    ./../modules/common.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  home.packages = with pkgs; [
  ];

  programs.home-manager.enable = true;
}
