# terraform.tfvars (À la racine)

location       = "North Europe"
vm_name        = "SRV-PROD-APP"
rg_name        = "RG-B3-Eric"
admin_username = "azureuser"
admin_password = "P@ssw0rd1234!"
vm_size        = "Standard_B1s"
public_ip_allocation_method = "Static"
public_ip_sku  = "Standard"
os_disk_caching = "ReadWrite"
storage_account_type = "Standard_LRS"
image_publisher = "Canonical"
image_offer    = "0001-com-ubuntu-server-jammy"
image_sku      = "22_04-lts"
image_version  = "latest"
subnet_name    = "internal"

vnet_params = {
  name        = "VNET-HYBRIDE"
  vnet_cidr   = "172.16.0.0/16"
  subnet_cidr = "172.16.1.0/24"
}