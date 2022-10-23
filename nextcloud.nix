{ pkgs }:
let
  nextcloud = rec {
    version = "25.0.0";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:0083mydqw0lfd4rcqgmh2ww9mx87gvwbpz8551r7wzm4h2czyvdj";
  };
  apps = [
    rec {
      name = "spreed";
      version = "15.0.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:1nwxkb3zrn1ygavxsrzr8mqz8njpcn2v0f71sjrjcn0v2xi023n2";
    }
    rec {
      name = "twofactor_totp";
      version = "6.4.1";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:1qh0zv5hahw6if0k5jkv6i7s5ks38cgf1in418qr5vv9vbm8zbar";
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
