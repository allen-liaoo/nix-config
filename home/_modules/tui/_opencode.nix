{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
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
    tui.theme = "system";
  };
}
