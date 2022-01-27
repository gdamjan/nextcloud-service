{ pkgs }:
let
  nextcloud = rec {
    version = "23.0.0";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256-w3WSq8O2XI/ShFkoGiT0FLh69S/IwuqXm+P5vnXQGiw=";
  };
  apps = [
    rec {
      name = "spreed";
      version = "13.0.2";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "1nzi4l5wcapywlcivzmjvfaqm8f9qzn3p657s0wgpmz5ffv3gsfk";
    }
    rec {
      name = "twofactor_totp";
      version = "6.2.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "03w0nnv7bp4h61yg9scb6l2hkpx7ihf0fqi5x4kq2p661dfax9dg";
    }
    rec {
      name = "twofactor_u2f";
      version = "6.3.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "0z1d7mm6fnaddgpalpjccbzyllkbrrx97z3adgx2f05j3qcd7ic9";
    }
  ];

in

pkgs.stdenv.mkDerivation rec {
  pname = "nextcloud";
  version = nextcloud.version;

  src = pkgs.fetchurl {
    url = nextcloud.url;
    sha256 = nextcloud.sha256;
  };

  additionalApps = map ({url, sha256, ...}: builtins.fetchurl {inherit url sha256;}) apps;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/
    cp -R . $out/

    ${pkgs.lib.concatMapStrings (app: ''
        tar xf ${app} -C $out/apps/
    '') additionalApps}

    runHook postInstall
  '';
}
