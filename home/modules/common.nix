{ lib, customLib, userName, ... }:

{
  imports = [
    ./ssh.nix
    ./xdg.nix

    ./shell
    ./term
  ];

  programs.home-manager.enable = true;

  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
