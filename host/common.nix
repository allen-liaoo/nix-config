{ pkgs, customLib, ... }:
{
  imports = map customLib.relativeToRoot (
    map (p: "modules/nixos/" + p) [
      "nixos.nix"
      "shell.nix"
      "sshd.nix"
    ]
  );
}
