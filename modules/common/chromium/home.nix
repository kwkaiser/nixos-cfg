{ config, pkgs, inputs, ... }: {
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "hdokiejnpimakedhajhdlcegeplioahd" # LastPass (alternative to KeePassXC)
      "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
      "fhbjgbiflinjbdggehcddcbncdddomop" # Redux DevTools
    ];
  };

  home.packages = with pkgs; [
    (writeScriptBin "chrome-dev" ''
      #!${bash}/bin/bash
      exec ${chromium}/bin/chromium --remote-debugging-port=9222 "$@"
    '')
  ];
}
