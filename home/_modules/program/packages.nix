 { pkgs, ... }:

 {
  home.packages = with pkgs; [
    bitwarden-desktop
    signal-desktop
    spotify
  ];
 }
