# TODO: -> nixpkgs
{ config, pkgs, ... }:

{
  environment.systemPackages =
    let
      satdump = with pkgs;
        stdenv.mkDerivation rec {
          pname = "satdump";
          version = "1.2.2";

          src = fetchgit {
            url = "https://github.com/SatDump/SatDump.git";
            rev = version;
            sha256 = "sha256-RRh0uk8auY/1z6oThq1sJlo0ruxm5gtpghb1YGAyDZw=";
          };

          patches = [ ./cmake-fix.patch ];

          nativeBuildInputs = [ cmake pkg-config ];
          buildInputs = [
            # required dependencies
            fftwFloat
            libpng
            libtiff
            jemalloc
            volk
            (nng.overrideAttrs (old: {
              cmakeFlags = old.cmakeFlags ++ [ "-DBUILD_SHARED_LIBS=ON" ];
            }))
            curl

            zstd # for ZIQ Recording compression

            # GUI dependencies
            glfw
            zenity

            # TODO: audio output - portaudio
            # TODO: libhdf5
            # TODO: opencl stuff?

            # All libraries required for live processing
            rtl-sdr-librtlsdr
            hackrf
            airspy
            airspyhf

            # for AD9361 hardware
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
