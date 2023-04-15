resource "packer_image" "ubuntu_server_jammy_base" {
    directory = "../../../packer/ubuntu-server-jammy-base/"
    file = "ubuntu-server-jammy-base.pkr.hcl"
    name = "ubuntu-server-jammy-base"
    variables = {
        proxmox_api_url = var.proxmox_api_url
        proxmox_api_user = var.proxmox_api_user
        proxmox_api_password = var.proxmox_api_password
    }
}

resource "packer_image" "ubuntu_server_jammy_docker" {
    depends_on    = [packer_image.ubuntu_server_jammy_base]
    directory = "../../../packer/ubuntu-server-jammy-docker/"
    file = "ubuntu-server-jammy-docker.pkr.hcl"
    name = "ubuntu-server-jammy-docker"
    variables = {
        proxmox_api_url = var.proxmox_api_url
        proxmox_api_user = var.proxmox_api_user
        proxmox_api_password = var.proxmox_api_password
    }
}

resource "packer_image" "ubuntu_server_jammy_kube" {
    depends_on    = [packer_image.ubuntu_server_jammy_docker]
    directory = "../../../packer/ubuntu-server-jammy-kube/"
    file = "ubuntu-server-jammy-kube.pkr.hcl"
    name = "ubuntu-server-jammy-kube"
    variables = {
        proxmox_api_url = var.proxmox_api_url
        proxmox_api_user = var.proxmox_api_user
        proxmox_api_password = var.proxmox_api_password
    }
}
