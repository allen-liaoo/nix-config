 { pkgs, ... }:

 {
  home.packages = with pkgs; [
    bitwarden-desktop
    gpu-screen-recorder
    loupe # image viewer
    nautilus # file browser
    signal-desktop
    spotify
    zotero
  ];
 }
