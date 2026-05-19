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
    gtrash
    ripgrep
    just

    pkgs-aln.television
  ];

  programs.fish = {
    shellAliases = {
      cat = "bat";
    };
    shellAbbrs = {
      js = "just";
      tr = "gtrash put";
      tvc = "tv channels";
      tvj = "tv journal";
      tvn = "tv nix-search-tv";
      tvt = "tv text";
    };
  };
}
