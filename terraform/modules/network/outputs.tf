output "subnet_id" {
  description = "ID of the created subnet"
  value       = azurerm_subnet.main.id
}

output "vnet_id" {
  description = "ID of the created VNet"
  value       = azurerm_virtual_network.main.id
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "vnet_address_space" {
  description = "Address space of the VNet"
  value       = azurerm_virtual_network.main.address_space
}
