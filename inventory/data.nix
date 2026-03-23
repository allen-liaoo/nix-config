# metadata of hosts and users
{ lib, config, alnLib, ... }:

{
  hosts = {
    # homeserver
    barrybenson = {
      name = "barrybenson";
      system = "x86_64-linux";
      kind = "server";
      tags = [ "impermanent" ];
      users = with config.users; [ allenl ];
    };
    # vm
    guinea = {
      name = "guinea";
      system = "x86_64-linux";
      kind = "server";
      tags = [ "impermanent" ];
      users = with config.users; [ pig ];
    };
  };

  users = {
    # me
    allenl = {
      name = "allenl";
      tags = [ "sudoer" ];
      can.deployNixConfig = true;
    };
    # vm user
    pig = {
      name = "pig";
      tags = [ "sudoer" ];
      can.deployNixConfig = true;
    };
  };
}
