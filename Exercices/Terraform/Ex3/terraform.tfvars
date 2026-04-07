# terraform.tfvars (À la racine)

location       = "North Europe"
vm_name        = "SRV-PROD-APP"
rg_name        = "RG-FINAL-PROJECT"
admin_username = "azureuser"

vnet_params = {
  name        = "VNET-HYBRIDE"
  vnet_cidr   = "172.16.0.0/16"
  subnet_cidr = "172.16.1.0/24"
}