# modules/network/variables.tf

variable "location" {}
variable "rg_name" {}
variable "vnet_name" {}
variable "vnet_cidr" {}
variable "subnet_cidr" {}

variable "subnet_name" {
  type        = string
  description = "Nom du subnet"
}