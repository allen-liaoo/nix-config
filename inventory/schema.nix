{
  lib,
  config,
  alnLib,
  ...
}:

let
  inherit (lib) mkOption flatten filterAttrs mergeAttrsList mapAttrsToList;
  inherit (lib.types) str bool enum listOf attrs attrsOf submodule functionTo;
  hostKinds = [
    "server"
    "laptop"
  ];
  oses = [
    "darwin" # unused
    "generic-linux"
    "nixos"
  ];
  systems = [
    "x86_64-linux"
  ];
  gpus = [
    "amd"
    "nvidia"
  ];
  hostTags = [
    "impermanent"
    "gui" # otherwise assumed headless
  ];
  userTags = [
  ];
  hostUserTags = [
    # Tags for users in nixos systems
    "system-user" # for normal users, ommit this # unused
    "linger" # unused
  ];
  groups = [
    "wheel"
    "i2c"
    "input"
  ];
  # Type of users
  userOpts =
    (
      { config, ... }:
      {
        options = {
          name = mkOption {
            type = str;
            default = "nobody";
          };
          tags = mkOption {
            type = listOf (enum userTags);
            default = [ ];
          };
          data = mkOption {
            type = attrs;
            default = { };
          };
          equals = mkOption {
            type = functionTo bool;
            default = user: user.name == config.name;
            readOnly = true;
          };
        };
      }
    );
  # Type of user tied to specific host
  hostUserOpts =
    (
      { config, ... }@args:
      {
        options = (userOpts args).options // {
          can = {
            deployNixConfig = mkOption {
              type = bool;
              default = false;
            };
          };
          utags = mkOption {
            type = listOf (enum (userTags ++ hostUserTags));
            default = [ ];
          };
          hasTag = mergeAttrsList (
            map (tag: {
              ${tag} = mkOption {
                type = bool;
                default = builtins.elem tag (config.tags ++ config.utags);
                readOnly = true;
              };
            }) (userTags ++ hostUserTags)
          );
          groups = mkOption {
            type = listOf (enum groups);
            default = [ ];
          };
          inGroup = mergeAttrsList (
            map (group: {
              ${group} = mkOption {
                type = bool;
                default = builtins.elem group config.groups;
                readOnly = true;
              };
            }) groups
          );
        };
      }
    );
in
{
  options = {
    hosts = mkOption {
      type = attrsOf (
        submodule (
          { config, ... }:
          {
            options = {
              name = mkOption {
                type = str;
              };
              kind = mkOption {
                type = enum hostKinds;
                description = "Categorized by function";
              };
              os = mkOption {
                type = enum oses;
              };
              system = mkOption {
                type = enum systems;
                default = "x86_64-linux";
              };
              gpu = mkOption {
                type = enum gpus;
              };
              users = mkOption {
                type = listOf (submodule hostUserOpts);
                default = [ ];
              };
              tags = mkOption {
                type = listOf (enum hostTags);
                default = [ ];
              };
              hasTag = mergeAttrsList (
                map (tag: {
                  ${tag} = mkOption {
                    type = bool;
                    default = builtins.elem tag config.tags;
                    readOnly = true;
                  };
                }) hostTags
              );
              equals = mkOption {
                type = functionTo bool;
                default = host: host.name == config.name;
                readOnly = true;
              };
              is = {
                headless = mkOption {
                  type = bool;
                  default = !config.hasTag.gui;
                  readOnly = true;
                };
                gui = mkOption {
                  type = bool;
                  default = config.hasTag.gui;
                  readOnly = true;
                };
              }
              // (mergeAttrsList (
                map (kind: {
                  ${kind} = mkOption {
                    type = bool;
                    default = config.kind == kind;
                    readOnly = true;
                  };
                }) hostKinds
              ))
              // (mergeAttrsList (
                map (os: {
                  ${os} = mkOption {
                    type = bool;
                    default = config.os == os;
                    readOnly = true;
                  };
                }) oses
              ))
              // (mergeAttrsList (
                map (gpu: {
                  ${gpu} = mkOption {
                    type = bool;
                    default = config.gpu == gpu;
                    readOnly = true;
                  };
                }) gpus
              ));
              data = mkOption {
                type = attrs;
                default = { };
              };
            };
          }
        )
      );
    };

    users = mkOption {
      type = attrsOf (submodule userOpts);
    };

    # derived / read-only

    systems = mkOption {
      type = listOf str;
      default = systems;
      readOnly = true;
    };

    hostNames = mkOption {
      type = listOf str;
      default = builtins.attrNames config.hosts;
      readOnly = true;
    };

    nixosHostNames = mkOption {
      type = listOf str;
      default = config.hosts |> filterAttrs (_: h: h.is.nixos) |> builtins.attrNames;
      readOnly = true;
    };

    userNames = mkOption {
      type = listOf str;
      default = builtins.attrNames config.users;
      readOnly = true;
    };

    userHostPairs = mkOption {
      type = listOf (submodule {
        options = {
          userName = mkOption { type = str; };
          hostName = mkOption { type = str; };
        };
      });
      default = flatten (
        mapAttrsToList (
          hostName: hostCfg:
          hostCfg.users
          |> map (user: user.name)
          |> map (userName: {
            inherit userName hostName;
          })
        ) config.hosts
      );
      readOnly = true;
    };
  };
}
