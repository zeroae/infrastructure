/*
 * Creates a pkgbuild host.
 */
resource "triton_firewall_rule" "vm-to-pkgbuild" {
  rule = "FROM all vms TO tag role=pkgbuild ALLOW tcp (PORT 8080 AND PORT 80)"
  enabled = true
}

resource "triton_machine" "pkgbuild" {
  count = 1
  name = "pkgbuild-${count.index}"
  package = "sample-8G"

  # Using pkgbuild 15.4.1
  image = "c20b4b7c-e1a6-11e5-9a4d-ef590901732e"

  firewall_enabled = true

  nic {
    network = "${var.triton_network_id}"
  }

  # User-script
  user_script = "${file("${path.module}/scripts/user-script.sh")}"
  user_data = "${var.gpg_private_key}"

  tags {
    # Use zeroae/terraform:features/triton-cns branch.
    triton_cns_services = "pkgbuild"
    env  = "prod"
    role = "pkgbuild"
  }
}
