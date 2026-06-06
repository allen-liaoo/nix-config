{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.aln.io.enable {
  hardware.bluetooth.enable = true;
  environment.systemPackages = with pkgs; [ bluez ];

  boot.kernelModules = [ "bnep" ]; # bluetooth tethering
}
