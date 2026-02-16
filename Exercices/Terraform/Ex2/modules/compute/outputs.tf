output "vm_public_ip" {
  description = "L'adresse IP publique de la VM générée par le module"
  # On va chercher l'attribut spécifique de la ressource VM
  value       = azurerm_linux_virtual_machine.vm.public_ip_address
}