{
  lib,
  pkgs,
  pkgs-aln,
  ctx,
  inventory,
  ...
}:

{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      theme = "system"; # TODO: change to tui on next HM version
      permission = {
        "*" = "ask";
        bash = {
          "*" = "ask";
          "rm *" = "deny";
          "grep *" = "allow";
        };
        grep = "allow";
        glob = "allow";
        question = "allow";
      };
    };
  };

  programs.mcp = {
    enable = true;
    servers = {
      nix = {
        type = "local";
        command = lib.getExe pkgs.mcp-nixos;
      };
      typst = lib.mkIf (ctx.host.equals inventory.hosts.theseus) {
        type = "local";
        command = lib.getExe pkgs-aln.typst-mcp;
      };
    };
  };
}
