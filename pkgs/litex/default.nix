pkgMeta:
{ lib
, buildPythonPackage
, fetchpatch
, pythondata-software-compiler_rt
, pythondata-software-picolibc
, pythondata-cpu-vexriscv
, pythondata-cpu-serv
, pythondata-misc-tapcfg
, pyserial
, migen
, requests
, colorama
, litedram
, liteeth
, liteiclink
, litescope
, pytest
, pexpect
, meson
, ninja
, pkgsCross
, verilator
, libevent
, json_c
, zlib
, zeromq
}:

buildPythonPackage rec {
  pname = "litex";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  patches = [
    ./0001-picolibc-allow-building-with-meson-0.57.patch
    # cores/cpu/vexriscv_smp: add default cores used by linux with l2 cache
    (fetchpatch {
      url = "https://github.com/enjoy-digital/litex/commit/1ce378e24db00dbbfe9a721fe14662f696cbfd2a.patch";
      hash = "sha256-4BxkBOJwfCQ0xL76MiMcOj85hHkYlQzf6z4Fmu84Iak=";
    })
    # cores/cpu/vexriscv_smp: define SYNTHESIS in Quartus
    (fetchpatch {
      url = "https://github.com/enjoy-digital/litex/commit/c2b62a6b0c527b86cc67831a45f183c92fc0a3aa.patch";
      hash = "sha256-R7McX6+EQqJUYNHKVU7MgQH/L16lceWcmLZC8gPEARc=";
    })
  ];

  propagatedBuildInputs = [
    # LLVM's compiler-rt data downloaded and importable as a python
    # package
    pythondata-software-compiler_rt

    # libc for the LiteX BIOS
    pythondata-software-picolibc

    # BIOS build tools. Must be propagated because LiteX will require
    # them to be in PATH when building any SoC with BIOS.
    meson
    ninja

    pyserial
    migen
    requests
    colorama
  ];

  checkInputs = [
    litedram
    liteeth
    liteiclink
    litescope
    pythondata-cpu-vexriscv
    pythondata-cpu-serv
    pythondata-misc-tapcfg
    pkgsCross.riscv64-embedded.buildPackages.gcc
    pexpect
    pytest

    # For Verilator simulation
    verilator
    libevent
    json_c
    zlib
    zeromq
  ];

  checkPhase = ''
    # The tests will try to execute the litex_sim command, which is
    # installed as part of this package. While $out is already added
    # to PYTHONPATH here, it isn't yet added to PATH.
    export PATH="$out/bin:$PATH"

    # This needs to be exported manually because checkInputs doesn't
    # propagate to these variables
    export NIX_CFLAGS_COMPILE=" \
      -isystem ${libevent.dev}/include \
      -isystem ${json_c.dev}/include \
      -isystem ${zlib.dev}/include \
      -isystem ${zeromq}/include \
      $NIX_CFLAGS_COMPILE"
    export NIX_LDFLAGS=" \
      -L${libevent}/lib \
      -L${json_c}/lib \
      -L${zlib}/lib \
      -L${zeromq}/lib \
      $NIX_LDFLAGS"

    # Only test CPU variants we actually package and want to support
    # as part of this repository
    pytest -v -k " \
      not test_vexriscv_smp \
      and not test_ibex \
      and not test_cv32e40p \
      and not test_femtorv \
      and not test_picorv32 \
      and not test_minerva \
    " test/
  '';

  doCheck = true;
}
