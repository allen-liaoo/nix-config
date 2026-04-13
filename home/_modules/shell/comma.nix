# https://github.com/nix-community/comma
# https://github.com/nix-community/nix-index-database

{
  inputs,
  pkgs,
  ...
}:

{
  programs.nix-index-database.comma.enable = true;
  # TODO: fix slow-down of "command not found"; below does not work
  # imports = [ inputs.nix-index-database.homeModules.default ];
  # home.packages = with pkgs; [ comma  ];
}
