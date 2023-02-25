{ pkgs }:
let
  nextcloud = rec {
    version = "25.0.4";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:19m1d7l0z6vh8vvhzcr6lxwjl21k7cpkb2wqsvi06hx9hc01w9f3";
  };
  apps = [
    rec {
      name = "spreed";
      version = "15.0.4";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:10ss1c7sb28f62mykz9xlk8gb2r8d56919wvq87650v71yqyqb98";
    }
  ];

in

pkgs.stdenv.mkDerivation rec {
  pname = "nextcloud";
  version = nextcloud.version;

  src = builtins.fetchurl { inherit (nextcloud) url sha256; };

  additionalApps = map ({url, sha256, ...}: builtins.fetchurl { inherit url sha256; }) apps;

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
