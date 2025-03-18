{ home-manager, flakeInputs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { 
      inherit flakeInputs;
    };
  };
}
