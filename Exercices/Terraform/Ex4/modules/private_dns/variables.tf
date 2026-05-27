variable "rg_name" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "zones" {
  description = "Liste des zones DNS privées à créer et lier au VNet"
  type        = list(string)
  default     = []
}