output "resource_group_name" {
  description = "Nom du groupe de ressources créé"
  value       = azurerm_resource_group.main.name
}

output "public_ip_address" {
  description = "Adresse IP publique de la VM"
  value       = azurerm_public_ip.main.ip_address
}

output "ssh_connection_command" {
  description = "Commande SSH pour se connecter à la VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "vm_name" {
  description = "Nom de la machine virtuelle"
  value       = azurerm_linux_virtual_machine.main.name
}

output "location" {
  description = "Région Azure où les ressources sont déployées"
  value       = azurerm_resource_group.main.location
}
