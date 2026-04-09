variable "virtual_machine_id" {
  description = "ID of the VM to install the desktop environment on"
  type        = string
}

variable "admin_username" {
  description = "Username for GDM auto-login"
  type        = string
}

variable "rustdesk_version" {
  description = "RustDesk version to install"
  type        = string
  default     = "1.4.6"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
