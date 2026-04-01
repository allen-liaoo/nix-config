# metadata of hosts and users
{ lib, config, alnLib, ... }:

let 
  users = {
    # me
    allenl = {
      name = "allenl";
      groups = [ "wheel" "input" ];
      can.deployNixConfig = true;
    };
    # vm user
    pig = {
      name = "pig";
      groups = [ "wheel" "input" ];
      can.deployNixConfig = true;
    };
  };
in
{
  hosts = {
    # homeserver
    barrybenson = {
      name = "barrybenson";
      os = "nixos";
      system = "x86_64-linux";
      kind = "server";
      tags = [ "impermanent" ];
      users = with users; [ allenl ];
    };
    # vm
    guinea = {
      name = "guinea";
      os = "nixos";
      system = "x86_64-linux";
      kind = "laptop";
      tags = [ "impermanent" ];
      users = with users; [ pig ];
    };
  };
  inherit users;
}
