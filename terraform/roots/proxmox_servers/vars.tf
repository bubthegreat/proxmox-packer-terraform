variable "vm_username" {
    type = string
}

variable "vm_public_key" {
    type = string
}

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_user" {
    type = string
}

variable "proxmox_api_password" {
    type = string
    sensitive = true
}

variable "proxmox_server_ip" {
    type = string
}

variable "proxmox_server_user" {
    type = string
}

variable "cluster_join_ip" {
  type = string
  default = "192.168.29.101"
}

variable "cluster_gateway" {
  type = string
  default = "192.168.29.1"
}
variable "cluster_netmask" {
  type = string
  default = "24"
}
variable "cluster_dns" {
  type = string
  default = "8.8.8.8"
}
variable "private_key_path" {
  type = string
  default = "~/.ssh/id_rsa"
}
