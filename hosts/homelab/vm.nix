{ config, pkgs, ... }: {
  virtualisation.vmVariantWithDisko = {
    hostForward = {
      "8080" = 80;
      "2222" = 22;
    };
  };
}
