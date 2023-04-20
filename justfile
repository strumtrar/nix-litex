default: ptxsoc

push:
    nix-store --query --references $(nix-instantiate shell.nix) | xargs nix-store --realise | xargs nix-store --query --requisites | cachix push strumtrar-litex

build-all:
    nix-build --arg skipChecks true --arg pkgs 'import <nixpkgs> {}' -A packages pkgs/default.nix | cachix push strumtrar-litex

ptxsoc:
    nix-build --arg skipChecks true --arg pkgs 'import <nixpkgs> {}' --out-link deploy -A packages.ptxsoc-vexriscv pkgs/default.nix
    notify-send -i ~/repos/nixos/users/smull/cfg/x/builder.png 'ptxsoc done'

lb-vex:
    nix-build --arg skipChecks true --arg pkgs 'import <nixpkgs> {}' --out-link lb-vex -A packages.litex-boards-vexriscv pkgs/default.nix
    notify-send -i ~/repos/nixos/users/smull/cfg/x/builder.png 'lb-vex done'

litex-boards:
    nix-build --arg skipChecks true --arg pkgs 'import <nixpkgs> {}' --out-link litex-boards -A packages.litex-boards pkgs/default.nix

rsync:
    #!/usr/bin/env bash
    PWD="{{invocation_directory()}}"
    rsync -avz $PWD/deploy/ptxsoc.bit rlabA-srv:ptxsoc.bit