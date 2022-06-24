{ pkgs }:
let
  nextcloud = rec {
    version = "24.0.2";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:0g83wlabal0phhwvjngfa9ypxzfagn9nmi5y6qc25zsx4v0wmmih";
  };
  apps = [
    rec {
      name = "spreed";
      version = "14.0.2";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:1kf5hj10xr3vy4a0zd8ph0w5h9gw478jf8dcldl298qncpdhghdh";
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
