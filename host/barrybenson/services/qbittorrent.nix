{ config, ... }:

{
  # webui is qui (own login), which proxies qBittorrent's webui on 127.0.0.1:<qui.internalPort>.
  # qBittorrent itself skips auth for localhost, so caddy must not proxy to it directly
  barrybenson.services.qbittorrent.webui.port = config.nixarr.qbittorrent.webuiPort;

  nixarr.qbittorrent.enable = true;
}
