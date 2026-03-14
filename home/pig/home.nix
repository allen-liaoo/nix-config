{ config, pkgs, ... }:

{
  home.username = "pig";
  home.homeDirectory = "/home/pig";

  home.packages = with pkgs; [
    cowsay
  ];

  programs.home-manager.enable = true;

  imports = [
    ./../modules/home.nix
  ];
}
