{ config, ... }:

{
  barrybenson.services.radarr.webui.port = config.nixarr.radarr.port;

  nixarr.radarr.enable = true;

  nixarr.radarr.settings-sync.transmission.enable = true;
  nixarr.transmission.enable = true;

  # nixarr.radarr.settings-sync.downloadClients = [
  #   {
  #     name = "qBittorrent";
  #     implementation = "QBittorrent";
  #     fields = {
  #       host = "127.0.0.1";
  #       port = config.services.qbittorrent.webuiPort; # qBittorrent's own webui, not qui
  #       movieCategory = "radarr"; # downloads to <mediaDir>/qbittorrent/radarr
  #     };
  #   }
  # ];
  services.radarr.settings.auth.required = "DisabledForLocalAddresses";
  aln.impermanence.dirs = [ config.nixarr.radarr.stateDir ];
}
