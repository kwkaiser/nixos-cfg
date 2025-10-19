{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.chrome.enable = lib.mkEnableOption "Whether or not to use chrome";
  };

  config = lib.mkIf config.mine.chrome.enable {
    environment.systemPackages = with pkgs; [ chromium terraform ];
  };
}

/* *
   code -> aws cloudformation -> creating a template for services that we want
   aws cloudformation -> creates bullshit in cloud
*/
