resource "packer_image" "ubuntu_server_jammy" {
    directory = "../../../packer/ubuntu-server-jammy/"
    file = "ubuntu-server-jammy.pkr.hcl"
    name = "ubuntu-server-jammy"
    variables = {
        proxmox_api_url = var.proxmox_api_url
        proxmox_api_user = var.proxmox_api_user
        proxmox_api_password = var.proxmox_api_password
    }
}