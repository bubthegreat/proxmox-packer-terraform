
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_user" {
    type = string
}

variable "proxmox_lxc_public_key" {
    type = string
}

variable "proxmox_lxc_template" {
    type = string
    default = "ubuntu-22.10-standard_22.10-1_amd64.tar.zst"
}

variable "proxmox_api_password" {
    type = string
    sensitive = true
}

variable "k8s_server_password" {
    type = string
    sensitive = true
}

variable "proxmox_server_ip" {
    type = string
}

variable "proxmox_server_user" {
    type = string
}

resource "proxmox_lxc" "basic" {
  count = 3
  target_node  = "pve"
  onboot = true
  memory = 8192
  vmid = "${100 + count.index + 1}"
  cores = 4
  hostname     = "k8s-lxc-${100 + count.index + 1}"
  ostemplate   = "local:vztmpl/${var.proxmox_lxc_template}"
  ostype = "ubuntu"
  password     = "${var.k8s_server_password}"
  start = true
  unprivileged = true
  ssh_public_keys = <<-EOT
    ${var.proxmox_lxc_public_key}
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "16G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "11.1.1.${100 + count.index + 1}/8"
    gw     = "11.0.0.1"
  }
}