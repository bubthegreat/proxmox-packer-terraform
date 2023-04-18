# https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#argument-reference

resource "proxmox_vm_qemu" "k8s_server_1" {
  vmid          = 2221
  name          = "k8s-server-1"
  desc          = "Ubuntu 22.04 LTS Server"
  target_node   = "pve"
  qemu_os       = "l26"
  
  agent         = 1

  clone         = "ubuntu-server-jammy-kube"
  cores         = 4
  sockets       = 2
  cpu           = "host"
  onboot        = true
  memory        = 8192

  scsihw        = "virtio-scsi-single"
  full_clone = false

  disk {
    storage = "local-lvm"
    type = "virtio"
    size = "16G"
    format = "raw"
  }

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=192.168.29.21/16"
  nameserver = "8.8.8.8"
  ciuser = "${var.vm_username}"
  sshkeys = <<EOF
${var.vm_public_key}
  EOF
}


resource "proxmox_vm_qemu" "k8s_server_2" {
  vmid          = 2222
  name          = "k8s-server-2"
  desc          = "Ubuntu 22.04 LTS Server"
  target_node   = "pve"
  qemu_os       = "l26"
  
  agent         = 1

  clone         = "ubuntu-server-jammy-kube"
  cores         = 4
  sockets       = 2
  cpu           = "host"
  onboot        = true
  memory        = 8192

  scsihw        = "virtio-scsi-single"
  full_clone = false

  disk {
    storage = "local-lvm"
    type = "virtio"
    size = "16G"
    format = "raw"
  }

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=192.168.29.22/16"
  nameserver = "8.8.8.8"
  ciuser = "${var.vm_username}"
  sshkeys = <<EOF
${var.vm_public_key}
  EOF
}


resource "proxmox_vm_qemu" "k8s_server_3" {
  vmid          = 2223
  name          = "k8s-server-3"
  desc          = "Ubuntu 22.04 LTS Server"
  target_node   = "pve"
  qemu_os       = "l26"
  
  agent         = 1

  clone         = "ubuntu-server-jammy-kube"
  cores         = 4
  sockets       = 2
  cpu           = "host"
  onboot        = true
  memory        = 8192

  scsihw        = "virtio-scsi-single"
  full_clone = false

  disk {
    storage = "local-lvm"
    type = "virtio"
    size = "16G"
    format = "raw"
  }

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=192.168.29.23/16"
  nameserver = "8.8.8.8"
  ciuser = "${var.vm_username}"
  sshkeys = <<EOF
${var.vm_public_key}
  EOF
}
