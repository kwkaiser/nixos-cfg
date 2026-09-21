{ mkModuleOption, ... }:
let
  hmModule = { pkgs, ... }: {
    home.packages = with pkgs; [
      docker-compose
    ];
  };

  colimaHmModule = { pkgs, ... }: {
    home.packages = with pkgs; [
      colima
      docker-client
    ];

    home.file = {
      ".docker/cli-plugins/docker-compose" = {
        source = "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose";
        force = true;
      };
      ".docker/cli-plugins/docker-buildx" = {
        source = "${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx";
        force = true;
      };
    };
  };

  backendOption = { lib, ... }: {
    options.mine.docker.backend = lib.mkOption {
      type = lib.types.enum [ "docker-desktop" "colima" ];
      default = "docker-desktop";
      description = "Container runtime on Darwin. docker-desktop brings its own CLI and daemon via homebrew; colima installs the client from nixpkgs and leaves the VM to be started with `colima start`.";
    };
  };
in
{
  options.nixos.modules.docker = mkModuleOption { };
  options.darwin.modules.docker = mkModuleOption { };
  options.homeManager.modules.docker = mkModuleOption { };

  config.homeManager.modules.docker = hmModule;

  config.nixos.modules.docker = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        log-driver = "json-file";
      };
    };
    users.users.${config.mine.username}.extraGroups = [ "docker" ];
  };

  config.darwin.modules.docker =
    { config, lib, ... }:
    let
      useColima = config.mine.docker.backend == "colima";
    in
    {
      imports = [ backendOption ];
      home-manager.users.${config.mine.username}.imports = [
        hmModule
      ] ++ lib.optional useColima colimaHmModule;
      homebrew.casks = lib.mkIf (!useColima) [ "docker-desktop" ];
    };
}
