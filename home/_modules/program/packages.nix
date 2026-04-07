 { pkgs, ... }:

 {
  home.packages = with pkgs; [
    bitwarden-desktop
    loupe
    nautilus
    qbittorrent
    signal-desktop
    spotify
    zotero
  ];
 }
