{ config, pkgs, lib, customLib, userName, ... }:

{
  imports = customLib.importDir { dir = ./.; } ++ [
    ../common.nix
  ];

  home.packages = with pkgs; [
  ];

  programs.home-manager.enable = true;
}
