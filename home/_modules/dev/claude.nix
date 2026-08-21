{ inputs, pkgs, ... }:

{
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
  home.packages = [
    pkgs.claude-code
  ];
}
