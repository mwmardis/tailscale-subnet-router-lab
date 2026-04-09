output "vm_name" {
  description = "Name of the created VM"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_id" {
  description = "ID of the created VM"
  value       = azurerm_linux_virtual_machine.main.id
}

output "private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}
