/*
 * Creates a simple bastion host.
 */
resource "triton_firewall_rule" "inet-to-bastion" {
  rule = "FROM any TO tag role=bastion ALLOW tcp PORT 22"
  enabled = true
}

resource "triton_firewall_rule" "bastion-to-vms" {
  rule = "FROM tag role=bastion TO all vms ALLOW tcp PORT 22"
  enabled = true
}

resource "triton_machine" "bastion" {
  count = 1
  name = "bastion-${count.index}"
  package = "sample-128M"

  # Using minimal-64-lts
  image = "eb9fc1ea-e19a-11e5-bb27-8b954d8c125c"

  # User-script
  user_script = "${file("bastion-user-script.sh")}"

  tags = {
    role = "bastion"
    triton.cns.services = "bastion"
  }

  firewall_enabled = true
}
