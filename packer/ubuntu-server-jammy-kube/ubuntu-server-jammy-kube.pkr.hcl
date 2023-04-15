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
source "proxmox-clone" "ubuntu-server-jammy-kube" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_user}"
    password = "${var.proxmox_api_password}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "pve"
    vm_id = "103"
    vm_name = "ubuntu-server-jammy-kube"
    template_description = "Ubuntu Server jammy Image with kube "
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
    ssh_timeout = "30m"
    ssh_private_key_file = "~/.ssh/id_rsa"

    # Clone settings

    clone_vm = "ubuntu-server-jammy-docker"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-jammy-kube"
    sources = ["source.proxmox-clone.ubuntu-server-jammy-kube"]

    # We want to wait for the template to finish with anything cloud-init needs to do just to make sure it's all
    # installed - this will (In theory) speed up subsequent builds)
    provisioner "shell" {
        inline = [
            "/usr/bin/cloud-init status --wait",
            "sudo apt -y update",
        ]
    }

    # Provisioning the VM Template with Docker Installation #4
    provisioner "shell" {
        inline = [
            "sudo apt -y update",
            "sudo apt install -y apt-transport-https ca-certificates curl",
            "sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg",
            "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
            "sudo apt -y update",
            "sudo apt install -y kubelet kubeadm kubectl",
            "sudo apt-mark hold kubelet kubeadm kubectl"
        ]
    }
}