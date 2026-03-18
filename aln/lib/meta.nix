# library functions operating on metadata
{ lib, meta, ... }:

{
  # Does host X have user Y?
  hostHasUser = hostName: userName:
    builtins.elem userName meta.hosts.${hostName}.users;

  # Get all users metadata for a host as attrs
  usersForHost = hostName:
    lib.genAttrs meta.hosts.${hostName}.users (u: meta.users.${u});
    
  isNixOS = (ctx: builtins.pathExists /etc/NIXOS); # or use context's hostName to determine?
}
