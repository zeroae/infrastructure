variable "triton_key_path" {
  default = "~/.ssh/id_rsa"
  description = "Path to Triton SSH Key"
}

variable "triton_vlan_id" {
  default = 3
  description = "Bastion desired VLAN"
}

variable "triton_network_public_id" {
  default = "f8c044bc-f14a-45ab-a5cd-2a6f9954a0c6"
  description = "Triton's Public Network"
}
