{ lib, config, aln, ... }:


let
  keys = [
    "personal"
    "liao0144"
  ];
in
{
  programs.ssh.matchBlocks."github.com" = {
    identityFile = config.sops.secrets.ssh_allenl_personal.path;
    addKeysToAgent = "yes";
  };
  programs.ssh.matchBlocks."umn.edu" = {
    identityFile = config.sops.secrets.ssh_allenl_liao0144.path;
    addKeysToAgent = "yes";
  };

  sops.secrets = lib.mergeAttrsList (map (key: {
    "ssh_allenl_${key}" = {
      sopsFile = aln.lib.relToRoot "secrets/user/allenl/ssh.yaml";
      mode = "0400";
      inherit key;
    };
  }) keys);
}
