# modules/webapp/variables.tf

variable "name"      { type = string }
variable "sku"       { type = string }
variable "rg_name"   { type = string }
variable "location"  { type = string }

# IDs provenant du module network
variable "subnet_pe_id"          { type = string }
variable "subnet_integration_id" { type = string }