{ pkgs }:
let
  nextcloud = rec {
    version = "22.2.0";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "07ryvynws65k42n6ca20nni1vqr90fsrd2dpx2bvh09mwhyblg97";
  };
  apps = [
    rec {
      name = "spreed";
      version = "12.2.1";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-${version}.tar.gz";
      sha256 = "0fbi76jckmp73w14g924i7p2x9jiby09gjmgim9l4sq2cvkb8cjr";
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
    url = nextcloud.url;
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
