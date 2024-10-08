# TODO: -> nixpkgs
{ config, pkgs, ... }:

{
  environment.systemPackages =
    let
      satdump = with pkgs;
        stdenv.mkDerivation rec {
          pname = "satdump";
          version = "1.2.0";

          src = fetchgit {
            url = "https://github.com/SatDump/SatDump.git";
            rev = version;
            sha256 = "sha256-QGegi5/geL5U3/ecc3hsdW+gp25UE9fOYVLFJUo/N50=";
          };

          nativeBuildInputs = [ cmake pkg-config ];
          buildInputs = [
            # required deps
            fftwFloat
            libpng
            libtiff
            jemalloc
            volk
            (nng.overrideAttrs (old: {
              cmakeFlags = old.cmakeFlags ++ [ "-DBUILD_SHARED_LIBS=ON" ];
            }))
            rtl-sdr-librtlsdr
            hackrf
            airspy
            airspyhf
            glfw
            zenity
            zstd

            # optional hw support
            libad9361
            libiio
          ];

          cmakeFlags = [
            "-DCMAKE_BUILD_TYPE=Release"
          ];
        };
    in
    [ satdump ];
}
