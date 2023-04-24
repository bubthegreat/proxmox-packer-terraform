
variable "worker_count" {
  default = 5
}

resource "proxmox_vm_qemu" "k3s_worker_nodes" {
  count         = var.worker_count
  vmid          = "${110 + count.index + 1}"
  name          = "k3s-worker-${110 + count.index + 1}"
  desc          = "Ubuntu 22.04 LTS Server"
  target_node   = "pve"
  qemu_os       = "l26"
  
  agent         = 1

  clone         = "ubuntu-22.04-server-cloud-init-template"
  cores         = 4
  sockets       = 2
  cpu           = "host"
  onboot        = true
  memory        = 8192

  scsihw        = "virtio-scsi-single"
  full_clone = false

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=192.168.29.${110 + count.index + 1}/24,gw=192.168.29.1"
  nameserver = "8.8.8.8"
  ciuser = "${var.vm_username}"
  sshkeys = <<EOF
${var.vm_public_key}
  EOF
}

resource "null_resource" "k3s_worker_nodes_cluster_joins" {
  count         = var.worker_count
  depends_on = [
    proxmox_vm_qemu.k3s_worker_nodes,
    proxmox_vm_qemu.k8s_etcd_servers,
    null_resource.cluster_join_3
  ]
  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no ${var.vm_username}@192.168.29.${110 + count.index + 1} 'curl -sfL https://get.k3s.io | K3S_TOKEN=${random_string.cluster_join_token.result} sh -s - agent --server https://${var.cluster_join_ip}:6443'"
  }
}