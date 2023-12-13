{
  description = ''Portable Nextcloud service run by uwsgi-php and built with Nix'';

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      packages.x86_64-linux.default = (import ./build.nix { inherit pkgs; withSystemd = false; });
    };
}
