{ pkgs }:
let
  nextcloud = rec {
    version = "26.0.0";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:0g8c1mxdmjhmlmgqp9yffgqd8vkmysdjbmawrdp3dsdfcc1iaqzi";
  };
  apps = [
    rec {
      name = "spreed";
      version = "16.0.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:0difhw865vpf020c5yvxsw699glayyf77a8xvlwlnnzr1v3wpfx6";
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
