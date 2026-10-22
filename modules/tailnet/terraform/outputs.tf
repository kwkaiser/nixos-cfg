output "device_addresses" {
  description = "Tailnet IPs per managed device - the homelab-vps entry feeds nginx-private's externalIPs."
  value       = { for name, d in data.tailscale_device.managed : name => d.addresses }
}
