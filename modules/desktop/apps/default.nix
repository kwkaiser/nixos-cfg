{ pkgs, config, lib, inputs, isDarwin, ... }: {
  imports = (if isDarwin then [ ./darwin ./common ] else [ ./nixos ./common ]);
}

