output "ipv4" {
  value = tolist(linode_instance.homelab_vps.ipv4)[0]
}

output "install_command" {
  value = "nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake .#homelab-vps --target-host root@${tolist(linode_instance.homelab_vps.ipv4)[0]} --phases kexec,disko,install"
}

output "install_command_no_disko" {
  value = "nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake .#homelab-vps --target-host root@${tolist(linode_instance.homelab_vps.ipv4)[0]} --phases kexec,install"
}

output "boot_into_nixos_command" {
  value = "secretspec runx -- tofu apply -var boot_into_direct_disk=true"
}
