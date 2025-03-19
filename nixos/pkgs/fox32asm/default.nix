{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fox32asm";
  version = "0.3.0";
  useFetchCargoVendor = true;

  src = fetchFromGitHub {
    owner = "fox32-arch";
    repo = "fox32asm";
    rev = "bedf8d54c4e5d419b62532e392c5fc0954e82823";
    sha256 = "sha256-pv+TI5yp0ytQrkdD9tkzvLzx8aJ7JYT7lvON9jp3L9U=";
    leaveDotGit = true; # for vergen
  };

  cargoHash = "sha256-Ns6XXy+Nu1Nj/cRYt7bTWXCkHlFhgd/UIj83YE1sNHE=";
})
