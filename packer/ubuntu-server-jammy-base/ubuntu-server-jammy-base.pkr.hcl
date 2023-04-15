# Variable Definitions
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

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-jammy-base" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_user}"
    password = "${var.proxmox_api_password}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "pve"
    vm_id = "101"
    vm_name = "ubuntu-server-jammy-base"
    template_description = "Ubuntu Server jammy Image"
    qemu_agent = true
    scsi_controller = "virtio-scsi-pci"
    cores = "4"
    sockets = "2"
    memory = "8192" 
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 
    disks {
        storage_pool = "local-lvm-fast"
        storage_pool_type = "lvm"
        type = "virtio"
        disk_size = "32G"
        format = "raw"
    }
    ssh_username = "bub"
    ssh_timeout = "20m"
    ssh_private_key_file = "~/.ssh/id_rsa"

    # ISO Settings

    disks {
        disk_size = "32G"
        format = "raw"
        storage_pool = "local-lvm"
        storage_pool_type = "lvm"
        type = "virtio"
    }

    iso_file = "local:iso/ubuntu-22.04-live-server-amd64.iso"
    iso_storage_pool = "local"
    unmount_iso = true

    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    http_directory = "http" 
    http_bind_address = "0.0.0.0"
    http_port_min = 8802
    http_port_max = 8802


}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-jammy-base"
    sources = ["source.proxmox-iso.ubuntu-server-jammy-base"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}