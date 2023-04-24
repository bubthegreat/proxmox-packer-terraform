# https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#argument-reference
# https://registry.terraform.io/modules/sdhibit/cloud-init-vm/proxmox/latest/examples/ubuntu_single_vm


resource "random_string" "cluster_join_token" {
  length            = 16
  special           = false

}

resource "proxmox_vm_qemu" "k8s_etcd_servers" {

  count         = 3
  vmid          = "${100 + count.index + 1}"
  name          = "k3s-etcd-${100 + count.index + 1}"
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
  ipconfig0 = "ip=192.168.29.${100 + count.index + 1}/24,gw=192.168.29.1"
  nameserver = "8.8.8.8"
  ciuser = "${var.vm_username}"
  sshkeys = <<EOF
${var.vm_public_key}
  EOF
}

# Have to start somewhere - so let's start with our first cluster node as etcd!
resource "null_resource" "cluster_init" {
  depends_on = [
    proxmox_vm_qemu.k8s_etcd_servers
  ]
  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no ${var.vm_username}@${var.cluster_join_ip} 'curl -sfL https://get.k3s.io | K3S_TOKEN=${random_string.cluster_join_token.result} sh -s - server --cluster-init'"
  }
}


# The etcd nodes weren't very stable when I let them all join at once, so we join them one at a time - it's hacky, but it works consistently.

resource "null_resource" "cluster_join_2" {
  depends_on = [
    null_resource.cluster_init
  ]

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no ${var.vm_username}@192.168.29.102 'curl -sfL https://get.k3s.io | K3S_TOKEN=${random_string.cluster_join_token.result} sh -s - server --server https://${var.cluster_join_ip}:6443'"
  }
}

resource "null_resource" "cluster_join_3" {
  depends_on = [
    null_resource.cluster_join_2
  ]

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no ${var.vm_username}@192.168.29.103 'curl -sfL https://get.k3s.io | K3S_TOKEN=${random_string.cluster_join_token.result} sh -s - server --server https://${var.cluster_join_ip}:6443'"
  }
}
