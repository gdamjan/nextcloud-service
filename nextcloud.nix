{ pkgs }:
let
  nextcloud = rec {
    version = "24.0.4";
    url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
    sha256 = "sha256:13n2d9nls5g5jxhw8ihyqavyxry7kd7q8k50haw3s68wirpl41yi";
  };
  apps = [
    rec {
      name = "spreed";
      version = "14.0.4";
      url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
      sha256 = "sha256:0286dljkp1dzn12yx9xnjl4z0zldfy6azyakisc4hri6prny1jnp";
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
