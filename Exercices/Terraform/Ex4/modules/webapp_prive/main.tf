# modules/webapp_prive/main.tf
variable "name" {}
variable "sku" {}
variable "rg_name" {}
variable "location" {}
variable "subnet_pe_id" {}
variable "subnet_integration_id" {}

resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.name}"
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku
}

resource "azurerm_linux_web_app" "app" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id
  
  # CONFIGURATION DE SORTIE (Pour accéder à la DB privée)
  virtual_network_subnet_id = var.subnet_integration_id 
  
  # CONFIGURATION D'ENTRÉE (Refuser Internet)
  public_network_access_enabled = false

  site_config {}
}

resource "azurerm_private_endpoint" "pe" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_pe_id

  private_service_connection {
    name                           = "psc-web"
    private_connection_resource_id = azurerm_linux_web_app.app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}