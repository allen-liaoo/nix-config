{ ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      MaxAuthTries = 3;
      LoginGraceTime = "5m";
      AllowAgentForwarding = "no";
      AllowTcpForwarding = "no";
      X11Forwarding = false;
    };

    # Must generate host ssh key for sops
    # host will be able to decrypt user age keys and other host-level secrets
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  aln.impermanence.files = [
    # these are the only files necessary to persist on initial install,
    # the rest of the configs can be generated from the config with these keys
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key.pub"
  ];
}
