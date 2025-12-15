{ flakeInputs, ... }:

import flakeInputs.nixpkgs {
  system = "aarch64-linux";
}
