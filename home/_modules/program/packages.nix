 { pkgs, ... }:

 {
  home.packages = with pkgs; [
    bitwarden-desktop
    loupe
    nautilus
    signal-desktop
    spotify
    zotero
  ];
 }
