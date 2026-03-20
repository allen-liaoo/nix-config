{ lib, alnLib, ... }@args:

(lib.evalModules {
  specialArgs = args;
  modules = [ ./options.nix ./config.nix ];
}).config
