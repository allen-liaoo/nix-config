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
  # Lucienne (Vega) VCN, per `vainfo`: no AV1, no VP8. h264 encode is always on
  services.jellyfin.transcoding = {
    hardwareDecodingCodecs = {
      h264 = true;
      hevc = true;
      hevc10bit = true;
      mpeg2 = true;
      vc1 = true;
      vp9 = true;
    };
    hardwareEncodingCodecs.hevc = true;
  };
  # otherwise the above is only written when encoding.xml doesn't exist yet (ignored after first start);
  # dashboard transcoding changes are now overwritten on restart (old file backed up next to it)
  services.jellyfin.forceEncodingConfig = true;
  hardware.graphics.enable = true;
  users.users.jellyfin.extraGroups = [
    "render"
    "video"
  ];

  # client auto-discovery on LAN
  networking.firewall.allowedUDPPorts = [ 7359 ];

  aln.impermanence.dirs = [ config.nixarr.jellyfin.stateDir ];
}
