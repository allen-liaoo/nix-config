{ config, ... }:

{
  barrybenson.services.jellyfin.webui.port = config.nixarr.jellyfin.port;

  nixarr.jellyfin.enable = true;

  # AMD gpu transcoding
  services.jellyfin.hardwareAcceleration = {
    enable = true;
    type = "vaapi";
    device = "/dev/dri/renderD128";
  };
  hardware.graphics.enable = true;
  users.users.jellyfin.extraGroups = [
    "render"
    "video"
  ];

  # client auto-discovery on LAN
  networking.firewall.allowedUDPPorts = [ 7359 ];

  aln.impermanence.dirs = [ config.nixarr.jellyfin.stateDir ];
}
