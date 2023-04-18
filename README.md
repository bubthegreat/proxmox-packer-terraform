# Install:

### Prerequisites

We require terraform and packer for these operations, as well as a functioning proxmox server with either user/pass or a token set up.

### Terraform Configuration

1. Rename the `credentials.auto.tfvars.example` to `credentials.auto.tfvars` and update the values in the file to reflect your proxmox server.
2. Initialize terraform
3. Run the terraform apply

### Example init and apply

```
cd terraform/roots/proxmox_server
terraform init
terraform apply -auto-approve

```

You should see it take forever to build the template, then once it builds the template it will deploy three nodes that we can configure for kubernetes.

Assuming this goes well, we can update the packer with a second image that would use the base `ubuntu-server-jammy` and install the bootstrapping necessary for the kubernetes clusters (i.e. whatever we run to install k3s or whatever flavor of kubernetes cluster we want) without having to rebuild the template from scratch since it takes so long.

Output from the `terraform apply -auto-approve`:

```
PS C:\Users\bubth\Development\homelab\terraform\roots\proxmox_server> terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # packer_image.ubuntu_server_jammy will be created
  + resource "packer_image" "ubuntu_server_jammy" {
      + build_uuid = (known after apply)
      + directory  = "../../../packer/ubuntu-server-jammy/"
      + file       = "ubuntu-server-jammy.pkr.hcl"
      + id         = (known after apply)
      + name       = "ubuntu-server-jammy"
      + variables  = {
          + "proxmox_api_password" = (sensitive)
          + "proxmox_api_url"      = "https://192.168.29.153:8006/api2/json"
          + "proxmox_api_user"     = "root@pam"
        }
    }

  # proxmox_vm_qemu.k8s_server_1 will be created
  + resource "proxmox_vm_qemu" "k8s_server_1" {
      + additional_wait           = 0
      + agent                     = 1
      + automatic_reboot          = true
      + balloon                   = 0
************** SNIPPED **************
          + rate      = (known after apply)
          + tag       = -1
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.
packer_image.ubuntu_server_jammy: Creating...
packer_image.ubuntu_server_jammy: Still creating... [10s elapsed]
************** SNIP 15 minutes of waiting **************
packer_image.ubuntu_server_jammy: Still creating... [16m11s elapsed]
packer_image.ubuntu_server_jammy: Creation complete after 16m15s
proxmox_vm_qemu.k8s_server_1: Creating...
proxmox_vm_qemu.k8s_server_2: Creating...
proxmox_vm_qemu.k8s_server_3: Creating...
proxmox_vm_qemu.k8s_server_2: Still creating... [10s elapsed]
proxmox_vm_qemu.k8s_server_1: Still creating... [10s elapsed]
proxmox_vm_qemu.k8s_server_3: Still creating... [10s elapsed]
************** SNIP 4 minutes of waiting **************
proxmox_vm_qemu.k8s_server_2: Still creating... [3m40s elapsed]
proxmox_vm_qemu.k8s_server_1: Still creating... [3m40s elapsed]
proxmox_vm_qemu.k8s_server_3: Still creating... [3m40s elapsed]
proxmox_vm_qemu.k8s_server_1: Creation complete after 3m47s [id=pve/qemu/100]
proxmox_vm_qemu.k8s_server_2: Creation complete after 3m47s [id=pve/qemu/103]
proxmox_vm_qemu.k8s_server_3: Creation complete after 3m48s [id=pve/qemu/102]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
PS C:\Users\bubth\Development\homelab\terraform\roots\proxmox_server>
```

# Notes

This is working on a windows box, but does not work on WSL2 because of the network forwarding shenanigans that packer requires for the cloud-init.

# TODO:

1. Update the user-data to be built from a template instead of being a raw file, with inputs for things like timezone, users, public key, etc.
2. Add options for cores and sockets and things like that into the vars and dump those into a module so we don't have to build out the inventory for each server object
3. Add notes in the resources
4. Convert sshkeys to variables
5. target node should be an input variable
6. Add storage configurations that will be consistent to terraform provider so your proxmox server is consistently configured for our kubernetes cluster even if it's already in use.

# Debugging

If you're running into issues with the packer build, you can build the image manually with some debug options instead of through the terraform resources, for example, if you need to debug a command live and want to use the ask flag, the packer terraform resource doesn't currently support that, so you will have to do it manually:

```powershell
PS C:\Users\bubth\Development\homelab\packer\ubuntu-server-jammy-docker> packer build -var="proxmox_api_user=root@pam" -var="proxmox_api_password=<super_secret>" -var="proxmox_api_url=https://192.168.29.153:8006/api2/json" -on-error=ask .\ubuntu-server-jammy-docker.pkr.hcl
```

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
