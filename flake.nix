{
  description = "NixOS Multi-Host & Multi-User Configuration";

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
      forEachSystem = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      mkPkgs =
        pkgs: system:
        import pkgs {
          inherit system;
          config.allowUnfree = true;
        };

      alnLib = import ./lib { inherit lib; };
      inventory = import ./inventory { inherit lib alnLib; };
      mkCtx = ctx: import ./ctx.nix ({ inherit lib inventory; } // ctx);
    in
    {
      nixosConfigurations = lib.genAttrs inventory.nixosHostNames (
        hostName:
        let
          host = inventory.hosts.${hostName};
          system = host.system;
        in
        lib.nixosSystem {
          specialArgs = {
            inherit inputs alnLib inventory;
            ctx = mkCtx { inherit hostName; };
          };
          system = system;
          modules = 
            (alnLib.importRecursive ./host/_modules)
            ++ (alnLib.importRecursive ./host/${hostName})
            ++ [
              inputs.disko.nixosModules.disko
              {
                _module.args = {
                  pkgs-unstable = mkPkgs inputs.nixpkgs-unstable system;
                };
              }
            ];
        }
      );

      homeConfigurations = lib.listToAttrs (
        map (
          { userName, hostName }:
          {
            name = "${userName}@${hostName}";
            value =
              let
                pkgs = inputs.nixpkgs.legacyPackages.${system}; # configure in modules
                system = inventory.hosts.${hostName}.system or inventory.systems.x86_linux;
              in
              inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = {
                  inherit inputs alnLib inventory;
                  ctx = mkCtx {
                    inherit hostName;
                    inherit userName;
                  };
                };
                modules =
                  (alnLib.importRecursive ./home/_modules)
                  ++ (alnLib.importRecursive ./home/${userName})
                  ++ [
                    {
                      _module.args = {
                        pkgs-unstable = mkPkgs inputs.nixpkgs-unstable system;
                        pkgs-nur = inputs.nur.legacyPackages.${system};
                        pkgs-aln = inputs.aln-packages.legacyPackages.${system};
                      };
                    }
                  ];
              };
          }
        ) inventory.userHostPairs
      );

      devShells = forEachSystem (system: import ./shell.nix { inherit inputs lib inventory; } system);
    };

  nixConfig = {
    extra-substituters = [ "https://vicinae.cachix.org" ];
    extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
  };

  inputs = {
    aln-packages = { 
      url = "github:allen-liaoo/aln-packages";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "home-manager"; # dependency not needed for use
      inputs.home-manager.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # my nixvim config
    nvimx = {
      url = "github:allen-liaoo/nvimx";
      #inputs.nixpkgs.follows = "nixpkgs-unstable"; # TODO: Wait til nixpkgs-unstable is on 26.11
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dont set nixpkgs.follows or cachix cache misses
    vicinae.url = "github:vicinaehq/vicinae";

    vicinae-extensions.url = "github:vicinaehq/extensions";

    xremap.url = "github:xremap/nix-flake";
  };
}
