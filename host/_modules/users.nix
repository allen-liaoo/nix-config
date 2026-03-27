{ lib, config, aln, ... }:

{
  # required for sops-nix to use sops-install-secrets-for-users.service instead of an activation script
  # useful for ordering services (i.e. with impermanence)
  services.userborn.enable = true;
  
  users.users = lib.mergeAttrsList (map (user: {
    ${user.name} = {
      isNormalUser = !(user.hasTags [ "system-user" ]);
      extraGroups = lib.optionals (user.hasTags ["sudoer"]) [ "wheel" ];
      linger = user.hasTags [ "linger" ];
      hashedPasswordFile = config.sops.secrets."passwd_${user.name}".path;
    };
  }) aln.ctx.host.users);
}
