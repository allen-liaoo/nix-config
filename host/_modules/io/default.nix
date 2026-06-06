{
  lib,
  ctx,
  ...
}:

{
  options.aln.io.enable = lib.mkEnableOption "io";
  config.aln.io.enable = ctx.host.is.gui;
}
