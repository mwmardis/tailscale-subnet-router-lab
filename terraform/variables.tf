variable "tailscale_oauth_client_id" {
  description = "Tailscale OAuth client ID"
  type        = string
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale OAuth client secret"
  type        = string
  sensitive   = true
}

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

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    project     = "tailscale-subnet-router-lab"
    environment = "lab"
  }
}
