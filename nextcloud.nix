{ pkgs }:
let
  nextcloud = rec {
    version = "25.0.2";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:0nbxwdvk3ni4011f2nxm8drwkx0iy47mfprr8bd7p4q8l7x41ayn";
  };
  apps = [
    rec {
      name = "spreed";
      version = "15.0.2";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:0qrf68iq2pqf5ml9lrlbjdd8a4cn1fxhgm5lpybzxi8m710sy0hk";
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
