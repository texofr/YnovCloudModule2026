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
    resource_group_name  = "RG-TERRAFORM-BACKEND"
    storage_account_name = "sttfstatevotreinitiale" # À adapter
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
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags = {
    Environment = terraform.workspace # Optionnel : pour taguer selon l'espace de travail
  }
}

# -----------------------------------------------------------------------
# 4. APPEL DU MODULE RÉSEAU (NETWORK)
# -----------------------------------------------------------------------
module "mon_reseau" {
  source      = "./modules/network"
  
  # On transmet les informations du RG
  rg_name     = azurerm_resource_group.rg.name
  location    = azurerm_resource_group.rg.location
  
  # On transmet les paramètres réseau définis dans les variables/tfvars
  vnet_name   = var.vnet_params.name
  vnet_cidr   = var.vnet_params.vnet_cidr
  subnet_cidr = var.vnet_params.subnet_cidr
}

# -----------------------------------------------------------------------
# 5. APPEL DU MODULE CALCUL (COMPUTE)
# -----------------------------------------------------------------------
module "mon_compute" {
  source           = "./modules/compute"
  
  rg_name          = azurerm_resource_group.rg.name
  location         = azurerm_resource_group.rg.location
  
  # Paramètres de la VM
  vm_name          = var.vm_name
  
  # Correction : Ajout de l'attribut requis admin_username
  admin_username   = var.admin_username 
  
  # Liaison : On récupère l'ID du subnet généré par le module network
  target_subnet_id = module.mon_reseau.subnet_id 
}