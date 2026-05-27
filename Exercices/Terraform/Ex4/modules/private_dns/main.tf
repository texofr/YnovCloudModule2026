resource "azurerm_private_dns_zone" "zones" {
  for_each            = toset(var.zones)
  name                = each.value
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each              = azurerm_private_dns_zone.zones
  name                  = "link-${replace(each.key, ".", "-")}"
  resource_group_name   = var.rg_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.vnet_id
}

output "zone_ids" {
  description = "Map zone DNS privee => id"
  value       = { for zone_name, zone in azurerm_private_dns_zone.zones : zone_name => zone.id }
}