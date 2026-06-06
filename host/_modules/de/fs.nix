{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.de.enable {
  # needed for nautilus
  services.gvfs.enable = true;
}
