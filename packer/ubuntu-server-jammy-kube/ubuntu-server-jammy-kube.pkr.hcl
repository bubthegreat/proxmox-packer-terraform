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

variable "vm_id" {
    type = string
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
    vm_id = "${var.vm_id}"
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
    ssh_timeout = "30m"
    ssh_username = "bub"
    ssh_private_key_file = "~/.ssh/id_rsa"
    task_timeout = "10m"
    
    full_clone = false
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

    provisioner "file" {
        source: "./files/containerd-config.toml"
        destination = "/etc/containerd/config.toml"
    }

    provisioner "file" {
        source: "./files/cgroup-driver-k8s.conf"
        destination = "/etc/modules-load.d/k8s.conf"
    }
}