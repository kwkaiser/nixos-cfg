{mkModuleOption, ...}: let
  mkHomeModule = {
    flakeHost,
    isDarwin,
  }: {pkgs, ...}: {
    home.packages = with pkgs; [
      fzf
      nix-search-tv

      (writeShellScriptBin "ns" ''
        nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history
      '')

      (writeShellScriptBin "update" ''
        cd ~/Documents/nixos-cfg && git pl && nix flake update && git commit --all --message "update flake" && git ps
      '')

      (writeShellScriptBin "cleanup" ''
        nix-collect-garbage -d && sudo nix-collect-garbage -d
      '')

      (writeShellScriptBin "upgrade" ''
        cd ~/Documents/nixos-cfg
        ${
          if isDarwin
          then "sudo nix run nix-darwin -- switch --flake .#${flakeHost}"
          else "sudo nixos-rebuild switch --flake .#${flakeHost}"
        }
      '')
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # Declared here (rather than in ./builder.nix) so they're visible on every
  # host, including darwin clients that never import ./builder.nix itself.
  builderOptions = {lib, ...}: {
    options.mine.builder = {
      enable =
        lib.mkEnableOption "use of the nix remote builder as a build machine and substituter for this host"
        // {default = true;};
      hostName = lib.mkOption {
        type = lib.types.str;
        default = "kwkaiser.io";
        description = "SSH hostname clients use to reach the nix remote builder.";
      };
      sshUser = lib.mkOption {
        type = lib.types.str;
        default = "nixbuilder";
        description = "SSH user clients connect as to reach the nix remote builder.";
      };
      publicKey = lib.mkOption {
        type = lib.types.str;
        default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJmeeD/NBdZPSs5Frh+jgmt0eHabG3d2F2s1pFtwsVj nix-remote-build-homelab-vps";
        description = "Public half of the dedicated remote-build keypair (private half lives in secretspec as NIX_BUILDER_KEY, installed on clients via `task install-nix-build-key`).";
      };
      publicHostKey = lib.mkOption {
        type = lib.types.str;
        default = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUJqZzMvdGdJUlJ3dlV4M1NZQmd6YmJDQVgzUUNkd1Q5NVdsNzNsZTRlUG4=";
        description = "Base64-encoded SSH host public key of the remote builder (its `/etc/ssh/ssh_host_ed25519_key.pub`), so clients trust it without needing an entry in root's known_hosts.";
      };
    };
    options.mine.isBuilder = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this host is the nix remote builder itself (excludes it from its own remote-build machine list). Set true alongside importing ./builder.nix.";
    };
  };

  mkRemoteBuild = {
    config,
    lib,
    ...
  }: let
    enabled = config.mine.builder.enable && !config.mine.isBuilder;
  in {
    inherit enabled;

    remoteBuildMachines = lib.optionals enabled [
      {
        hostName = config.mine.builder.hostName;
        sshUser = config.mine.builder.sshUser;
        sshKey = "/etc/nix/build-keys/builder";
        publicHostKey = config.mine.builder.publicHostKey;
        protocol = "ssh-ng";
        systems = ["x86_64-linux"];
        maxJobs = 2;
        speedFactor = 1;
      }
    ];
    remoteSubstituters = lib.optionals enabled [
      "ssh-ng://${config.mine.builder.sshUser}@${config.mine.builder.hostName}?ssh-key=/etc/nix/build-keys/builder&base64-ssh-public-host-key=${config.mine.builder.publicHostKey}&trusted=true"
    ];
  };
in {
  options.nixos.modules.nix-settings = mkModuleOption {};
  options.darwin.modules.nix-settings = mkModuleOption {};

  config.nixos.modules.nix-settings = {
    config,
    lib,
    pkgs,
    ...
  }: let
    remote = mkRemoteBuild {inherit config lib;};
  in {
    imports = [builderOptions];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = _: true;
    environment.systemPackages = [pkgs.nixfmt];
    home-manager.users.${config.mine.username}.imports = [
      (mkHomeModule {
        flakeHost = config.mine.flakeHost;
        isDarwin = false;
      })
    ];

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 3d";
      };
      optimise = {
        automatic = true;
        persistent = true;
      };
      distributedBuilds = remote.enabled;
      buildMachines = remote.remoteBuildMachines;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        builders-use-substitutes = true;
        extra-substituters = remote.remoteSubstituters;
      };
    };
  };

  config.darwin.modules.nix-settings = {
    config,
    lib,
    pkgs,
    ...
  }: let
    remote = mkRemoteBuild {inherit config lib;};
  in {
    imports = [builderOptions];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = _: true;
    environment.systemPackages = [pkgs.nixfmt];
    home-manager.users.${config.mine.username}.imports = [
      (mkHomeModule {
        flakeHost = config.mine.flakeHost;
        isDarwin = true;
      })
    ];

    nix = {
      enable = true;
      optimise.automatic = true;
      gc = {
        automatic = true;
        options = "--delete-older-than 3d";
      };
      linux-builder = {
        enable = false;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        ephemeral = true;
        maxJobs = 6;
        config = {
          virtualisation = {
            cores = 6;
            darwin-builder = {
              diskSize = 30 * 1024;
              memorySize = 6 * 1024;
            };
          };
          # We have to emulate aarch64 on x86 qemu, see https://github.com/golang/go/issues/69255
          # boot.binfmt.emulatedSystems = ["x86_64-linux"];
        };
      };
      distributedBuilds = remote.enabled;
      buildMachines = remote.remoteBuildMachines;
      settings = {
        trusted-users = [
          "@admin"
          "kwkaiser"
          "root"
          "kkaiser"
        ];
        extra-trusted-users = [
          "@admin"
          "kwkaiser"
          "root"
          "kkaiser"
        ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        builders-use-substitutes = true;
        extra-substituters = remote.remoteSubstituters;
      };
    };
  };
}
