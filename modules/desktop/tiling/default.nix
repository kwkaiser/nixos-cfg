{ pkgs, config, lib, inputs, isDarwin, ... }: {
  imports = (if isDarwin then [ ./darwin ] else [ ./nixos ]);
}
