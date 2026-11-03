{ mkModuleOption, ... }:
{
  options.nixos.modules.sftp-browser = mkModuleOption { };
  options.darwin.modules.sftp-browser = mkModuleOption { };

  config.nixos.modules.sftp-browser = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [
      ({ pkgs, ... }: { home.packages = [ pkgs.filezilla ]; })
    ];
  };

  config.darwin.modules.sftp-browser = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [
      ({ pkgs, ... }: { home.packages = [ pkgs.cyberduck ]; })
    ];
  };
}
