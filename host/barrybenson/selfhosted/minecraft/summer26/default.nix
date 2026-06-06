{
  pkgs,
  ...
}:

{
  services.minecraft-servers = {
    servers.summer26 = {
      enable = true;
      package = pkgs.neoforgeServers.neoforge-1_21_1-21_1_228; # 229 too new

      autoStart = true;
      enableReload = true;
      serverProperties = {
        server-port = 25565;
        white-list = true;
        enable-rcon = true;
        difficulty = 3;
      };
      jvmOpts = [
        "-Xmx10G" "-Xms1G"
      ];

      whitelist = import ../_players.nix;
      operators = import ../_ops.nix {
        ayyllien = {
          level = 4;
        };
        Dsnustad = {
          level = 3;
        };
      };
      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          map pkgs.fetchurl (builtins.attrValues (import ./mods.nix))
        );
      };
    };
  };
}
