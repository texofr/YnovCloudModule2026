# main.tf (à la racine)
# -----------------------------------------------------------------------
# 1. CONFIGURATION DU BACKEND ET DU PROVIDER
# -----------------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Configuration du stockage distant pour le fichier d'état
  backend "azurerm" {
    resource_group_name  = "RG-TERRAFORM-BACKEND"
    storage_account_name = "sttfstate[VOS_INITIALES]" # À modifier
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------
# 2. CRÉATION DES RESSOURCES
# -----------------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = "RG-MODULAIRE-LAB"
  location = "France Central"
}

# Appel du module Réseau
module "mon_reseau" {
  source      = "./modules/network"
  rg_name     = azurerm_resource_group.rg.name
  location    = azurerm_resource_group.rg.location
  vnet_name   = "VNET-PROD"
  vnet_cidr   = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
}

# Appel du module VM
module "ma_vm" {
  source           = "./modules/compute"
  rg_name          = azurerm_resource_group.rg.name
  location         = azurerm_resource_group.rg.location
  vm_name          = "SRV-WEB-01"
  admin_username   = var.admin_username
  target_subnet_id = module.mon_reseau.subnet_id # On récupère l'output du module network !
}