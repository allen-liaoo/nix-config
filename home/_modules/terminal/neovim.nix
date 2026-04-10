{ lib, pkgs, inputs, ... }:

{
  home.packages = [
    inputs.nvimx.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.fish.shellAbbrs = {
    "v" = lib.mkForce "nvim";
    "vi" = lib.mkForce "nvim";
    "vim" = lib.mkForce "nvim"; 
  };
}
