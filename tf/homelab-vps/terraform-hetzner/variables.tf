variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "label" {
  type    = string
  default = "homelab-vps"
}

variable "location" {
  description = "Hetzner datacenter region. cx33 is only offered in fsn1/nbg1 (Germany) and hel1 (Finland) - not in either US location (ash/hil)."
  type        = string
  default     = "fsn1"
}

variable "image" {
  description = "Bootstrap image only - nixos-anywhere replaces this with NixOS."
  type        = string
  default     = "debian-12"
}

variable "server_type" {
  description = "Hetzner server type (plan). Bump via -var if it's not enough."
  type        = string
  default     = "cx33"
}

variable "authorized_keys" {
  description = "SSH public keys allowed to reach the bootstrap image (and, afterward, NixOS) as root. Unlike Linode, Hetzner needs no separate root password when SSH keys are provided."
  type        = list(string)
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
