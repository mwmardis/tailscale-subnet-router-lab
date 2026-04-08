variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "tailscale-subnet-router-lab-rg"
}

variable "vm_name" {
  description = "Name of the Azure VM"
  type        = string
  default     = "tailscale-lab-vm"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for RDP/xrdp login"
  type        = string
  sensitive   = true
}

variable "allowed_rdp_cidr" {
  description = "CIDR allowed to RDP into the VM (e.g., your public IP as x.x.x.x/32)"
  type        = string
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    project     = "tailscale-subnet-router-lab"
    environment = "lab"
  }
}
