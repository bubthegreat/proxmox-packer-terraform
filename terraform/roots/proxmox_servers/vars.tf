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
