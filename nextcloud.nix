{ pkgs }:
let
  nextcloud = rec {
    version = "27.0.0";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:0gsklrdmihzsnr8p4x0x1wghpkzkkc2v9mwdfmcc0nilp44jlc9x";
  };
  apps = [
    rec {
      name = "spreed";
      version = "17.0.1";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:16vh84wcklclv4xzwfim7sa933b0frgykzsqpn6m2s1qyfc6srdg";
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
