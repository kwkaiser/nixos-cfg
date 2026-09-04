{
  mkNixosSystem,
  lib,
  ...
}@topArgs:
{
  flake.nixosConfigurations.desktop = mkNixosSystem (
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports =
        with topArgs.config.nixos.modules;
        [
          identity
          base
          git
          nix-settings
          stylix
          timezone
          vm-testing

          chrome
          waybar
          swaync
          gthumb
          hyprland
          kitty
          syncthing
          rofi
          zsh
          keepass
          firefox
          messaging
          gtk
          steam
          pathofbuilding
          notes
          ssh
          docker
          sunshine
          spotify
          neovim
          python
          remote-unlock
          keyring
          secretspec
          homelab-hosts-file
          misc-cli-util
          tmux
          work
          claude
          anki
          zotero
          tf2
        ]
        ++ [
          ./_desktop/disks.nix
          ./_desktop/boot.nix
          ./_desktop/hardware.nix
          ./_desktop/net.nix
          ./_desktop/vm.nix
        ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      system.stateVersion = "25.05";

      programs.nix-ld.enable = true;
      systemd.tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
      ];

      mine.waybar.primaryMonitor = "DP-1";
      mine.waybar.secondaryMonitor = "DP-2";
      mine.syncthing.deviceName = "desktop";
      mine.remoteUnlock.requiredKernelModules = [ "igb" ];
      mine.remoteUnlock.ethDevice = "enp8s0";
      mine.tf2.customPath = "/home/kwkaiser/data/steam/steamapps/common/Team Fortress 2/tf/custom";
      mine.tf2.rayshud.enable = true;
      mine.tf2.hitsound.enable = true;

      # stylix's dconf integration only makes sense with a desktop session -
      # this is the only nixos host that imports hyprland.
      home-manager.users.${config.mine.username}.dconf.enable = lib.mkDefault true;
    }
  );
}
