{
  lib,
  pkgs,
  config,
  ...
}:

lib.mkIf config.aln.app.enable {
  home.packages = with pkgs; [
    bitwarden-desktop
    loupe # image viewer
    nautilus # file browser
    signal-desktop
    zotero
  ];

  # fix dep electron-39.8.10 insecure and EOL
  # https://github.com/NixOS/nixpkgs/issues/526914
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      bitwarden-desktop = prev.bitwarden-desktop.override {
        electron_39 = final.electron_39-bin;
      };
    })
  ];
}
