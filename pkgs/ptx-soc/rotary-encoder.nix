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

  encoder = builtins.fetchurl {
      url = "https://github.com/pengutronix/meta-ptx-fpga/raw/next/recipes-synthesis/litex/rotary-encoder-1.0/encoder.v";
      sha256 = "sha256:0w8sdaj55ijfn6zyhq7vk9kw985bz9q0mjnygdaf9xfgic855sqy";
  };
  core = builtins.fetchurl {
      url = "https://github.com/pengutronix/meta-ptx-fpga/raw/next/recipes-synthesis/litex/rotary-encoder-1.0/core.py";
      sha256 = "sha256:1np612ic76yg3ck5r9j2jbhzfak8acqaj3whvchxj7cj06hgl24l";
  };

  unpackPhase = "true";

  nativeBuildInputs = [
  ];

  propagatedBuildInputs = [
  ];

  buildPhase = ''
  '';

  installPhase = ''
    mkdir -p $out/${pkgs.python3.sitePackages}/rotary_encoder/verilog
    cp $encoder $out/${pkgs.python3.sitePackages}/rotary_encoder/verilog/encoder.v
    cp $core $out/${pkgs.python3.sitePackages}/rotary_encoder/core.py
  '';
}
