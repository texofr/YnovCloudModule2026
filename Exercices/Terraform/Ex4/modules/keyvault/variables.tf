variable "name" { type = string }
variable "rg_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }

variable "private_dns_zone_ids" {
  description = "IDs des zones DNS privées à associer au Private Endpoint"
  type        = list(string)
  default     = []
}