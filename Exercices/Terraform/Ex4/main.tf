# --- 1. CONFIGURATION LOCALE & PARSING JSON ---
locals {
  infra = jsondecode(file("infra.json"))

  # Aplatissement des listes pour gérer plusieurs ressources par RG
  all_dbs = flatten([for rg, v in local.infra.resource_groups : [for d in lookup(v, "databases", []) : merge(d, { rg = rg })]])
  all_st  = flatten([for rg, v in local.infra.resource_groups : [for s in lookup(v, "storage_accounts", []) : merge(s, { rg = rg })]])
}

# --- 2. PROVIDERS ---
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Configuration du stockage distant pour le fichier d'etat
  backend "azurerm" {
    resource_group_name  = "RG-TERRAFORM-BACKEND"
    storage_account_name = "sttfstate[VOS_INITIALES]" # A modifier
    container_name       = "tfstate"
    key                  = "ex4.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# --- 3. RESSOURCES DE BASE (RESOURCE GROUPS) ---
resource "azurerm_resource_group" "rgs" {
  for_each = local.infra.resource_groups
  name     = each.key
  location = each.value.location
}

# --- 4. MODULE RÉSEAUX ---
module "networks" {
  for_each     = local.infra.resource_groups
  source       = "./modules/network"
  rg_name      = azurerm_resource_group.rgs[each.key].name
  location     = each.value.location
  vnet_name    = each.value.networking.vnet_name
  vnet_cidr    = each.value.networking.vnet_cidr
  pe_subnet    = each.value.networking.pe_subnet
  integ_subnet = each.value.networking.integ_subnet
}

# --- 5. MODULE SQL DATABASES ---

module "databases" {
  for_each = { for db in local.all_dbs : db.name => db }
  source   = "./modules/sql"
  name     = each.value.name
  sku      = each.value.sku
  rg_name  = azurerm_resource_group.rgs[each.value.rg].name
  location       = local.infra.location
  subnet_id      = module.networks[each.value.rg].subnet_pe_id 
}

# --- 6. MODULE STORAGE ACCOUNTS  ---
module "storage_accounts" {
  for_each  = { for st in local.all_st : st.name => st }
  source    = "./modules/storage"
  name      = each.value.name
  sku       = each.value.sku
  rg_name   = azurerm_resource_group.rgs[each.value.rg].name
  location  = local.infra.location
  subnet_id = module.networks[each.value.rg].subnet_pe_id
}

# --- 7. MODULE KEYVAULTS ---
module "keyvaults" {
  for_each  = { for k, v in local.infra.resource_groups : k => v.keyvault if lookup(v, "keyvault", null) != null }
  source    = "./modules/keyvault"
  name      = each.value.name
  rg_name   = azurerm_resource_group.rgs[each.key].name
  location  = local.infra.resource_groups[each.key].location
  subnet_id = module.networks[each.key].subnet_pe_id
}

# --- 8. MODULE WEBAPPS (SÉPARÉ) ---
module "webapps" {
  for_each              = { for k, v in local.infra.resource_groups : k => v.webapp if lookup(v, "webapp", null) != null }
  source                = "./modules/webapp"
  name                  = each.value.name
  sku                   = each.value.sku
  rg_name               = azurerm_resource_group.rgs[each.key].name
  location              = local.infra.location
  subnet_pe_id          = module.networks[each.key].subnet_pe_id # Liaison entrée
  subnet_integration_id = module.networks[each.key].subnet_integ_id # Liaison sortie
}