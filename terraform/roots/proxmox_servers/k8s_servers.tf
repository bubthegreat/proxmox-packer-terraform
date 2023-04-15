# https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#argument-reference

resource "proxmox_vm_qemu" "k8s_server_1" {
  vmid          = 2021
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

resource "null_resource" "k8s_server_1_reboot" {
  depends_on    = [proxmox_vm_qemu.k8s_server_1]
  provisioner "remote-exec" {
    inline = [
      "qm reboot ${proxmox_vm_qemu.k8s_server_1.vmid}",
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


resource "proxmox_vm_qemu" "k8s_server_2" {
  vmid          = 2022
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

resource "null_resource" "k8s_server_2_reboot" {
  depends_on    = [proxmox_vm_qemu.k8s_server_2]
  provisioner "remote-exec" {
    inline = [
      "qm reboot ${proxmox_vm_qemu.k8s_server_2.vmid}",
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


resource "proxmox_vm_qemu" "k8s_server_3" {
  vmid          = 2023
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

resource "null_resource" "k8s_server_3_reboot" {
  depends_on    = [proxmox_vm_qemu.k8s_server_3]
  provisioner "remote-exec" {
    inline = [
      "qm reboot ${proxmox_vm_qemu.k8s_server_3.vmid}",
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