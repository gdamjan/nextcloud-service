{
  description =
    "Portable Nextcloud service run by uwsgi-php and built with Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      nixos = (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ];
      }).config.system.nixos;
      nextcloud = pkgs.nextcloud27;
      php = pkgs.php;
      uwsgi = pkgs.uwsgi;
    in {
      formatter.x86_64-linux = pkgs.nixfmt;
      packages.x86_64-linux.default = (import ./build.nix {
        inherit pkgs nextcloud php uwsgi;
        withSystemd = false;
      });
      packages.x86_64-linux.release-info = pkgs.writeText "release-info.txt" ''
        php: ${php.version}
        uwsgi: ${uwsgi.version}
        nextcloud: ${nextcloud.version}
        ${nixos.distroName} ${nixos.release} (${nixos.codeName})
        ${nixos.distroId} ${nixos.label}
      '';
    };
}
