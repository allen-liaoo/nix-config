{ lib, inputs, pkgs, aln, ... }:

{
  programs.niri.enable = true;
  hardware.graphics.enable = true;

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
    package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
    configFiles = [
      "/var/cache/dms-greeter/settings.json"
      "/var/cache/dms-greeter/session.json"
    ];
    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
  };

  # symlink dms-greeter config files
  systemd.tmpfiles.rules = let 
    dmsDir = "/dms-greeter/";
    settingsJson = pkgs.writeText "settings.json" (builtins.toJSON {
      #currentThemeName = "blue";
    });
    sessionJson = pkgs.writeText "session.json" (builtins.toJSON {
      wallpaperPath = aln.lib.relToRoot "assets/wallpaper/wallpaper-night.jpg";
      wallpaperFillMode = "PreserveAspectCrop";
    });
  in [
    "d /var/cache/dms-greeter 0755 root root -"
    "C+ /var/cache/dms-greeter/settings.json - - - - ${settingsJson}"
    "C+ /var/cache/dms-greeter/session.json - - - - ${sessionJson}"
  ];
}
