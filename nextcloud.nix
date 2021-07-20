{ pkgs }:
let
  nextcloud = {
    version = "22.0.0";
    sha256 = "0yjxpkniwyqiq4b0iw4sjyxvbwn02dsv7cpknp4sgb1p9isx649r";
  };
  apps = [
    rec {
      name = "spreed";
      version = "12.0.1";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-${version}.tar.gz";
      sha256 = "04dvq4nha86877yyhbvv2lq4xx0z4ymh5vx6mknmqmmn4xg3fmyl";
    }
    rec {
      name = "twofactor_totp";
      version = "6.1.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "18xqqjk08iz2a2n9l87v9siqllzqmr4ap9bp6p8xw3yn0m1zgp05";
    }
    rec {
      name = "twofactor_u2f";
      version = "6.2.0";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "0rry094wxbq2dsaasvybzavgyr6crhmc63gbkhigsfbn9af53qy8";
    }
  ];

in

pkgs.stdenv.mkDerivation rec {
  pname = "nextcloud";
  version = nextcloud.version;

  src = pkgs.fetchurl {
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = nextcloud.sha256;
  };

  additionalApps = map ({url, sha256, ...}: builtins.fetchurl {inherit url sha256;}) apps;

  installPhase = ''
    mkdir $out
    cp -ra * $out/

    ${pkgs.lib.concatMapStrings (app: ''
        tar xf ${app} -C $out/apps/
    '') additionalApps}
  '';
}
