{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena.url = "github:zhaofengli/colmena";
  };

  outputs = inputs@{ self, ... }: {
    colmena = {
      meta = {
        nixpkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
        };
        specialArgs = {
          flakeInputs = inputs;
        };
      };
      defaults = { name, ... }: {
        imports = [
          ./modules/common
          ./modules/nixos
          (./. + "/hosts/${name}")
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    } // (with inputs.nixpkgs.lib; listToAttrs (map (x: nameValuePair x {}) (attrNames (filterAttrs (x: type: type == "directory") (builtins.readDir ./hosts)))));

    nixosConfigurations = (inputs.colmena.lib.makeHive self.colmena).nodes;
  };
}
