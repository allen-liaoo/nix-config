{
  lib,
  config,
  inputs,
  ctx,
  ...
}:

let
  # gui hosts only ever have a single desktop user
  user = lib.head ctx.host.users;
in
{
  imports = [
    inputs.dank-greeter.nixosModules.default
  ];

  config = lib.mkIf config.aln.de.enable {
    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
      # copies settings.json/session.json/dms-colors.json from this user's
      # live DMS config at every greetd start, so the greeter always shows
      # the current theme/wallpaper
      configHome = "/home/${user.name}";
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
    };
  };
}
