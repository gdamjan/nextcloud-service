{ pkgs }:
let
  nextcloud = rec {
    version = "24.0.3";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:0f9444nmd661v8kdvga5zm3l78cnhn2wzspkrr5jp4h2p7wq231j";
  };
  apps = [
    rec {
      name = "spreed";
      version = "14.0.3";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:1vqdbr35jm1q9waic458kzwy1b7nf3c6qghw7da17nwpvy68ymgi";
    }
    rec {
      name = "twofactor_totp";
      version = "6.4.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:06j8af9pydmnjr6h349nk3gc47dr91364f3gqiy5kpvcrm36j6vi";
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
