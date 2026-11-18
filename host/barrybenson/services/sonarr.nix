{ config, ... }:

{
  barrybenson.services.sonarr.webui.port = config.nixarr.sonarr.port;

  nixarr.sonarr.enable = true;

  nixarr.sonarr.settings-sync.transmission = {
    enable = true;
    config = {
      # remove from transmission once imported and done seeding (deletes the copy in torrents/,
      # the hardlinked library file stays)
      remove_completed_downloads = true;
      remove_failed_downloads = true;
      fields.tvCategory = "sonarr"; # downloads to <mediaDir>/torrents/sonarr
    };
  };

  services.sonarr.settings.auth.required = "DisabledForLocalAddresses";
  aln.impermanence.dirs = [ config.nixarr.sonarr.stateDir ];
}

