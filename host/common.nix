{ pkgs, aln, ... }:
{
  imports = [
    ./modules/nixos.nix
    ./modules/shell.nix
    ./modules/sops.nix
    ./modules/sshd.nix
  ];
}
