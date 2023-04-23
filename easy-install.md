Well, this was easier: 


```bash
# Download the cloud init ready image from ubuntu
wget http://cloud-images.ubuntu.com/releases/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img -P /root

# Create a public key file with your public key
echo 'your-pub-key' > /root/id_rsa.pub

# Create the initial VM that will be converted to a template and set it's name
qm create 9001 --memory 8192 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
qm set 9001 --name ubuntu-22.04-server-cloud-init-template

# Create the disk from the cloud-init image and then resize the drive by your desired
# size so that you don't have just a 2GB root partition.
qm set 9001 --scsi0 local-lvm:0,import-from=/root/ubuntu-22.04-server-cloudimg-amd64.img
qm resize 9001 scsi0 +32G

# set storage for cloud init device and set boot order to the scsi0 drive we set up
qm set 9001 --ide2 local-lvm:cloudinit
qm set 9001 --boot order=scsi0

# Configure all them settings baby
qm set 9001 -ipconfig0 ip=dhcp
qm set 9001 -ciuser bub
qm set 9001 -cipassword 'secretpass'
qm set 9001 -nameserver 8.8.8.8
qm set 9001 -memory 8192
qm set 9001 -sockets 2
qm set 9001 -cores 2
qm set 9001 --sshkeys /root/id_rsa.pub
qm template 9001

# Deploy x number of servers
for ID in 1 2 3; do
    VMID="20$ID"
    qm clone 9001 $VMID --name k3s-server-$ID
    qm set $VMID --name k3s-server-$ID
    qm set $VMID --net0 model=virtio,bridge=vmbr0
    qm set $VMID --ipconfig0 ip=192.168.29.10$ID/24,gw=192.168.29.1
    qm set $VMID --searchdomain bubtaylor.com
    qm set $VMID --nameserver 8.8.8.8
    qm set $VMID --onboot 1
    qm set $VMID --agent 1
    qm start $VMID
done

# On controller:
curl -sfL https://get.k3s.io | K3S_TOKEN=12345 INSTALL_K3S_EXEC="server" sh -s -

# On workers
curl -sfL https://get.k3s.io | K3S_TOKEN="12345" K3S_URL=https://192.168.29.101 sh -s -

```
