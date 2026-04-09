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
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "tailscale" {
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}

resource "tailscale_tailnet_key" "main" {
  reusable      = false
  ephemeral     = true
  preauthorized = true
  expiry        = 3600
  description   = "Terraform-managed key for ${var.vm_name}"
  tags          = ["tag:vm-lab"]
}

module "tailscale_ssh_node" {
  source = "./modules/tailscale-ssh-node"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.network.subnet_id
  vm_name             = var.vm_name
  admin_username      = var.admin_username
  tailscale_auth_key  = tailscale_tailnet_key.main.key
  tags                = var.tags
}

module "desktop_environment" {
  source = "./modules/desktop-environment"

  virtual_machine_id = module.tailscale_ssh_node.vm_id
  admin_username     = var.admin_username
  tags               = var.tags
}
