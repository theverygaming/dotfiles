{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #plasma-manager = {
    #  url = "github:pjones/plasma-manager";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.home-manager.follows = "home-manager";
    #};
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, /* plasma-manager, */ ... }: {
    nixosModules = {};
    nixosConfigurations = {
      "foxnix" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = with self.nixosModules; [
          home-manager.nixosModules.home-manager
          ./machines/foxnix
        ];
      };
      "foxportable" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = with self.nixosModules; [
          home-manager.nixosModules.home-manager
          ./machines/foxportable
        ];
      };
      "macintosh" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = with self.nixosModules; [
          home-manager.nixosModules.home-manager
          ./configs/i3.nix
          ./machines/macintosh
        ];
      };
    };
  };
}
