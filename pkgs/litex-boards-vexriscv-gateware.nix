{ stdenv
, pkgs
, lib
, litex
, litex-boards
, pythondata-cpu-vexriscv_smp
, migen
}:

stdenv.mkDerivation rec {
  pname = "litex-boards-vexriscv-gateware";
  version = "1.0";

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

  buildInputs = [
    litex
    litex-boards
    pythondata-cpu-vexriscv_smp
    pkgs.yosys
    pkgs.nextpnr
  ];

  buildPhase = ''
    ./ptx_ecpix5.py \
      --no-compile-software \
      --output-dir=/tmp/ptx_ecpix5 \
      --gateware-dir=/tmp/ptx_ecpix5/gw \
      --cpu-type vexriscv_smp \
      --cpu-variant linux \
      --sys-clk-freq 50e6 \
      --l2-size 2048 \
      --with-ethernet \
      --with-wishbone-memory \
      --with-sdcard \
      --csr-json build/csr.json
  '';
}
