terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
    random  = { source = "hashicorp/random", version = "~> 3.0" }
  }
  backend "local" {} # Pour le lab. À changer pour azurerm en prod
}

provider "azurerm" {
  features {}
}

# --- CHARGEMENT DU JSON ---
locals {
  config = jsondecode(file("infra.json"))
}

# --- GROUPE DE RESSOURCES ---
resource "azurerm_resource_group" "rg" {
  name     = "RG-${local.config.project_name}-${local.config.environment}"
  location = local.config.location
}

# --- MODULE RÉSEAU (Fondation) ---
module "network" {
  source = "./modules/network"

  rg_name      = azurerm_resource_group.rg.name
  location     = azurerm_resource_group.rg.location
  vnet_name    = "vnet-${local.config.project_name}"
  vnet_cidr    = local.config.networking.vnet_cidr
  pe_subnet    = local.config.networking.subnet_private_endpoints_cidr
  integ_subnet = local.config.networking.subnet_app_integration_cidr
}

# --- MODULE STORAGE (Boucle sur la liste) ---
module "storage" {
  for_each = { for st in local.config.resources.storage_accounts : st.name => st }
  source   = "./modules/storage_prive"

  name      = each.value.name
  sku       = each.value.sku
  rg_name   = azurerm_resource_group.rg.name
  location  = azurerm_resource_group.rg.location
  subnet_id = module.network.subnet_pe_id
}

# --- MODULE SQL (Boucle sur la liste) ---
module "database" {
  for_each = { for db in local.config.resources.databases : db.name => db }
  source   = "./modules/database_privee"

  name      = each.value.name
  sku       = each.value.sku
  rg_name   = azurerm_resource_group.rg.name
  location  = azurerm_resource_group.rg.location
  subnet_id = module.network.subnet_pe_id
}

# --- MODULE KEYVAULT (Conditionnel) ---
module "keyvault" {
  count  = local.config.resources.keyvault.enabled ? 1 : 0
  source = "./modules/keyvault_prive"

  name      = local.config.resources.keyvault.name
  rg_name   = azurerm_resource_group.rg.name
  location  = azurerm_resource_group.rg.location
  subnet_id = module.network.subnet_pe_id
}

# --- MODULE WEB APP (Conditionnel) ---
module "webapp" {
  count  = local.config.resources.webapp.enabled ? 1 : 0
  source = "./modules/webapp_prive"

  name                  = local.config.resources.webapp.name
  sku                   = local.config.resources.webapp.sku
  rg_name               = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  subnet_pe_id          = module.network.subnet_pe_id    # Pour l'entrée privée
  subnet_integration_id = module.network.subnet_integ_id # Pour la sortie vers la DB
}