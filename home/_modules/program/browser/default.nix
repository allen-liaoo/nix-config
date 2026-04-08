{ lib, pkgs, aln, ... }:

{
  imports = aln.lib.listDirFiles ./. ++ aln.lib.importExcept (aln.lib.listSubdirs ./.) [ "firefox" ];
}
