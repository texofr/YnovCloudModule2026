# terraform.tfvars (À la racine)

location = "North Europe"
vm_name  = "SRV-PROD-APP"
rg_name  = "RG-B3-Eric"
admin_password = "P@ssw0rd1234!"

vnet_params = {
  name        = "VNET-LABOYNOV"
  vnet_cidr   = "172.16.0.0/16"
  subnet_cidr = "172.16.1.0/24"
}