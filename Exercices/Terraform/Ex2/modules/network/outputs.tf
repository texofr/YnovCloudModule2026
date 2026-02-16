# SORTIE : On doit "exporter" l'ID du subnet pour que la VM puisse l'utiliser
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}