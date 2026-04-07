 { pkgs, ... }:

 {
  home.packages = with pkgs; [
    bitwarden-desktop
    nautilus
    signal-desktop
    spotify
  ];
 }
