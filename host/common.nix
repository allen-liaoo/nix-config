{ pkgs, aln, ... }:
{
  imports = map aln.lib.relToRoot (
    map (p: "modules/nixos/" + p) [
      "nixos.nix"
      "shell.nix"
      "sshd.nix"
    ]
  );
}
