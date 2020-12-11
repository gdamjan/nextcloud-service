{ pkgs }:
let
  apps = [
    rec {
      name = "spreed";
      version = "10.0.3";
      url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}-${version}.tar.gz";
      sha256 = "1j4dgincsp1ngdxa0h416f5b88mnsjjqr54vw366514d7cn360js";
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
  version = "20.0.3";
  sha256 = "e0f64504d338f64d3c677357f0012cf8b0ed0dc42ec08f958b6dc4ff70edf175";

  src = pkgs.fetchurl {
    url = "https://github.com/nextcloud/server/releases/download/v${version}/nextcloud-${version}.tar.bz2";
    sha256 = sha256;
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
