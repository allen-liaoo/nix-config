{
  pkgs,
  pkgs-aln,
  ...
}:

{
  home.packages = with pkgs; [
    bat
    fd
    fzf
    ripgrep
    just

    # TODO: fix pkg
    # pkgs-aln.television
  ];

  programs.fish = {
    shellAliases = {
      cat = "bat";
    };
    shellAbbrs = {
      js = "just";
      tvc = "tv channels";
      tvj = "tv journal";
      tvn = "tv nix-search-tv";
      tvt = "tv text";
    };
  };
}
