{
  description = "nix-litex";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/master";
      flake-utils.url = "github:numtide/flake-utils";
      nix-environments.url = "github:nix-community/nix-environments";
    };


  outputs = { self, nixpkgs, flake-utils, nix-environments }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
           pkgs = import nixpkgs {
             inherit system;
             overlays = [ ];
           };
        in
        {
          devShell = import ./shell.nix {
            inherit pkgs;
          };
        }
      );
}
