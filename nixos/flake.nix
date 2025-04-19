{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # this is kind of ass honestly
    secrets = {
      url = "git+ssh://git@github.com:/theverygaming/nixos-secrets.git?ref=main";
      flake = false;
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    {
      colmena =
        {
          meta = {
            nixpkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
            };
            specialArgs = {
              flakeInputs = inputs;
            };
          };
          defaults =
            { name, ... }:
            {
              imports = [
                ./modules/common
                ./modules/nixos
                ./pkgs/override.nix
                (./. + "/hosts/${name}")
                inputs.home-manager.nixosModules.home-manager
                inputs.disko.nixosModules.disko
                inputs.sops-nix.nixosModules.sops
                inputs.microvm.nixosModules.host
              ];
            };
        }
        // (
          with inputs.nixpkgs.lib;
          listToAttrs (
            map (x: nameValuePair x { }) (
              attrNames (filterAttrs (x: type: type == "directory") (builtins.readDir ./hosts))
            )
          )
        );
      colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;
      # nix run github:zhaofengli/colmena -- apply --on ... --experimental-flake-eval --verbose --show-trace

      nixosConfigurations = (inputs.colmena.lib.makeHive self.outputs.colmena).nodes;
    };
}
