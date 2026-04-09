resource "azurerm_virtual_machine_extension" "install_desktop" {
  name                 = "install-desktop"
  virtual_machine_id   = var.virtual_machine_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = jsonencode({
    script = base64encode(<<-SCRIPT
      #!/bin/bash
      export DEBIAN_FRONTEND=noninteractive

      cloud-init status --wait || true

      while fuser /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/cache/apt/archives/lock >/dev/null 2>&1; do
        sleep 5
      done
      dpkg --configure -a || true

      apt-mark hold walinuxagent
      apt-get update -y
      apt-get install -y xfce4 xfce4-goodies lightdm firefox-esr

      wget -q https://github.com/rustdesk/rustdesk/releases/download/${var.rustdesk_version}/rustdesk-${var.rustdesk_version}-x86_64.deb -O /tmp/rustdesk.deb
      apt-get install -y /tmp/rustdesk.deb
      rm -f /tmp/rustdesk.deb

      mkdir -p /etc/lightdm/lightdm.conf.d
      printf '[Seat:*]\nautologin-user=${var.admin_username}\nautologin-user-timeout=0\n' > /etc/lightdm/lightdm.conf.d/50-autologin.conf

      systemctl set-default graphical.target
      reboot
    SCRIPT
    )
  })

  tags = var.tags

  timeouts {
    create = "60m"
  }
}
