resource "linode_instance" "homelab_vps" {
  label           = var.label
  region          = var.region
  type            = var.instance_type
  image           = var.image
  authorized_keys = var.authorized_keys
  root_pass       = var.root_pass
}

resource "linode_instance_config" "homelab_vps" {
  linode_id   = linode_instance.homelab_vps.id
  label       = "direct-disk"
  kernel      = "linode/direct-disk"
  root_device = "/dev/sda"
  booted      = var.boot_into_direct_disk ? true : null

  device {
    device_name = "sda"
    disk_id     = [for d in linode_instance.homelab_vps.disk : d.id if d.filesystem != "swap"][0]
  }
  device {
    device_name = "sdb"
    disk_id     = [for d in linode_instance.homelab_vps.disk : d.id if d.filesystem == "swap"][0]
  }
}

resource "linode_firewall" "homelab_vps" {
  label = "${var.label}-fw"

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = var.ssh_allow_list_ipv4
    ipv6     = var.ssh_allow_list_ipv6
  }

  inbound {
    label    = "http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "k3s-api"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "6443"
    ipv4     = var.ssh_allow_list_ipv4
    ipv6     = var.ssh_allow_list_ipv6
  }

  linodes = [linode_instance.homelab_vps.id]
}
