terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.28"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "tailscale" {}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allowed_rdp_cidr    = var.allowed_rdp_cidr
  tags                = var.tags
}

resource "tailscale_tailnet_key" "main" {
  reusable      = false
  ephemeral     = true
  preauthorized = true
  expiry        = 3600
  description   = "Terraform-managed key for ${var.vm_name}"
}

module "tailscale_ssh_node" {
  source = "./modules/tailscale-ssh-node"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.network.subnet_id
  vm_name             = var.vm_name
  admin_password      = var.admin_password
  tailscale_auth_key  = tailscale_tailnet_key.main.key
  tags                = var.tags
}
