variable "tailscale_oauth_client_id" {
  type = string
}

variable "tailscale_oauth_client_secret" {
  type      = string
  sensitive = true
}

variable "devices" {
  description = "Tailnet devices managed here, keyed by short hostname."
  type = map(object({
    tags = list(string)
  }))
  default = {
    homelab-vps = {
      tags = ["tag:homelab"]
    }
  }
}
