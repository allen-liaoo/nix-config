{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.io.enable {
  networking.networkmanager.enable = true;
}
