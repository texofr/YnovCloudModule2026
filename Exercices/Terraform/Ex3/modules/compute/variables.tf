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

variable "vm_size" {
  type        = string
  description = "Taille de la VM"
}

variable "public_ip_allocation_method" {
  type        = string
  description = "Méthode d'allocation de l'IP publique"
}

variable "public_ip_sku" {
  type        = string
  description = "SKU de l'IP publique"
}

variable "os_disk_caching" {
  type        = string
  description = "Caching du disque OS"
}

variable "storage_account_type" {
  type        = string
  description = "Type de compte de stockage"
}

variable "image_publisher" {
  type        = string
  description = "Editeur de l'image OS"
}

variable "image_offer" {
  type        = string
  description = "Offre de l'image OS"
}

variable "image_sku" {
  type        = string
  description = "SKU de l'image OS"
}

variable "image_version" {
  type        = string
  description = "Version de l'image OS"
}