{
  lib,
  rustPlatform,
  fetchgit,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sarracenia";
  version = "aa6982cc6554b279b2300c8885a0f9277fdb54e0";
  #useFetchCargoVendor = true;

  src = fetchgit {
    url = "https://git.softkittypa.ws/lea/sarracenia.git";
    rev = "${finalAttrs.version}";
    sha256 = "sha256-f7gwkXAI99IpP0/8WbjHSKEcVS+oDTEXIfnJhOTyjik=";
  };

  patches = [
    ./better_templating.patch
  ];

  cargoHash = "sha256-y38OXFyQdCFaM+cxOvTev8OsrlZT6k4/xGTw6E/vOx0=";

  installPhase = ''
    runHook preInstall

    install -Dm755 target/release/${pname} $out/bin/${pname}
  
    # TODO: actually copy the right files into the right paths
    mkdir -p $out/share/${pname}
    cp -r static $out/${pname}/

    runHook postInstall
  '';
})
