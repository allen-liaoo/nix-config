{
  config,
  ...
}:

{
  barrybenson.services.seerr.webui.port = config.nixarr.seerr.port;
  nixarr.seerr.enable = true;
  aln.impermanence.dirs = [ config.nixarr.seerr.stateDir ];
}
