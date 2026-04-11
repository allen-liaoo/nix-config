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

  home.sessionVariables = {
    "EDITOR" = lib.mkForce "nvim";
    "VISUAL" = lib.mkForce "nvim";
  };
}
