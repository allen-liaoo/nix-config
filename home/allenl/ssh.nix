{
  lib,
  config,
  alnLib,
  inventory,
  ...
}:

let
  keys = [
    "personal"
    "liao0144"
  ];
in
{
  programs.ssh.settings = {
    "ionobro" = {
      hostname = "allenl.me";
      user = "allenliao"; # TODO: Change to al
    };
    "barrybenson" = with inventory; {
      hostname = "barrybenson.local"; # mDNS, same LAN
      user = users.al.name;
      serverAliveInterval = 60;
      serverAliveCountMax = 10;
    };
    # "guinea" = {
    #   hostname = "192.168.122.100";
    #   user = "pig";
    # };
    "*".identityFile = (map (key: config.sops.secrets."ssh_allenl_${key}".path) keys);
  };

  sops.secrets = lib.mergeAttrsList (
    map (key: {
      "ssh_allenl_${key}" = {
        sopsFile = alnLib.relToRoot "secrets/user/allenl/ssh.yaml";
        mode = "0400";
        path = config.home.homeDirectory + "/.ssh/" + key;
        inherit key;
      };
    }) keys
  );
}
