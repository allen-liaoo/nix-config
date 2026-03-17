{ pkgs, customLib, ... }:
{
  imports = map customLib.relToRoot (
    map (p: "modules/nixos/" + p) [
      "nixos.nix"
      "shell.nix"
      "sshd.nix"
    ]
  );
}
