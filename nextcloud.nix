{ pkgs }:
let
  nextcloud = rec {
    version = "25.0.3";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:1v00bji3wp9q3flcgh879siqgbacq9hlzqkg15lj9ybffcii8asb";
  };
  apps = [
    rec {
      name = "spreed";
      version = "15.0.3";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:016yl2w8fla3mxkykrnb4nlsjciayikgrxwqp5qfzz6jycsl6kyj";
    }
  ];

in

pkgs.stdenv.mkDerivation rec {
  pname = "nextcloud";
  version = nextcloud.version;

  src = builtins.fetchurl {
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
