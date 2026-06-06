{
  lib,
  ctx,
  ...
}:

{
  options.aln.de.enable = lib.mkEnableOption "de";
  config.aln.de.enable = ctx.host.is.gui;
}
