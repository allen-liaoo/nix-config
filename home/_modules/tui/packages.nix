{
  pkgs-unstable,
  ...
}:

{
  home.packages = [
    pkgs-unstable.concord-tui # TODO: move to pkgs (stable) once 26.11
  ];
}
