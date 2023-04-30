# Install:

### Prerequisites

We require terraform and packer for these operations, as well as a functioning proxmox server with either user/pass or a token set up.

### Terraform Configuration

1. Rename the `credentials.auto.tfvars.example` to `credentials.auto.tfvars` and update the values in the file to reflect your proxmox server.
2. Initialize terraform & Run the terraform apply in proxmox_templates
3. Initialize terraform & Run the terraform apply in proxmox_servers
4. Pull the kubectl config from the servers with `sudo sed "s/127.0.0.1/$(ip a | grep 101 | awk '{print $2}' | awk -F'/' '{print $1}')/" /etc/rancher/k3s/k3s.yaml`
5. Make sure you have an existing domain - still a manual step because of how long DNS takes to update for a new domain.
6. Initialize terraform & Run the terraform apply in deployments
7. Wait until certs resolve and visit https://whoami.${DOMAIN} and enjoy your TLS baby!

### Example init and apply

```
cd terraform/roots/proxmox_lxc
terraform init
terraform apply -auto-approve

```

You should see it take forever to build the template, then once it builds the template it will deploy three nodes that we can configure for kubernetes.

Assuming this goes well, we can update the packer with a second image that would use the base `ubuntu-server-jammy` and install the bootstrapping necessary for the kubernetes clusters (i.e. whatever we run to install k3s or whatever flavor of kubernetes cluster we want) without having to rebuild the template from scratch since it takes so long.

### Get the kubeconfig file

Once you know you've got a server, run the following to get the kubeconfig - adjust as needed to get the right IP address:

```
 sudo sed "s/127.0.0.1/$(ip a | grep 101 | awk '{print $2}' | awk -F'/' '{print $1}')/" /etc/rancher/k3s/k3s.yaml
```

# TODO:

1. target node should be an input variable
2. Add additional security configurations using https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_firewall_rules

# Bugs

### This is why we're using telmate/proxmox/2.9.11 instead of 2.9.14

https://gitlab.com/acidpizza-stuff/infra/terraform-modules/proxmox-vm-terraform-module

https://github.com/Telmate/terraform-provider-proxmox/issues/704

### Randomly failing at different steps

Had the unfortunate luck to find out that a hardware RAID controller is probably not going to work for the types of builds we're doing here - either get better raid controllers or get rekt, because you're gonna have a bumpy ride if you hit this.

Other causes of "random" failing can be DNS issues on your local network - if you're getting errors for network related stuff, make sure you're not blowing up your network or that it is happy - lots of packet loss or things that might block traffic can and will mess up your builds if you don't get it straightened out - including duplicate IP addresses - so if you're not going to use the

# References

https://www.youtube.com/watch?v=1nf3WOEFq1Y

https://github.com/christianlempa/boilerplates/tree/main/packer/proxmox

https://github.com/ChristianLempa/boilerplates/tree/main/terraform/proxmox

https://registry.terraform.io/providers/toowoxx/packer/0.14.0

https://registry.terraform.io/providers/Telmate/proxmox/latest

https://developer.hashicorp.com/packer/plugins/builders/proxmox

https://github.com/terraform-iaac/terraform-kubernetes-cert-manager

# Troubleshooting

## DNS

https://ranchermanager.docs.rancher.com/v2.5/troubleshooting/other-troubleshooting-tips/dns

## SSL

Trying to get letsencrypt working found some issues with the searchdomains being configured to bubtaylor.com, which was resolving back to my original server even when it was local, so letsencrypt was trying to resolve things and getting routed back to the traefik containers:

```
Status:
  Acme:
  Conditions:
    Last Transition Time:  2023-04-29T21:23:14Z
    Message:               Failed to register ACME account: Get "https://acme-v02.api.letsencrypt.org/directory": x509: certificate is valid for e7d2eeae9a70c65f91e98b5ae75aefd4.c66232ae56958a0adbadb62ac983f08d.traefik.default, not acme-v02.api.letsencrypt.org
    Observed Generation:   1
    Reason:                ErrRegisterACMEAccount
    Status:                False
    Type:                  Ready
Events:
  Type     Reason         Age                 From                         Message
  ----     ------         ----                ----                         -------
  Warning  ErrInitIssuer  44s (x6 over 3m9s)  cert-manager-clusterissuers  Error initializing issuer: Get "https://acme-v02.api.letsencrypt.org/directory": x509: certificate is 
valid for e7d2eeae9a70c65f91e98b5ae75aefd4.c66232ae56958a0adbadb62ac983f08d.traefik.default, not acme-v02.api.letsencrypt.org 
```

The fix for this issue was to update the searchdomains and restart the pods (including the kube-dns pod) so that they picked up a new search domain (In this case I set it to pve.local) - so the lesson here is make sure you don't set your INTERNAL search domains to an EXTERNAL search domain or you'll get weird DNS skips when things inherit the host configuration and start saying "Oh, look, you're local!"

# Provisioning

## local-exec provisioner error

If you're getting this error:

```
╷
│ Error: local-exec provisioner error
│
│   with null_resource.cluster_init,
│   on k3s_etcd_nodes.tf line 51, in resource "null_resource" "cluster_init":
│   51:   provisioner "local-exec" {
│
│ Error running command 'ssh -o StrictHostKeyChecking=no bub@192.168.29.101 'curl -sfL https://get.k3s.io | K3S_TOKEN=CBeafhx9KrfcholD sh -s - server --cluster-init'': exit status 255. Output: ssh: connect to host 192.168.29.101 port 22: Connection refused
│
╵ 
```

Try removing all your ~/.ssh/known_hosts that might reflect one of the servers.
