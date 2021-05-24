{ pkgs }:
let
  nextcloud = {
    version = "21.0.2";
    sha256 = "1zhiamyj1vmvmhqb047cj03nrgpag12g4j6js9gxp19lk883hnsy";
  };
  apps = [
    rec {
      name = "spreed";
      version = "11.2.1";
      url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}-${version}.tar.gz";
      sha256 = "1g10v8h66yd4xk59fwf8rzayr4zhs6zmi35vmc6mxrdnr1qjwxkx";
    }
    rec {
      name = "twofactor_totp";
      version = "6.0.0";
      url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "086qpyn4hqx9zyqrs0b9js7lz6wzq6nyrq2ca5yrdijsh9flrxi9";
    }
    rec {
      name = "twofactor_u2f";
      version = "6.1.0";
      url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "0qn0qzr9ngnwaxacbi5vk8ibkxy73da0xbfmr07qndb06p6mrga0";
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
