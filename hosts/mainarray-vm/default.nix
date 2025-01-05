# default.nix
{ lib, config, pkgs, ... }:

let
  module1 = import ./disks.nix;
  module2 = import ./hardware.nix;

in { imports = [ module1 module2 ]; }
