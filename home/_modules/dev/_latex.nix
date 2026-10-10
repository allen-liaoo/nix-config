{
  pkgs,
  lib,
  ctx,
  inventory,
  ...
}:

lib.optionalAttrs (with inventory; (ctx.host.equals hosts.theseus && ctx.user.equals users.allenl)) {
  home.packages = [
    pkgs.texliveBasic
  ];
}
