## Network
+ Reserve barrybenson's IP in the router's DHCP settings.
+ mDNS names: `http://<service>.barrybenson.local`. Linux clients using nss-mdns `mdns4_minimal`.

## Media services
Managed by nixarr (`services/`). State lives in `/var/lib/nixarr/<service>` (persisted), media in
`/srv/media`: downloads in `torrents/<category>`, library in `library/{shows,movies}`.
nixarr extracts each *arr API key to `/var/lib/nixarr/secrets/<service>.api-key`; `sudo nixarr list-api-keys`
prints them. Use `http://127.0.0.1:<port>` for service-to-service URLs.

+ Prowlarr / Sonarr / Radarr: create the login user on first visit (see `_mkServarr.nix`).
  The Transmission download client is added to Sonarr/Radarr by nixarr (`*-sync-config.service`).
  If an old qBittorrent download client is still listed there, delete it.
  + Sonarr: root folder `/srv/media/library/shows`
  + Radarr: root folder `/srv/media/library/movies`
  + Prowlarr: add indexers; Settings > Apps: add Sonarr (`:8989`) and Radarr (`:7878`) with their API keys
+ Bazarr: nixarr's `bazarr-sync-config.service` is currently a no-op (it posts JSON, Bazarr only reads
  form data), so set Settings > Sonarr/Radarr (enable, `127.0.0.1`, API key) by hand.
  Settings > Languages: profile "English + Chinese Traditional" (en, zt), default for series and movies;
  Settings > Providers: embeddedsubtitles, podnapisi, yifysubtitles, tvsubtitles, gestdown
  (no accounts; OpenSubtitles.com has the best coverage but needs one).
+ Jellyfin: run the setup wizard. Libraries `/srv/media/library/{shows,movies}`.
  Dashboard > Playback > Transcoding: VAAPI, device `/dev/dri/renderD128`.
