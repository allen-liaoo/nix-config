{
  lib,
  config,
  ...
}:

let
  nssmdns = config.services.avahi.nssmdns4 || config.services.avahi.nssmdns6;
in
{
  networking.networkmanager.enable = true;

  # Let nss-mdns resolve .local names with more than two labels
  # The full mdns4 module (after dns in nsswitch) accepts them only if allowed here
  environment.etc."mdns.allow" = lib.mkIf nssmdns {
    text = ''
      .local.
      .local
    '';
  };

  system.nssDatabases.hosts = lib.mkIf nssmdns (
    lib.mkForce (
      [
        "mymachines" # name of local systemd containers and vms
        "files" # /etc/hosts
        "myhostname" # machine's own hostname, localhost
      ]
      ++ lib.optional config.services.resolved.enable "resolve [!UNAVAIL=return]" # systemd-resolved
      ++ [
        "dns"
        (if config.services.avahi.nssmdns6 then (if config.services.avahi.nssmdns4 then "mdns" else "mdns6") else "mdns4") # ask the local avahi daemon; important for avahi host resolution
      ]
    )
  );

  aln.impermanence.dirs = [
    "/etc/NetworkManager/system-connections"
  ];
}
