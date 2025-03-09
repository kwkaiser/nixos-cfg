{ pkgs, lib, config, ... }: {
  options = {
    mine.zsh.enable =
      lib.mkEnableOption "Whether or not to use zsh as a preferred shell";
    mine.node.enable =
      lib.mkEnableOption "Whether or not to use node as a preferred shell";
  };
  imports =
    [ ./kitty ./git ./neovim ./node ./zsh ./keepass ./syncthing ./cursor ];
}
