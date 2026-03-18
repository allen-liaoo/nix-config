{ pkgs, aln, ... }:
{
  imports = [
    ./modules/nixos.nix
    ./modules/shell.nix
    ./modules/sshd.nix
  ];
}
