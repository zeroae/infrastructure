/*
 * Creates a simple bastion host.
 */
output "host" {
  value = "${triton_machine.bastion.primaryip}"
}
output "port" {
  value = "22"
}
output "user" {
  value = "admin"
}
output "private_network_id" {
  value = "${triton_machine.bastion.networks.1}"
}

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
  name = "bastion${count.index}"
  package = "sample-128M"

  # Using minimal-64-lts
  image = "eb9fc1ea-e19a-11e5-bb27-8b954d8c125c"

  firewall_enabled = true

  # User-script
  user_script = "${file("${path.module}/user-script.sh")}"

  tags {
    # TODO enable once hashicorp/terraform#2143 is implemented OR
    # Use zeroae/terraform:features/triton-cns branch.
    triton_cns_services = "bastion"
    env  = "prod"
    role = "bastion"
  }

  provisioner "local-exec" {
    command = "sed -E -e 's/BASTION_IP/${self.primaryip}/' \
               -e 's/TRITON_KEY_PATH/${var.triton_key_path}' \
               ${path.module}/ssh.config.in > ssh.config"
  }

}
