# TODO: -> NUR?? after figuring out how to pin ebsynth version
{
  lib,
  stdenv,
  fetchurl,
  # dependencies
  alsa-lib,
  ncurses,
  fftw,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ebsynth";
  version = "0.8h";

  # use finalAttrs.version
  src = fetchurl {
    url = "http://abelian.org/ebnaut/ebsynth.c";
    sha256 = "sha256-CnR6Apj4QCFkKhEL1IlX1KEINOB1dfoT53SAiTOWKmc=";
  };

  unpackPhase = ''
    cp $src ebsynth.c
  '';

  buildPhase = ''
    mkdir -p "$out"/bin
    gcc -std=gnu99 -Wall -O3 -o "$out"/bin/ebsynth ebsynth.c -lasound -lncurses -lfftw3 -lm -lpthread
  '';

  buildInputs = [
    alsa-lib
    ncurses
    fftw
  ];
})
