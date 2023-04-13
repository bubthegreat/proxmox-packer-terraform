# To get this running:

rename the `credentials.auto.tfvars.example` to `credentials.auto.tfvars` and update the values in the file to reflect your proxmox server.

Run the terraform:

```
cd terraform/roots/proxmox_server
terraform init
terraform apply -auto-approve

```

You should see it take forever to build the template, then once it builds the template it will deploy three nodes that we can configure for kubernetes.

Assuming this goes well, we can update the packer with a second image that would use the base `ubuntu-server-jammy` and install the bootstrapping necessary for the kubernetes clusters (i.e. whatever we run to install k3s or whatever flavor of kubernetes cluster we want) without having to rebuild the template from scratch since it takes so long.
