import {
  to = tailscale_acl.policy
  id = "acl"
}

resource "tailscale_acl" "policy" {
  acl = jsonencode({
    tagOwners = {
      "tag:homelab" = ["autogroup:admin"]
    }

    grants = [
      {
        src = ["*"]
        dst = ["*"]
        ip  = ["*"]
      },
    ]

    ssh = [
      {
        action = "check"
        src    = ["autogroup:member"]
        dst    = ["autogroup:self"]
        users  = ["autogroup:nonroot", "root"]
      },
    ]
  })
}

data "tailscale_device" "managed" {
  for_each = var.devices

  hostname = each.key
}

resource "tailscale_device_tags" "managed" {
  for_each = var.devices

  device_id = data.tailscale_device.managed[each.key].node_id
  tags      = each.value.tags

  depends_on = [tailscale_acl.policy]
}

resource "tailscale_device_key" "managed" {
  for_each = var.devices

  device_id           = data.tailscale_device.managed[each.key].node_id
  key_expiry_disabled = true
}
