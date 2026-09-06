{
  lib,
  pkgs,
  config,
  inputs,
  alnLib,
  ...
}:

let
  nvimxPkg =
    with inputs.nvimx;
    makeNvimxWithModule (pkgs.stdenv.hostPlatform.system) {
      nvimx.treesitter.enableAllGrammars = true;
      nvimx.preset.nix.enable = true;
      nvimx.preset.rust.enable = true;
      nvimx.preset.shells.enable = true;
    };
in
{
  home.packages = [
    nvimxPkg
    pkgs.wl-clipboard
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
