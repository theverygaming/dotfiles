# TODO: -> NUR??
{
  lib,
  stdenv,
  fetchurl,
  # dependencies
  ncurses,
  libshout,
  flac,
  libsamplerate,
  fftw,
  libpng,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vlfrx-tools";
  version = "0.9p";

  src = fetchurl {
    url = "http://abelian.org/vlfrx-tools/vlfrx-tools-${finalAttrs.version}.tgz";
    sha256 = "sha256-tq9k1tnP6bmkqOdY1OkXqzvowRkEu71OC9D/vLPyjtc=";
  };

  buildInputs = [
    ncurses
    libshout
    flac
    libsamplerate
    fftw
    libpng
  ];
  configureFlags = [
    # requires xforms which is not in nixpkgs and i did not feel like packaging it after a failed attempt
    "--without-x11"
  ];
})
