{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.io.enable {
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
