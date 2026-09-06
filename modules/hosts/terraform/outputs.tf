output "ipv4" {
  value = hcloud_server.homelab_vps.ipv4_address
}

output "install_command" {
  value = "nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake .#homelab-vps --target-host root@${hcloud_server.homelab_vps.ipv4_address} --phases kexec,disko,install"
}

output "install_command_no_disko" {
  value = "nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake .#homelab-vps --target-host root@${hcloud_server.homelab_vps.ipv4_address} --phases kexec,install"
}

output "nix_volume_device" {
  description = "Stable device path for the /nix volume, for use in disks.nix's LVM PV definition."
  value       = "/dev/disk/by-id/scsi-0HC_Volume_${hcloud_volume.nix.id}"
}
