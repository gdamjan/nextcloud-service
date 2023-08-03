{ stdenv
, lib
, fetchFromGitHub
}:

let
  pname = "nextcloud";
  version = "27.0.1";
  spreed_version = "17.0.3";

  nextcloud = {
    name = "nextcloud-server";
    owner= "nextcloud";
    repo = "server";
    rev = "refs/tags/v${version}";
    hash = "sha256-drnG7IJdyasj12Eje6JPw0avh0cilYYyiwSpJZNYf/c=";
  };
  apps = [
    {
      name = "spreed";
      owner= "nextcloud-releases";
      repo = "spreed";
      rev = "refs/tags/v${spreed_version}";
      hash = "sha256-1Km0SbRrFCs5Znk353/98pHWpJ+1pXthSB549lpuqwc=";
    }
  ];

in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchFromGitHub nextcloud;

  additionalApps = map fetchFromGitHub apps;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -R . $out/

    ${lib.concatMapStrings (app: ''
        ln -sT ${app} $out/apps/${app.name}
    '') additionalApps}

    runHook postInstall
  '';
  buildPhase = "true";
}
