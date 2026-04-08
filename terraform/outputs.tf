output "vm_name" {
  description = "Name of the Azure VM"
  value       = module.tailscale_ssh_node.vm_name
}

output "vm_public_ip" {
  description = "Public IP of the Azure VM — use this for RDP"
  value       = module.tailscale_ssh_node.public_ip
}
