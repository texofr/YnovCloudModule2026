resource "azurerm_subnet" "pe_subnet" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.pe_subnet]
  private_endpoint_network_policies = "Enabled" 
}
output "subnet_pe_id" { value = azurerm_subnet.pe_subnet.id } #
output "subnet_integ_id" { value = azurerm_subnet.integ_subnet.id }