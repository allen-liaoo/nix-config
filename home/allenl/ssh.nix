{ config, aln, ... }:

{
  programs.ssh.matchBlocks."github.com" = {
    identityFile = config.sops.secrets.ssh_allenl.path;
    addKeysToAgent = "yes";
  };

  sops.secrets.ssh_allenl = {
    sopsFile = aln.lib.relToRoot "secrets/user/allenl/common.yaml";
    mode = "0400";
    key = "ssh_private";
  };
}
