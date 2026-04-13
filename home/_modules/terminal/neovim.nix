{ lib, pkgs, inputs, config, ... }:

let
  nvimxPkg = inputs.nvimx.packages.${pkgs.stdenv.hostPlatform.system}.default;
  #extended-nixvim = nvimxPkg.extend config.stylix.targets.nixvim.exportedModule;
in
{
  home.packages = [
    nvimxPkg
  ];

  programs.fish.shellAliases = {
    "v" = lib.mkForce "nvim";
    "vi" = lib.mkForce "nvim";
    "vim" = lib.mkForce "nvim"; 
  };

  home.sessionVariables = {
    "EDITOR" = lib.mkForce "nvim";
    "VISUAL" = lib.mkForce "nvim";
  };
}
