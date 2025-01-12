{ config, pkgs, ... }: {
  # Packages installed on all systems
  environment.systemPackages = with pkgs; [ git jq fzf ];
}
