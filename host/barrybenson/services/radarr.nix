{ config, ... }:

{
  barrybenson.services.radarr.webui.port = config.nixarr.radarr.port;

  nixarr.radarr.enable = true;

  nixarr.radarr.settings-sync.transmission = {
    enable = true;
    config = {
      # remove from transmission once imported and done seeding (deletes the copy in torrents/,
      # the hardlinked library file stays)
      remove_completed_downloads = true;
      remove_failed_downloads = true;
      fields.movieCategory = "radarr"; # downloads to <mediaDir>/torrents/radarr
    };
  };

  services.radarr.settings.auth.required = "DisabledForLocalAddresses";
  aln.impermanence.dirs = [ config.nixarr.radarr.stateDir ];
}
