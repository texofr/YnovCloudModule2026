# modules/storage_prive/main.tf

resource "azurerm_storage_account" "st" {
  name                     = var.name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = split("_", var.sku)[0]
  account_replication_type = split("_", var.sku)[1]
  
  # SÉCURITÉ MAXIMALE
  public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "pe" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_storage_account.st.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}