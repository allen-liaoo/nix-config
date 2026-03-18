{ config, aln, ... }: {
  sops.secrets = {
    "nix_config_deploy" = {
      sopsFile = aln.lib.relToRoot "secrets/common.yaml";
      mode = "0400";
      path = "${config.home.homeDirectory}" + "/.ssh/nix_config_deploy";
    };
  };
}
