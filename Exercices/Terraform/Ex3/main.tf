# -----------------------------------------------------------------------
# 1. CONFIGURATION TERRAFORM & BACKEND
# -----------------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Le backend est configuré pour utiliser le stockage Azure.
  # La "key" (le nom du fichier tfstate) sera écrasée par le pipeline GitHub 
  # pour différencier Dev et Prod.
  backend "azurerm" {
    resource_group_name  = "RG-B3-Eric"
    storage_account_name = "sttfstatelabynovepe" # À adapter
    container_name       = "tfstate"
    key                  = "default.terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# 2. CONFIGURATION DU PROVIDER
# -----------------------------------------------------------------------
provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------
# 3. RESSOURCES PRINCIPALES (LE RESOURCE GROUP)
# -----------------------------------------------------------------------
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

# -----------------------------------------------------------------------
# 4. APPEL DU MODULE RÉSEAU (NETWORK)
# -----------------------------------------------------------------------
module "mon_reseau" {
  source      = "./modules/network"
  
  # On transmet les informations du RG
  rg_name     = data.azurerm_resource_group.rg.name
  location    = data.azurerm_resource_group.rg.location
  
  # On transmet les paramètres réseau définis dans les variables/tfvars
  vnet_name   = var.vnet_params.name
  vnet_cidr   = var.vnet_params.vnet_cidr
  subnet_cidr = var.vnet_params.subnet_cidr
  subnet_name = var.subnet_name
}

# -----------------------------------------------------------------------
# 5. APPEL DU MODULE CALCUL (COMPUTE)
# -----------------------------------------------------------------------
module "mon_compute" {
  source           = "./modules/compute"
  
  rg_name          = data.azurerm_resource_group.rg.name
  location         = data.azurerm_resource_group.rg.location
  
  # Paramètres de la VM
  vm_name          = var.vm_name
  admin_username   = var.admin_username
  admin_password   = var.admin_password
  vm_size          = var.vm_size
  public_ip_allocation_method = var.public_ip_allocation_method
  public_ip_sku    = var.public_ip_sku
  os_disk_caching  = var.os_disk_caching
  storage_account_type = var.storage_account_type
  image_publisher  = var.image_publisher
  image_offer      = var.image_offer
  image_sku        = var.image_sku
  image_version    = var.image_version
  
  # Liaison : On récupère l'ID du subnet généré par le module network
  target_subnet_id = module.mon_reseau.subnet_id 
}