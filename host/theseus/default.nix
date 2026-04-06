{ aln, ... }:

{
  imports = aln.lib.listDirFiles ./. ++ aln.lib.listSubdirs ./. ++ [
    ../_modules
    nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];
}
