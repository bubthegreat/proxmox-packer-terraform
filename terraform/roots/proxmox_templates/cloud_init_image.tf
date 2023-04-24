resource "null_resource" "cloud_init_image_download" {
  provisioner "remote-exec" {
    inline = [
      "qm destroy 9001",
      "apt -y install libguestfs-tools",
      "wget http://cloud-images.ubuntu.com/releases/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img -O /var/lib/vz/template/iso/ubuntu-22.04-server-cloudimg-amd64.img",
      "virt-customize -a /var/lib/vz/template/iso/ubuntu-22.04-server-cloudimg-amd64.img --install qemu-guest-agent",
      "echo '${var.vm_public_key}' > /root/id_rsa.pub",
      "chmod 600 /root/id_rsa.pub",
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

resource "null_resource" "cloud_init_image" {
  depends_on = [
    null_resource.cloud_init_image_download
  ]
  provisioner "remote-exec" {
    inline = [
      "qm create 9001 --memory 8192 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci",
      "qm set 9001 --name ubuntu-22.04-server-cloud-init-template",
      "qm set 9001 --scsi0 local-lvm:0,import-from=/var/lib/vz/template/iso/ubuntu-22.04-server-cloudimg-amd64.img",
      "qm resize 9001 scsi0 +32G",
      "qm set 9001 --ide2 local-lvm:cloudinit",
      "qm set 9001 --boot order=scsi0",
      "qm set 9001 -ipconfig0 ip=dhcp",
      "qm set 9001 -nameserver ${var.cluster_dns}",
      "qm set 9001 -memory 8192",
      "qm set 9001 -sockets 2",
      "qm set 9001 -cores 2",
      "qm set 9001 --sshkeys /root/id_rsa.pub",
      "qm set 9001 --onboot 1",
      "qm set 9001 --agent 1",
      "qm set 9001 -ciuser bub",
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

resource "null_resource" "cloud_init_template" {
  depends_on = [
    null_resource.cloud_init_image
  ]
  provisioner "remote-exec" {
    inline = [
      "qm set 9001 -cipassword '${var.proxmox_api_password}'",
      "qm template 9001",
      "sleep 10",
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