resource "hcloud_ssh_key" "homelab_vps" {
  for_each = { for idx, key in var.authorized_keys : tostring(idx) => key }

  name       = "${var.label}-${each.key}"
  public_key = each.value
}

resource "hcloud_firewall" "homelab_vps" {
  name = "${var.label}-fw"

  rule {
    description = "ssh"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = concat(var.ssh_allow_list_ipv4, var.ssh_allow_list_ipv6)
  }

  rule {
    description = "http"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "https"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "k3s-api"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = concat(var.ssh_allow_list_ipv4, var.ssh_allow_list_ipv6)
  }
}

resource "hcloud_server" "homelab_vps" {
  name        = var.label
  server_type = var.server_type
  image       = var.image
  location    = var.location

  ssh_keys     = [for k in hcloud_ssh_key.homelab_vps : k.id]
  firewall_ids = [hcloud_firewall.homelab_vps.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
