{ stdenv
, buildPythonPackage
, python
, pkgs
, lib
}:

buildPythonPackage rec {
  pname = "rotary-encoder";
  version = "1.0";
  format = "other";

  src = builtins.fetchGit ~/work/customers/ecpix.vexriscv/rotary-encoder;

  unpackPhase = "true";

  nativeBuildInputs = [
  ];

  propagatedBuildInputs = [
  ];

  buildPhase = ''
  '';

  installPhase = ''
    mkdir -p $out/${pkgs.python3.sitePackages}/rotary_encoder/verilog
    cp $src/encoder.v $out/${pkgs.python3.sitePackages}/rotary_encoder/verilog/
    cp $src/core.py $out/${pkgs.python3.sitePackages}/rotary_encoder/
  '';
}
