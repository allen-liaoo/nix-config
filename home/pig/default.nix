{ config, pkgs, lib, aln, ... }:

{
  imports = aln.lib.listDirFiles ./. ++ [
    ../common.nix
  ];

  home.packages = with pkgs; [
  ];

  programs.home-manager.enable = true;
}
