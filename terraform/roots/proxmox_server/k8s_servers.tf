# https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#argument-reference

resource "proxmox_vm_qemu" "k8s_server_1" {
  depends_on    = [packer_image.ubuntu_server_jammy]
  name          = "k8s-server-1"
  desc          = "Ubuntu 22.04 LTS Server"
  target_node   = "pve"
  qemu_os       = "l26"
  
  agent         = 1

  clone         = packer_image.ubuntu_server_jammy.name
  cores         = 4
  sockets       = 2
  cpu           = "host"
  onboot        = true
  memory        = 8192

  scsihw        = "virtio-scsi-single"

  disk {
    storage = "local-lvm"
    type = "scsi"
    size = "32G"
  }

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=192.168.29.101/16,gw=192.168.29.1"
  nameserver = "192.168.29.1"
  ciuser = "bub"
  sshkeys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6CLheLTcYf7v23mF69qpGiTfCd7dmhMFTRh3IfqCppURO+W10rbCIebMEiT4bjF1QXAMwaXFRJ/FahIyWsMiojJ5yyCkJzspZuJyDUaLFQRQY0U0vS4Y7B5FqO5PpNXfPXN1uOXpgJWAlzcm2pb+XDl6ceF3F2EHTWXjUvLMrAVri8drws3B2IXMwommD6CcXcqK+mbAqQTEaPODV6q+G3clTdStKqF+kTE+az49hh+wctGU0fQCh4G2gv+cddizGKTUou/wIlD0uHk3OgLMT5/J7cQvWzyzKVa34LEboDg8pBgP+FXJxGTHLxpy+8K68oxhGssc9FLiOnWESxRcaCJgU4WMpJR6pof1VyJJTEODAd2eg5LWfIsTwVFfl8goDnuR1zY3H3IfMDkyv7a0kFYvUjk6XPBpv/hnVO22mfCyAZRVn3PzTqmw3c7W5Lk4TSRZHzVrZUNN2kMmfYZE4uP0IUmxDpvu47HmMatQlRDGekv439JPW/PJ0dD8SQpE= bub@DESKTOP-VEH8D7J
EOF
}
resource "proxmox_vm_qemu" "k8s_server_2" {
  depends_on    = [packer_image.ubuntu_server_jammy]
  name          = "k8s-server-2"
  desc          = "Ubuntu 22.04 LTS Server"
  target_node   = "pve"
  qemu_os       = "l26"
  
  agent         = 1

  clone         = packer_image.ubuntu_server_jammy.name
  cores         = 4
  sockets       = 2
  cpu           = "host"
  onboot        = true
  memory        = 8192

  scsihw        = "virtio-scsi-single"

  disk {
    storage = "local-lvm"
    type = "scsi"
    size = "32G"
  }

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=192.168.29.102/16,gw=192.168.29.1"
  nameserver = "192.168.29.1"
  ciuser = "bub"
  sshkeys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6CLheLTcYf7v23mF69qpGiTfCd7dmhMFTRh3IfqCppURO+W10rbCIebMEiT4bjF1QXAMwaXFRJ/FahIyWsMiojJ5yyCkJzspZuJyDUaLFQRQY0U0vS4Y7B5FqO5PpNXfPXN1uOXpgJWAlzcm2pb+XDl6ceF3F2EHTWXjUvLMrAVri8drws3B2IXMwommD6CcXcqK+mbAqQTEaPODV6q+G3clTdStKqF+kTE+az49hh+wctGU0fQCh4G2gv+cddizGKTUou/wIlD0uHk3OgLMT5/J7cQvWzyzKVa34LEboDg8pBgP+FXJxGTHLxpy+8K68oxhGssc9FLiOnWESxRcaCJgU4WMpJR6pof1VyJJTEODAd2eg5LWfIsTwVFfl8goDnuR1zY3H3IfMDkyv7a0kFYvUjk6XPBpv/hnVO22mfCyAZRVn3PzTqmw3c7W5Lk4TSRZHzVrZUNN2kMmfYZE4uP0IUmxDpvu47HmMatQlRDGekv439JPW/PJ0dD8SQpE= bub@DESKTOP-VEH8D7J
EOF
}

resource "proxmox_vm_qemu" "k8s_server_3" {
  depends_on    = [packer_image.ubuntu_server_jammy]
  name          = "k8s-server-3"
  desc          = "Ubuntu 22.04 LTS Server"
  target_node   = "pve"
  qemu_os       = "l26"
  
  agent         = 1

  clone         = packer_image.ubuntu_server_jammy.name
  cores         = 4
  sockets       = 2
  cpu           = "host"
  onboot        = true
  memory        = 8192

  scsihw        = "virtio-scsi-single"

  disk {
    storage = "local-lvm"
    type = "scsi"
    size = "32G"
  }

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=192.168.29.103/16,gw=192.168.29.1"
  nameserver = "192.168.29.1"
  ciuser = "bub"
  sshkeys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6CLheLTcYf7v23mF69qpGiTfCd7dmhMFTRh3IfqCppURO+W10rbCIebMEiT4bjF1QXAMwaXFRJ/FahIyWsMiojJ5yyCkJzspZuJyDUaLFQRQY0U0vS4Y7B5FqO5PpNXfPXN1uOXpgJWAlzcm2pb+XDl6ceF3F2EHTWXjUvLMrAVri8drws3B2IXMwommD6CcXcqK+mbAqQTEaPODV6q+G3clTdStKqF+kTE+az49hh+wctGU0fQCh4G2gv+cddizGKTUou/wIlD0uHk3OgLMT5/J7cQvWzyzKVa34LEboDg8pBgP+FXJxGTHLxpy+8K68oxhGssc9FLiOnWESxRcaCJgU4WMpJR6pof1VyJJTEODAd2eg5LWfIsTwVFfl8goDnuR1zY3H3IfMDkyv7a0kFYvUjk6XPBpv/hnVO22mfCyAZRVn3PzTqmw3c7W5Lk4TSRZHzVrZUNN2kMmfYZE4uP0IUmxDpvu47HmMatQlRDGekv439JPW/PJ0dD8SQpE= bub@DESKTOP-VEH8D7J
EOF
}