{ pkgs }:
let
  nextcloud = rec {
    version = "24.0.0";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:101p2y677y7r38sk11kckprwyypbxfm3rpwvfns5yii01xibav0p";
  };
  apps = [
    rec {
      name = "spreed";
      version = "14.0.1";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:1n6ipfy1c7ddk1n03p15qp3x68d2y2r85icg0k7id85j884xvjw1";
    }
    rec {
      name = "twofactor_totp";
      version = "6.3.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "sha256:17c56fikfwvvhlvy19dpik9lyg7l92mwa54r2xk0msb9ygm3zk8c";
    }
    rec {
      name = "twofactor_u2f";
      version = "6.3.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "sha256:0z1d7mm6fnaddgpalpjccbzyllkbrrx97z3adgx2f05j3qcd7ic9";
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
