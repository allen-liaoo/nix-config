{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:

lib.mkIf config.aln.app.enable {
  home.packages = (with pkgs; [
    loupe # image viewer
    nautilus # file browser
    signal-desktop
    zotero
  ])
  # old BW uses EOL electron version
  # https://github.com/NixOS/nixpkgs/issues/526914
  ++ (with pkgs-unstable; [
    bitwarden-desktop
  ]);
}
