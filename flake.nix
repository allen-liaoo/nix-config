{
  description = "NixOS Multi-Host & Multi-User Configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@args: {
    nixosConfigurations = {
      "vm" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          args.disko.nixosModules.disko
          ./configuration.nix
        ];
      };
    };
  };
}