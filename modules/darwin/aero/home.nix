{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  home.file.".config/google-chrome/NativeMessagingHosts/com.google.chrome.keybindings.json".text =
    ''
      {
        "keybindings": {
          "Ctrl+T": "new-tab",
          "Ctrl+W": "close-tab",
          "Ctrl+Tab": "next-tab",
          "Ctrl+Shift+Tab": "previous-tab",
          "Ctrl+N": "new-window",
          "Ctrl+Shift+N": "new-incognito-window",
          "Ctrl+F": "find",
          "Ctrl+G": "find-next",
          "Ctrl+Shift+G": "find-previous",
          "Ctrl+1": "select-tab-1",
          "Ctrl+2": "select-tab-2",
          "Ctrl+3": "select-tab-3",
          "Ctrl+4": "select-tab-4",
          "Ctrl+5": "select-tab-5",
          "Ctrl+6": "select-tab-6",
          "Ctrl+7": "select-tab-7",
          "Ctrl+8": "select-tab-8",
          "Ctrl+9": "last-tab"
        }
      }
    '';
}
