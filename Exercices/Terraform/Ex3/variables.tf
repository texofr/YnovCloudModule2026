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

variable "admin_password" {
  description = "Mot de passe administrateur de la VM"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------
# VARIABLES COMPUTE (VM)
# -----------------------------------------------------------------------

variable "vm_size" {
  description = "La taille de la machine virtuelle"
  type        = string
  default     = "Standard_B1s"
}

variable "public_ip_allocation_method" {
  description = "Méthode d'allocation de l'adresse IP publique"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "SKU de l'adresse IP publique"
  type        = string
  default     = "Standard"
}

variable "os_disk_caching" {
  description = "Type de caching pour le disque OS"
  type        = string
  default     = "ReadWrite"
}

variable "storage_account_type" {
  description = "Type de compte de stockage pour le disque OS"
  type        = string
  default     = "Standard_LRS"
}

variable "image_publisher" {
  description = "Editeur de l'image OS"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Offre de l'image OS"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "SKU de l'image OS"
  type        = string
  default     = "22_04-lts"
}

variable "image_version" {
  description = "Version de l'image OS"
  type        = string
  default     = "latest"
}

variable "subnet_name" {
  description = "Nom du subnet"
  type        = string
  default     = "internal"
}