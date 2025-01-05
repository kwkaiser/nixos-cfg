#! /bin/bash
rsync -aP kwkaiser@192.168.122.1:/home/kwkaiser/desktop/nix .

sudo nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko ./hosts/vm.nix

sudo nixos-install --flake .#vm

nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake .#vm --target-host root@

nix --experimental-features 'nix-command flakes' run github:serokell/deploy-rs -- .#vm --target-host