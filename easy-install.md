Well, this was easier:

```bash
# Download the cloud init ready image from ubuntu
wget http://cloud-images.ubuntu.com/releases/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img -O /var/lib/vz/template/iso/ubuntu-22.04-server-cloudimg-amd64.img

# Create a public key file with your public key
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6CLheLTcYf7v23mF69qpGiTfCd7dmhMFTRh3IfqCppURO+W10rbCIebMEiT4bjF1QXAMwaXFRJ/FahIyWsMiojJ5yyCkJzspZuJyDUaLFQRQY0U0vS4Y7B5FqO5PpNXfPXN1uOXpgJWAlzcm2pb+XDl6ceF3F2EHTWXjUvLMrAVri8drws3B2IXMwommD6CcXcqK+mbAqQTEaPODV6q+G3clTdStKqF+kTE+az49hh+wctGU0fQCh4G2gv+cddizGKTUou/wIlD0uHk3OgLMT5/J7cQvWzyzKVa34LEboDg8pBgP+FXJxGTHLxpy+8K68oxhGssc9FLiOnWESxRcaCJgU4WMpJR6pof1VyJJTEODAd2eg5LWfIsTwVFfl8goDnuR1zY3H3IfMDkyv7a0kFYvUjk6XPBpv/hnVO22mfCyAZRVn3PzTqmw3c7W5Lk4TSRZHzVrZUNN2kMmfYZE4uP0IUmxDpvu47HmMatQlRDGekv439JPW/PJ0dD8SQpE= bub@DESKTOP-VEH8D7J' > /root/id_rsa.pub

# Create the initial VM that will be converted to a template and set it's name
qm create 9001 --memory 8192 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
qm set 9001 --name ubuntu-22.04-server-cloud-init-template

# Create the disk from the cloud-init image and then resize the drive by your desired
# size so that you don't have just a 2GB root partition.
qm set 9001 --scsi0 local-lvm:0,import-from=/var/lib/vz/template/iso/ubuntu-22.04-server-cloudimg-amd64.img
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

# Give it time for templating to finish
sleep 10
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

# Give it time to finish the cloud-init
sleep 20

for ID in 1; do
    VMID="20$ID"
    ssh -o StrictHostKeyChecking=no bub@192.168.29.10$ID 'curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server --cluster-init' 
done

for ID in 2 3; do
    VMID="20$ID"
    ssh -o StrictHostKeyChecking=no bub@192.168.29.10$ID 'curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server --server https://192.168.29.101:6443'
done


# Deploy x number of servers
for ID in 4 5 6 7 8; do
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

# Give it time to finish the cloud-init
sleep 20

# Deploy x number of servers
for ID in 4 5 6 7 8; do
    VMID="20$ID"
    echo "Updating VM $VMID"
    ssh -o StrictHostKeyChecking=no bub@192.168.29.10$ID 'curl -sfL https://get.k3s.io | sh -s - agent --token SECRET --server https://192.168.29.101:6443'
done

# After on your local host pull down the kube config - this overwrites any you have locally so
# back up your old one: 
# ssh bub@192.168.29.101 'sudo cat /etc/rancher/k3s/k3s.yaml' > ~/.kube/config

```
