{ mkModuleOption, ... }:
{
  options.nixos.modules.fail2ban = mkModuleOption { };

  config.nixos.modules.fail2ban = {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        maxtime = "168h";
      };
      ignoreIP = [
        "100.64.0.0/10"
        "10.42.0.0/16"
        "10.43.0.0/16"
        "10.100.0.0/24"
        "fd10:100::/64"
      ];
    };
  };
}
