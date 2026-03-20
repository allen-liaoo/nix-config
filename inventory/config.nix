# metadata of hosts and users
{ lib, config, alnLib, ... }:

{
  hosts = {
    # vm
    guinea = {
      name = "guinea";
      system = "x86_64-linux";
      kind = "server";
      users = with config.users; [ pig ];
    };
  };

  users = {
    # vm user
    pig = {
      name = "pig";
      can.deployNixConfig = true;
    };
  };
}
