# -----------------------------------------------------------------------
# VARIABLES GÉNÉRALES
# -----------------------------------------------------------------------

variable "rg_name" {
  description = "Le nom du Resource Group à créer"
  type        = string
}

variable "location" {
  description = "La région Azure où déployer les ressources"
  type        = string
  default     = "France Central"
}

# -----------------------------------------------------------------------
# VARIABLES RÉSEAU (Objet complexe)
# -----------------------------------------------------------------------

variable "vnet_params" {
  description = "Paramètres groupés pour le réseau virtuel"
  type = object({
    name        = string
    vnet_cidr   = string
    subnet_cidr = string
  })
}

# -----------------------------------------------------------------------
# VARIABLES MACHINE VIRTUELLE
# -----------------------------------------------------------------------

variable "vm_name" {
  description = "Le nom de la machine virtuelle"
  type        = string
}

variable "admin_username" {
  description = "Le nom de l'utilisateur administrateur (obligatoire)"
  type        = string
}