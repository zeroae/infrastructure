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
