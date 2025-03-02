{ config, pkgs, inputs, ... }: {
  programs.firefox = {
    enable = true;
    profiles = {
      kwkaiser = {
        extensions = with inputs.firefox-addons.packages.${pkgs.system};
          [ ublock-origin ];
      };
    };
  };

}
