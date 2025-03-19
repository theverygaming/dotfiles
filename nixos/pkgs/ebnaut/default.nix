# TODO: -> NUR?? after figuring out how to pin ebnaut version
{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ebnaut";
  version = "1.1";

  # use finalAttrs.version
  src = fetchurl {
    url = "http://abelian.org/ebnaut/ebnaut.c";
    sha256 = "sha256-ZPV2bdQ2O+IDx9q3oVOpx8150EK6IvwRa3n0xREYS4s=";
  };

  unpackPhase = ''
    cp $src ebnaut.c
  '';

  buildPhase = ''
    mkdir -p "$out"/bin
    gcc -std=gnu99 -Wall -O3 -o "$out"/bin/ebnaut ebnaut.c -lm -lpthread
  '';
})
