output "ipv4" {
  value = tolist(linode_instance.homelab_vps.ipv4)[0]
}

output "install_command" {
  value = "nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake .#homelab-vps --target-host root@${tolist(linode_instance.homelab_vps.ipv4)[0]}"
}
