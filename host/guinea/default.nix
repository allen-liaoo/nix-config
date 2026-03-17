{ customLib, ... }:

{
  imports = customLib.importDir { dir = ./.; } ++ customLib.importSubdirs ./. ++ [
    ../common.nix
  ];
}
