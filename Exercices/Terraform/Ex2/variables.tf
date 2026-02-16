# variables.tf (Racine)

variable "location" {
  description = "Région Azure pour toutes les ressources"
  type        = string
  default     = "France Central"
}

variable "rg_name" {
  description = "Nom du Resource Group"
  type        = string
  default     = "RG-MODULAIRE-LAB"
}

variable "vnet_params" {
  description = "Configuration du réseau"
  type = object({
    name        = string
    vnet_cidr   = string
    subnet_cidr = string
  })
  default = {
    name        = "VNET-PROD"
    vnet_cidr   = "10.0.0.0/16"
    subnet_cidr = "10.0.1.0/24"
  }
}

variable "vm_name" {
  description = "Nom de la machine virtuelle"
  type        = string
  default     = "SRV-WEB-01"
}

variable "admin_username" {
  description = "Utilisateur administrateur de la VM"
  type        = string
  default     = "azureuser"
}