# modules/compute/variables.tf

variable "location" {}
variable "rg_name" {}
variable "vm_name" {}


variable "admin_username" {
  type        = string
  description = "Nom de l'utilisateur admin"
}

variable "admin_password" {
  type        = string
  description = "Mot de passe administrateur de la VM"
  sensitive   = true
}

variable "target_subnet_id" {
  description = "L'ID du subnet provenant du module network"
  type        = string
}