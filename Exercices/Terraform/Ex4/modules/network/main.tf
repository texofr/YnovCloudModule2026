resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.rg_name
  location            = var.location
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "pe_subnet" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.pe_subnet]
  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "integ_subnet" {
  name                 = "snet-vnet-integration"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.integ_subnet]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

output "subnet_pe_id" { value = azurerm_subnet.pe_subnet.id }
output "subnet_integ_id" { value = azurerm_subnet.integ_subnet.id }