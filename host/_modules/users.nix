{
  lib,
  config,
  ctx,
  ...
}:

{
  # required for sops-nix to use sops-install-secrets-for-users.service instead of an activation script
  # which is used for ordering services (i.e. with impermanence)
  services.userborn.enable = true;

  # userborn keeps UIDs/GIDs stable by reading its previous passwd/group, so they must persist.
  # Otherwise system users without a static uid are reallocated each boot and lose
  # access to their persisted state. 
  # Can't persist /etc/passwd itself: userborn umounts it to write it.
  # /var/lib/nixos is in pathsNeededForBoot, so it's bind mounted in initrd, before userborn runs
  services.userborn.passwordFilesLocation = lib.mkIf ctx.host.hasTag.impermanent "/var/lib/nixos";


  users.mutableUsers = false;
  users.users = lib.mergeAttrsList (
    map (user: {
      ${user.name} = {
        isNormalUser = !(user.hasTag.system-user);
        group = user.name;
        extraGroups = user.groups;
        linger = user.hasTag.linger;
        hashedPasswordFile = config.sops.secrets."passwd_${user.name}".path;
      };
    }) ctx.host.users
  );

  users.groups = 
    let
      userGroups = lib.genAttrs (map (user: user.name) ctx.host.users) (_: { });
      extraGroups = lib.genAttrs (lib.unique (lib.flatten (map (user: user.groups) ctx.host.users))) (_: { });
    in
    lib.recursiveUpdate userGroups extraGroups;

  # account service
  services.accounts-daemon.enable = !ctx.host.is.server;

  # enable sudoers to use some commands without sudo
  security.sudo = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl suspend";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/shutdown";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
