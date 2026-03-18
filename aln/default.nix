args:

let 
  meta = import ./meta.nix;
  alnLib = ./lib (args // { inherit meta; });
in {
  inherit meta;
  lib = alnLib;
  ctx = {
    hostName = args.hostName or "default";  # default for non-nixos
    userName = args.userName or null;
  };
}
