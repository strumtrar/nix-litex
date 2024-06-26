# A nix-shell expression with the collection of build inputs for the
# various board expressions. Can be helpful when developing and
# debugging LiteX.

{ pkgs ? (import <nixpkgs> { }), enableVivado ? false, skipPkgChecks ? true }:

with pkgs;

let
  # import the litex package set and overlay it onto nixpkgs so we can
  # modify the packages inside it
  litexImport = (import ./pkgs { inherit pkgs; skipChecks = skipPkgChecks; });
  litexPkgs = (import pkgs.path {
    overlays = [
      litexImport.overlay

      (self: super: {
        maintenance = litexImport.maintenance;
      })
    ];
  });

in
pkgs.mkShell {
  name = "litex-shell";
  buildInputs = with litexPkgs; with litexPkgs.python3Packages; [
    migen
    openocd
    microcom

    litex
    litex-boards
    ptxsoc-vexriscv
    litedram
    liteeth
    liteiclink
    litescope
    litespi
    litepcie
    litehyperbus
    pythondata-cpu-vexriscv_smp
    pkgsCross.riscv64.buildPackages.gcc
    gnumake
    python3Packages.pyvcd
    openfpgaloader

    # For simulation
    pythondata-misc-tapcfg
    libevent
    json_c
    zlib
    verilator

    # For ECP5 bitstream builds
    yosys
    nextpnr
    icestorm
    trellis

    # For executing the maintenance scripts of this repository
    maintenance

    # For LiteX development
    python3Packages.pytest
    python3Packages.pytest-xdist
    python3Packages.pytest-subtests
  ] ++ (if enableVivado then [ (pkgs.callPackage ./pkgs/vivado { }) ] else [ ]);
}
