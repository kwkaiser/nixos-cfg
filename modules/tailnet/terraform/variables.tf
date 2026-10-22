variable "tailscale_oauth_client_id" {
  type = string
}

variable "tailscale_oauth_client_secret" {
  type      = string
  sensitive = true
}

variable "devices" {
  description = "Tailnet devices managed here, keyed by short hostname. dns_domains are split-DNS domains this device resolves for the tailnet."
  type = map(object({
    tags        = list(string)
    dns_domains = optional(list(string), [])
  }))
  default = {
    homelab-vps = {
      tags        = ["tag:homelab"]
      dns_domains = ["kwkaiser.io"]
    }
  }
}
