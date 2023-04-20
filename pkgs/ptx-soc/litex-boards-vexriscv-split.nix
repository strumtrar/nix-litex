{ stdenv
, buildPythonPackage
, python
, pkgs
, pkgsCross
, lib
, litex
, litex-boards
, yosys
, nextpnr
, trellis
, meson
, ninja
, pythondata-cpu-vexriscv_smp
, buildBitstream ? false
}:

buildPythonPackage rec {
  pname = "litex-boards-vexriscv-split";
  version = "1.0";
  format = "other";

  #src = builtins.fetchurl {
  #    url = "https://github.com/pengutronix/meta-ptx-fpga/raw/master/recipes-synthesis/litex/litex-boards-vexriscv-gateware-1.0/ptx_ecpix5.py";
  #    sha256 = "0ifj2iw12qcc2c0yryjlxizsgq9hkdb1jpqc64p52xkzxiygflml";
  #};

  #unpackPhase = ''
  #  for srcFile in $src; do
  #    cp $srcFile $(stripHash $srcFile)
  #    chmod +x $(stripHash $srcFile)
  #  done
  #'';

  src = builtins.fetchGit ~/work/customers/ecpix5.vexriscv/ptx_ecpix5;
  unpackPhase = ''
     cp $src/ptx_ecpix5.py $(stripHash ptx_ecpix5.py)
     chmod +x $(stripHash ptx_ecpix5.py)
  '';

  nativeBuildInputs = [
    trellis
    yosys
    nextpnr
    meson
    ninja
    pkgsCross.riscv32-embedded.buildPackages.gcc
    pkgsCross.riscv64-embedded.buildPackages.gcc
  ];

  propagatedBuildInputs = [
    litex
    litex-boards
    pythondata-cpu-vexriscv_smp
  ];

  buildPhase = (builtins.concatStringsSep " " ([
    "${pkgs.python310}/bin/python3 ./ptx_ecpix5.py"
    "--output-dir=$out"
    "--cpu-type vexriscv_smp"
    "--cpu-variant linux"
    "--sys-clk-freq 50e6"
    "--l2-size 2048"
    "--with-ethernet"
    "--with-sdcard"
    "--csr-json $out/csr.json"
  ]) +
   (if buildBitstream then
       " --build --no-compile-software --gateware-dir=$out/gw"
    else
       " --no-compile-gateware --gateware-dir=$out/sw"
   ) +
   (if buildBitstream then
      " && ${litex}/bin/litex_json2dts_linux --root-device mmcblk0p2 --initrd disabled $out/csr.json > $out/litex-vexriscv-ecpix5.dts"
    else
      " ")
  );

  installPhase = 
    (if buildBitstream then
        "cp $out/gw/mem.init $out/gateware.init"
    else
        "cp $out/sw/mem.init $out/software.init");
}
