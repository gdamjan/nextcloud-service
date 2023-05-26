{ pkgs }:
let
  nextcloud = rec {
    version = "26.0.1";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:0j2gnsr9fd5wazx5q72ksjxdlsjzar13mmvksi5azj6p9096m73g";
  };
  apps = [
    rec {
      name = "spreed";
      version = "16.0.4";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:09qkj42nnklglm67fvmrcr7nh5xsv92a66a7jkpsirjgjnqkqrxw";
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
