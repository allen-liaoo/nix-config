{ config, ... }:

{
  barrybenson.services.sonarr.webui.port = config.nixarr.sonarr.port;

  nixarr.sonarr.enable = true;

  nixarr.sonarr.settings-sync.transmission.enable = true;
   
  # nixarr.sonarr.settings-sync.downloadClients = [
  #   {
  #     name = "qBittorrent";
  #     implementation = "QBittorrent";
  #     fields = {
  #       host = "127.0.0.1";
  #       port = config.services.qbittorrent.webuiPort; # qBittorrent's own webui, not qui
  #       tvCategory = "sonarr"; # downloads to <mediaDir>/qbittorrent/sonarr
  #     };
  #   }
  # ];
  services.sonarr.settings.auth.required = "DisabledForLocalAddresses";
  aln.impermanence.dirs = [ config.nixarr.sonarr.stateDir ];
}

