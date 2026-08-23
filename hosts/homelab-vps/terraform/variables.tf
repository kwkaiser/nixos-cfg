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

variable "ssh_allow_list" {
  description = "CIDRs allowed to reach SSH/k3s API. Defaults to open - tighten this once you know your source IPs."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}
