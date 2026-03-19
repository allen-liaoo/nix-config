# metadata of hosts and users
{ lib, ... }:

rec {
  systems = {
    x86_linux = "x86_64-linux";
  }; 

  hosts = {
    # vm
    guinea = {
      name = "guinea";
      system = systems.x86_linux;
      users = with users; [ pig.name ];
    };
  };

  users = {
    # vm user
    pig = {
      name = "pig";
      primary = true;
    };
  };

  systemsList = builtins.attrValues systems;
  hostNames = builtins.attrNames hosts;
  userNames = builtins.attrNames users;

  # All "user@host" pairs that need a homeConfiguration
  userHostPairs = lib.flatten (
    lib.mapAttrsToList (hostName: hostCfg:
      map (userName: { inherit userName hostName; }) hostCfg.users
    ) hosts
  );

  # Does host X have user Y?
  hostHasUser = hostName: userName:
    builtins.elem userName hosts.${hostName}.users;

  # Get all users metadata for a host as a list
  usersForHost = hostName: (map (u: users."${u}") hosts."${hostName}".users);

  isNixOS = (hostName: hostName != "default");
}
