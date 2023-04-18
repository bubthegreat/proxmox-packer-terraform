resource "packer_image" "ubuntu_server_jammy_base" {
    directory = "../../../packer/ubuntu-server-jammy-base/"
    file = "ubuntu-server-jammy-base.pkr.hcl"
    name = "ubuntu-server-jammy-base"
    force = true
    variables = {
        proxmox_api_url = var.proxmox_api_url
        proxmox_api_user = var.proxmox_api_user
        proxmox_api_password = var.proxmox_api_password
        vm_id = 101
    }
}

resource "null_resource" "ubuntu_server_jammy_base_cloud_init_config" {
  depends_on    = [packer_image.ubuntu_server_jammy_base]
  provisioner "remote-exec" {
    inline = [
      "qm set 101 -ipconfig0 ip=dhcp",
      "qm set 101 -ciuser bub",
      "qm set 101 -cipassword supersecret",
      "qm set 101 -nameserver 8.8.8.8",

    ]
    connection {
      type     = "ssh"
      user     = "${var.proxmox_server_user}"
      password = "${var.proxmox_api_password}"
      host     = "${var.proxmox_server_ip}"
      timeout  = "60s"
    }
  }
}


resource "packer_image" "ubuntu_server_jammy_docker" {
    depends_on    = [null_resource.ubuntu_server_jammy_base_cloud_init_config]
    directory = "../../../packer/ubuntu-server-jammy-docker/"
    file = "ubuntu-server-jammy-docker.pkr.hcl"
    name = "ubuntu-server-jammy-docker"
    # force = true
    variables = {
        proxmox_api_url = var.proxmox_api_url
        proxmox_api_user = var.proxmox_api_user
        proxmox_api_password = var.proxmox_api_password
        vm_id = 102
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
        vm_id = 103
    }
}
