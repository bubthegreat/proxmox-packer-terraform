# Install:

### Prerequisites

We require terraform and packer for these operations, as well as a functioning proxmox server with either user/pass or a token set up.

### Terraform Configuration

1. Rename the `credentials.auto.tfvars.example` to `credentials.auto.tfvars` and update the values in the file to reflect your proxmox server.
2. Initialize terraform
3. Run the terraform apply

### Example init and apply

```
cd terraform/roots/proxmox_lxc
terraform init
terraform apply -auto-approve

```

You should see it take forever to build the template, then once it builds the template it will deploy three nodes that we can configure for kubernetes.

Assuming this goes well, we can update the packer with a second image that would use the base `ubuntu-server-jammy` and install the bootstrapping necessary for the kubernetes clusters (i.e. whatever we run to install k3s or whatever flavor of kubernetes cluster we want) without having to rebuild the template from scratch since it takes so long.

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
