variable "linode_token" {
  type      = string
  sensitive = true
}

variable "label" {
  type    = string
  default = "homelab-vps"
}

variable "region" {
  type    = string
  default = "us-east"
}

variable "image" {
  description = "Bootstrap image only - nixos-anywhere replaces this with NixOS."
  type        = string
  default     = "linode/debian12"
}

variable "instance_type" {
  description = "g6-standard-2 (4GB/2vCPU) is a reasonable starting point for auth+immich+news+sync+mealie; bump via -var if it's not enough."
  type        = string
  default     = "g6-standard-2"
}

variable "authorized_keys" {
  description = "SSH public keys allowed to reach the bootstrap image as root."
  type        = list(string)
}

variable "root_pass" {
  description = "Root password for the bootstrap image (Linode requires one even when using SSH keys)."
  type        = string
  sensitive   = true
}

variable "ssh_allow_list_ipv4" {
  description = "IPv4 CIDRs allowed to reach SSH/k3s API. Defaults to open - tighten this once you know your source IPs."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allow_list_ipv6" {
  description = "IPv6 CIDRs allowed to reach SSH/k3s API. Defaults to open - tighten this once you know your source IPs."
  type        = list(string)
  default     = ["::/0"]
}

variable "boot_into_direct_disk" {
  description = "Switches the instance's active boot config to direct-disk and reboots into it. Leave false until nixos-anywhere has installed NixOS (and its own GRUB) onto the disk - flipping this before then reboots into a disk with no bootloader on it yet."
  type        = bool
  default     = false
}
