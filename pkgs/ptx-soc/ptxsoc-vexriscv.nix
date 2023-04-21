{ stdenv
, buildPythonPackage
, python
, pkgs
, lib
, litex-boards-vexriscv-split
}:

let
    gateware = (litex-boards-vexriscv-split.override { buildBitstream = true; });
    software = litex-boards-vexriscv-split;
in
buildPythonPackage rec {
  pname = "ptxsoc-vexriscv";
  version = "1.0";
  format = "other";

  unpackPhase = "true";

  nativeBuildInputs = [
    pkgs.trellis
  ];

  propagatedBuildInputs = [
    gateware
    software
  ];

  buildPhase = ''
    cp ${software}/software.init .
    cp ${gateware}/gateware.init .
    cp ${gateware}/gw/lambdaconcept_ecpix5.config ptxsoc-vexriscv.config

    ecpbram -v -i ptxsoc-vexriscv.config -o ptxsoc_vexriscv_update.config --from gateware.init --to software.init

    ecppack ptxsoc_vexriscv_update.config --svf ptxsoc.svf --bit ptxsoc.bit --bootaddr 0 --compress
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
