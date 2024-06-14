default: ptxsoc

update:
    #!/usr/bin/env bash
    PWD="{{invocation_directory()}}"
    yes | ./maintenance/update_packages.py pkgs/litex_packages.toml
    git add pkgs/litex_packages.toml
    git commit -m "litex_packages: update `date`"

push:
    nix-store --query --references $(nix-instantiate shell.nix) | xargs nix-store --realise | xargs nix-store --query --requisites | cachix push strumtrar-litex

build-all:
    nix-build --arg skipChecks true --arg pkgs 'import <nixpkgs> {}' -A packages pkgs/default.nix | cachix push strumtrar-litex

ptxsoc:
    nix-build --arg skipChecks true  --keep-failed --arg pkgs 'import <nixpkgs> {}' --out-link deploy -A packages.ptxsoc-vexriscv pkgs/default.nix | cachix push strumtrar-litex

lb-vex:
    nix-build --arg skipChecks true --arg pkgs 'import <nixpkgs> {}' --out-link lb-vex -A packages.litex-boards-vexriscv pkgs/default.nix
    notify-send -i ~/repos/nixos/users/smull/cfg/x/builder.png 'lb-vex done'

lb-vex-start: lb-vex
    #!/usr/bin/env bash
    PWD="{{invocation_directory()}}"
    rsync -avz $PWD/lb-vex/gw/lambdaconcept_ecpix5.bit rlabA-srv:lambdaconcept_ecpix5.bit
    ssh rlabA-srv ./openFPGALoader lambdaconcept_ecpix5.bit

ptxsoc-start: ptxsoc
    #!/usr/bin/env bash
    PWD="{{invocation_directory()}}"
    sudo openFPGALoader -b ecpix5 $PWD/deploy/ptxsoc-vexriscv.bit

ptxsoc-start-dude06:
    #!/usr/bin/env bash
    PWD="{{invocation_directory()}}"
    rsync -avz dude06:/ptx/work/WORK_BOOME/str/YOCTO.BSP-Pengutronix-FPGA/build/tmp/deploy/images/ecpix5-vexriscv/ptxsoc.bit ptxsoc.bit
    sudo openFPGALoader -b ecpix5 ptxsoc.bit

ptxsoc-start-remote: ptxsoc
    #!/usr/bin/env bash
    PWD="{{invocation_directory()}}"
    rsync -avz $PWD/deploy/ptxsoc.bit rlabA-srv:ptxsoc.bit
    ssh rlabA-srv ./openFPGALoader ptxsoc.bit

litex-boards:
    nix-build --arg skipChecks true --arg pkgs 'import <nixpkgs> {}' --out-link litex-boards -A packages.litex-boards pkgs/default.nix

rsync:
    #!/usr/bin/env bash
    PWD="{{invocation_directory()}}"
    rsync -avz $PWD/deploy/ptxsoc.bit rlabA-srv:ptxsoc.bit
