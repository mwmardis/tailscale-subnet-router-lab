output "vm_name" {
  description = "Name of the created VM"
  value       = azurerm_windows_virtual_machine.main.name
}

output "public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}

output "private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}
