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

resource "triton_vlan" "bastion" {
  vlan_id = "${var.triton_vlan_id}"
  name = "bastion-VLAN"
}

resource "triton_fabric" "bastion" {
  name = "bastion-network"
  description = "bastion VPC"
  vlan_id = "${triton_vlan.bastion.vlan_id}"

  subnet = "10.0.0.0/22"
  gateway = "10.0.0.1"
  provision_start_ip = "10.0.0.5"
  provision_end_ip = "10.0.3.250"

  resolvers = ["8.8.8.8", "8.8.4.4"]
}

resource "triton_machine" "bastion" {
  count = 1
  name = "bastion${count.index}"
  package = "sample-128M"

  # Using minimal-64-lts
  image = "eb9fc1ea-e19a-11e5-bb27-8b954d8c125c"

  firewall_enabled = true

  nic {
    network = "${var.triton_network_public_id}"
  }
  nic {
    network = "${triton_fabric.bastion.id}"
  }

  # User-script
  user_script = "${file("${path.module}/scripts/user-script.sh")}"

  tags {
    # TODO enable once hashicorp/terraform#2143 is implemented OR
    # Use zeroae/terraform:features/triton-cns branch.
    triton_cns_services = "bastion"
    env  = "prod"
    role = "bastion"
  }

  provisioner "local-exec" {
    command = "cp ${path.module}/templates/ssh.config.in ${path.root}/ssh.config"
  }
  provisioner "local-exec" {
    command = "sed -E -e 's|\\$\\{bastion_host\\}|${self.primaryip}|' -i '' ${path.root}/ssh.config"
  }
  provisioner "local-exec" {
    command = "sed -E -e 's|\\$\\{triton_key_path\\}|${var.triton_key_path}|' -i '' ${path.root}/ssh.config"
  }
}
