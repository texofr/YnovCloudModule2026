# modules/webapp/main.tf

# 1. Plan de service (App Service Plan)
resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.name}"
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku
}

# 2. Web App Linux
resource "azurerm_linux_web_app" "app" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id
  
  # CONFIGURATION DE SORTIE (VNet Integration)
  # Permet à l'App d'atteindre le SQL/Storage en interne
  virtual_network_subnet_id = var.subnet_integration_id 
  
  # CONFIGURATION D'ENTRÉE (Sécurité)
  # Désactive l'accès via l'URL publique .azurewebsites.net
  public_network_access_enabled = false

  site_config {
    always_on = (var.sku == "F1" || var.sku == "B1") ? false : true
  }
}

# 3. Point de terminaison privé (Private Endpoint)
# Pour permettre l'accès à l'App uniquement via le réseau privé
resource "azurerm_private_endpoint" "pe" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_pe_id # Utilise l'ID du subnet PE

  private_service_connection {
    name                           = "psc-web-${var.name}"
    private_connection_resource_id = azurerm_linux_web_app.app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}