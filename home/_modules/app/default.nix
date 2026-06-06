{
  lib,
  ctx,
  ...
}:

{
  options.aln.app.enable = lib.mkEnableOption "app";
  config.aln.app.enable = ctx.host.is.gui;
}
