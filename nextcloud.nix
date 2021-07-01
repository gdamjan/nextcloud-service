{ pkgs }:
let
  nextcloud = {
    version = "21.0.2";
    sha256 = "1zhiamyj1vmvmhqb047cj03nrgpag12g4j6js9gxp19lk883hnsy";
  };
  apps = [
    rec {
      name = "spreed";
      version = "11.3.0";
      url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}-${version}.tar.gz";
      sha256 = "1hwq83iiz5lyc90sgd2l2p9lnxacnzdrd01a2my1wdd1mrgxd29i";
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
