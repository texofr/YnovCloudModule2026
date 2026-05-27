variable "name" {}
variable "sku" {}
variable "rg_name" {}
variable "location" {}
variable "subnet_id" {}

variable "private_dns_zone_ids" {
  description = "IDs des zones DNS privées à associer au Private Endpoint"
  type        = list(string)
  default     = []
}