{ config, lib, pkgs, aln, ... }:

{
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1"; # install to the disk, not a partition
    useOSProber = false;     # headless server, no dual-boot needed
  };

  boot.tmp.useTmpfs = true;

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    wait-online.enable = true;
  };
  # Need network-online for podman-user-wait-network-online.service
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];


  users.users.${aln.inventory.users.allenl.name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    linger = true;
    hashedPasswordFile = config.sops.secrets.passwd_allenl.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPevSDBLs3jQWYE8sq2Dx6S2qQ4VzpKn5RvS1zXkGfiW wcliaw610@gmail.com"
    ];
  };
}
