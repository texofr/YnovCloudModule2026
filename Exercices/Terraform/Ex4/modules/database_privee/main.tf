# modules/database_privee/main.tf
variable "name" {}
variable "sku" {}
variable "rg_name" {}
variable "location" {}
variable "subnet_id" {}

resource "random_password" "pass" {
  length = 16
  special = true
}

resource "azurerm_mssql_server" "sql" {
  name                         = var.name
  resource_group_name          = var.rg_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.pass.result
  
  # SÉCURITÉ : Pas d'accès public
  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "db" {
  name      = "${var.name}-db"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = var.sku
}

resource "azurerm_private_endpoint" "pe" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}