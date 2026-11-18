{
  lib,
  config,
  ...
}:

# firewall for the dms Cast plugin (cast-helper, installed in home/_modules/de/dms)
# ports must match the plugin's settings: https://github.com/Conava/dux-plugins/tree/master/Cast
lib.mkIf config.aln.de.enable {
  # device discovery over avahi's dbus api; openFirewall opens mDNS (UDP 5353)
  services.avahi = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 47830 ]; # serving files to the cast device
    # allowedUDPPortRanges = [
    #   {
    #     # AirPlay
    #     from = 47840;
    #     to = 47849;
    #   }
    # ];
  };
}
