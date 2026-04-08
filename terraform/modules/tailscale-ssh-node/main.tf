resource "azurerm_public_ip" "main" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]
  tags                = var.tags
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  zone                = "2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  computer_name       = "tailscalevm"
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-pro"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "install_tailscale" {
  name                 = "install-tailscale"
  virtual_machine_id   = azurerm_windows_virtual_machine.main.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -Command \"Invoke-WebRequest -Uri 'https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi' -OutFile 'C:\\tailscale.msi'; Start-Process msiexec.exe -ArgumentList '/i C:\\tailscale.msi /quiet /norestart' -Wait; for ($$i = 0; $$i -lt 30; $$i++) { $$svc = Get-Service -Name Tailscale -ErrorAction SilentlyContinue; if ($$svc -and $$svc.Status -eq 'Running') { break }; Start-Sleep -Seconds 2 }; & 'C:\\Program Files\\Tailscale\\tailscale.exe' up --authkey=${var.tailscale_auth_key} --accept-routes\""
  })

  tags = var.tags
}
