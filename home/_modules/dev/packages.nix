{ pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    antigravity-cli
    claude-code
  ];
}
