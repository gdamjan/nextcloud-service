{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "nextcloud";
    version = "20.0.1";
    sha256 = "96c6b50e1e676e46cec82d8f8ff1abd5eef9dfa00580081b6c640612c3ff2efc";

    src = pkgs.fetchurl {
      url = "https://github.com/nextcloud/server/releases/download/v${version}/nextcloud-${version}.tar.bz2";
      sha256 = sha256;
    };

    installPhase = ''
      mkdir $out
      cp -ra * $out/
    '';
}
