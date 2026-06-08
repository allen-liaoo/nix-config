{
  lib,
  config,
  ctx,
  ...
}:

lib.mkIf config.aln.io.enable {
  networking.networkmanager.enable = true;

  aln.impermanence.dirs = [
    "/etc/NetworkManager/system-connections"
  ];
}
