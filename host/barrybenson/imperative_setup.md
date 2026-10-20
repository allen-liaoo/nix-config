## Network
+ Reserve barrybenson's IP in the TP-Link router's DHCP settings.
  Only clients without mDNS need it (i.e. smart TVs use `http://<ip>`).
+ mDNS names: `http://<service>.barrybenson.local`. Linux clients using nss-mdns `mdns4_minimal`.

## Media services
Managed by nixarr (`services/`). State lives in `/var/lib/nixarr/<service>` (persisted), media in
`/srv/media`: downloads in `qbittorrent/<category>`, library in `library/{shows,movies}`.
nixarr extracts each *arr API key to `/var/lib/nixarr/secrets/<service>.api-key`; `sudo nixarr list-api-keys`
prints them. Use `http://127.0.0.1:<port>` for service-to-service URLs.

+ qBittorrent (`qbittorrent.barrybenson.local`) is served through qui: create the qui login on first visit,
  then add the qBittorrent instance `http://127.0.0.1:8085` (no credentials, qBittorrent trusts localhost).
+ Prowlarr / Sonarr / Radarr: create the login user on first visit (see `_mkServarr.nix`).
  The qBittorrent download client is added to Sonarr/Radarr by nixarr (`*-sync-config.service`).
  + Sonarr: root folder `/srv/media/library/shows`
  + Radarr: root folder `/srv/media/library/movies`
  + Prowlarr: add indexers; Settings > Apps: add Sonarr (`:8989`) and Radarr (`:7878`) with their API keys
+ Jellyfin: run the setup wizard. Libraries `/srv/media/library/{shows,movies}`.
  Dashboard > Playback > Transcoding: VAAPI, device `/dev/dri/renderD128`.
