{ config, pkgs, ... }: {
  programs.firefox = {
    enable = true;
    profiles = {
      kwkaiser = {
        extensions = [
          "ublock-filters"
          "ublock-badware"
          "ublock-privacy"
          "ublock-unbreak"
          "ublock-quick-fixes"
        ];
      };
    };
  };

}
