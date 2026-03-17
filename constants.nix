{
  # shared constants will be accessible to both

  homeManager = {
    # Directory of current repository relative to a user's $HOME
    # This is particularly useful for mkOutOfStoreSymlink for managing dotfiles outside of the nix store (so one doesn't need to switch each time a change is made)
    # Due to how flakes works, one cannot use a relative path to refer to this repo itself
    # Instead, the relevant files are copied into the store and the relative path is resolved against the store, which defeats the purpose
    # So we require that ALL INSTANCES OF THIS REPO ON NIXOS/NON-NIXOS machines to be stored in the below path (one per user who manages hm/os on NixOS machines)
    NIX_CONFIG_REL_PATH = "/nix-config";

    IS_NIXOS = builtins.pathExists /etc/NIXOS;
  };

  nixOs = {};
  shared = {};
}
