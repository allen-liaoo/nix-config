{ lib, ... }:

let
  rootPath = ../.; # project root path; resolves in nix store
  inherit (builtins) readFile readDir attrNames;
  inherit (lib) pipe path concatMap hasPrefix hasSuffix removePrefix filterAttrs;
in
rec {
  # use path relative to the root of this project
  # note that this will resolve to be a path within /nix/store
  # to refer to a path outside of /nix/store, use outOfStoreRelToRoot
  relToRoot = path.append rootPath;

  # recursively imports every nix file in a directory, ignoring files/directories starting with "_"
  importRecursive =
    dir:
    let
      entries = readDir (toString dir); # toString to prevent dir from being copied to store again
      nixFiles = pipe entries [
        (filterAttrs (name: typ: typ == "regular" && hasSuffix ".nix" name && !(hasPrefix "_" name)))
        attrNames
        (map (f: path.append dir f))
      ];
      subdirs = pipe entries [
        (filterAttrs (name: typ: typ == "directory" && !(hasPrefix "_" name)))
        attrNames
        (map (d: path.append dir d))
      ];
    in
    nixFiles ++ concatMap importRecursive subdirs;

  ## HOME MANAGER EXCLUSIVE ##

  # Directory of current repository relative to a user's $HOME
  # DO NOT USE DIRECTLY
  # We require that ALL INSTANCES OF THIS REPO ON NIXOS/NON-NIXOS MACHINES TO BE STORED IN THE BELOW PATH (one per user who manages hm/os on NixOS machines)
  # See outOfStoreRelToRoot for explanation
  NIX_CONFIG_REL_HOME = readFile (relToRoot "REPO_NAME");

  # Returns the actual, out of store, path relative to the root of the repository
  # ONLY USE WITHIN HM
  # This is particularly useful for HM's mkOutOfStoreSymlink for managing dotfiles outside of the nix store (so one doesn't need to switch each time a change is made)
  # Due to how flakes work, one cannot use a relative path to refer to anything outside of the store
  # Because the repository is copied into the store and the relative path is resolved against it
  # Usage: when calling inside "modules/xyz/"
  #   outOfStoreRelToRoot config.home.HomeDirectory ./config.kdl
  # returns /home/hm_user/nix-config/modules/xyz/config.kdl
  # Note that ./config.kdl is a relative path that resolves in /nix/store, which is fine
  outOfStoreRelToRoot = (
    homeDir: relPath:
    let
      flakePath = toString rootPath;
      relPathStr = toString relPath;
    in
    builtins.trace "flakePath: ${flakePath}\n relPath: ${relPathStr}" 
    (assert hasPrefix flakePath relPathStr;
    homeDir + "/" + NIX_CONFIG_REL_HOME + (removePrefix flakePath relPathStr))
  );
}
