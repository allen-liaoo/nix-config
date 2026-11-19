{ lib }@args:

import ./path.nix args
// {
  # Callers that have pkgs use this: aln.lib.withPkgs pkgs
  #withPkgs = pkgs: import ./syspkg.nix (args // { inherit pkgs; });
}
