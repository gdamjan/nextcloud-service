{ pkgs }:
let
  nextcloud = {
    version = "20.0.7";
    sha256 = "8ced82b772bf0af67d5be1323e40f977429bc0a2bcc864095efc78767500b72b";
  };
  apps = [
    rec {
      name = "spreed";
      version = "10.1.0";
      url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}-${version}.tar.gz";
      sha256 = "1a58dy3wr0d13162rcg7dyn1n2xmmxkdgghfzd9bwn3wy1w76skl";
    }
    rec {
      name = "twofactor_totp";
      version = "5.0.0";
      url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "1qwdqqy58csp5nsgjw312gji005pbwfplidygccrxvm6aazlskvh";
    }
    rec {
      name = "twofactor_u2f";
      version = "6.0.0";
      url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
      sha256 = "1zhay3nfmqpa2rdq5r3r81dxrnl92x7mzid1xfhp5bg0qf2qj3kw";
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
