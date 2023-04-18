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
source "proxmox-clone" "ubuntu-server-jammy-docker" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_user}"
    password = "${var.proxmox_api_password}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "pve"
    vm_id = "${var.vm_id}"
    vm_name = "ubuntu-server-jammy-docker"
    template_description = "Ubuntu Server jammy Image with Docker "
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
    clone_vm = "ubuntu-server-jammy-base"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-jammy-docker"
    sources = ["source.proxmox-clone.ubuntu-server-jammy-docker"]

    
    # We want to wait for the template to finish with anything cloud-init needs to do just to make sure it's all
    # installed - this will (In theory) speed up subsequent builds)
    provisioner "shell" {
        inline = [
            "/usr/bin/cloud-init status --wait",
            "sudo apt-get -y update",
        ]
    }

    # Provisioning the VM Template with Docker Installation #4
    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install --fix-missing -y docker-ce docker-ce-cli containerd.io"
        ]
    }
}