{
  pkgs,
  pkgs-unstable,
  ...
}:

{
  home.packages = [
    pkgs.wl-clipboard
    pkgs-unstable.concord-tui
  ];
}
