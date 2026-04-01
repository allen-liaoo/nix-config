{ lib, aln, ... }:

{
  imports = (aln.lib.importExcept (aln.lib.listDirFiles ./.) [ "secrets_dir.nix" ]) ++ aln.lib.listSubdirs ./.;
}
