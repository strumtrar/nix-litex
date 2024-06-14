{
  description = "nix-litex";

  inputs =
    {
      nixpkgs.url = "gitub:nixos/nixpkgs/master";
      flake-utils.url = "github:numtide/flake-utils";
      nix-environments.url = "github:nix-community/nix-environments";
      davepkgs.url = "github:danderson/nixpkgs/openfpgaloader";
    };


  outputs = { self, nixpkgs, flake-utils, nix-environments, davepkgs }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
           pkgs = import nixpkgs {
             inherit system;
             overlays = [ ];
           };
           dave = davepkgs.legacyPackages.${system};
        in
        {
          devShell = import ./shell.nix {
            inherit pkgs;
          };
        }
      );
}
