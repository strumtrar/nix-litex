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

  dontPatchELF = true;
  dontFixup = true;
  dontStrip = true;

  nativeBuildInputs = [
    pkgs.trellis
  ];

  propagatedBuildInputs = [
    gateware
    software
  ];

  buildPhase = ''
    cp ${software}/sw/bios.init bios.init
    cp -r ${gateware}/* .

    ${pkgs.trellis}/bin/ecpbram -v -i gw/lambdaconcept_ecpix5.config -o lambdaconcept_ecpix5_update.config --from gw/included.init --to bios.init

    ${pkgs.trellis}/bin/ecppack lambdaconcept_ecpix5_update.config --svf ptxsoc-vexriscv.svf --bit ptxsoc-vexriscv.bit --bootaddr 0
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
