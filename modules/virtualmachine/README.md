# Virtual Machine Module

This Terraform module deploys KubeVirt Virtual Machines on OpenShift clusters with OpenShift Virtualization installed.

## Features

- Deploy VMs with customizable CPU, memory, and disk configurations
- Support for container disk images from any public registry
- Cloud-init integration for VM initialization
- SSH access via NodePort service
- Node placement control for bare metal or virtual nodes
- Live migration support with ReadWriteMany storage

## Prerequisites

- OpenShift cluster with OpenShift Virtualization installed
- Storage class that supports ReadWriteMany access mode (e.g., `ibmc-vpc-file-metro-1000-iops`)
- Helm provider configured

## Usage

```hcl
module "vm" {
  source = "../../modules/virtualmachine"

  # VM Configuration
  vm_name      = "my-vm"
  vm_namespace = "default"
  vm_cores     = 2
  vm_memory    = "4Gi"
  vm_running   = true

  # Storage Configuration
  storage_class = "ibmc-vpc-file-metro-1000-iops"
  disk_size     = "30Gi"

  # VM Image
  vm_image = "quay.io/kubevirt/fedora-cloud-container-disk-demo:latest"

  # Network Configuration
  network_type       = "pod"
  expose_ssh_service = true

  # VM Access
  ssh_public_key = file("~/.ssh/id_rsa.pub")
  vm_username    = "fedora"

  # Node Placement
  node_selector = {
    "ibm-cloud.kubernetes.io/server-type" = "physical"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vm_name | Name of the virtual machine | `string` | n/a | yes |
| vm_namespace | Kubernetes namespace for the VM | `string` | `"default"` | no |
| vm_cores | Number of CPU cores | `number` | `2` | no |
| vm_memory | Memory size (e.g., '4Gi') | `string` | `"4Gi"` | no |
| vm_running | Whether VM should be running | `bool` | `true` | no |
| storage_class | StorageClass for VM disks | `string` | `"ibmc-vpc-file-metro-1000-iops"` | no |
| disk_size | Root disk size (e.g., '30Gi') | `string` | `"30Gi"` | no |
| vm_image | Container disk image URL | `string` | `"quay.io/kubevirt/fedora-cloud-container-disk-demo:latest"` | no |
| network_type | Network type: pod, multus, or bridge | `string` | `"pod"` | no |
| expose_ssh_service | Expose SSH via NodePort | `bool` | `true` | no |
| ssh_public_key | SSH public key for VM access | `string` | `""` | no |
| cloud_init_user_data | Additional cloud-init YAML | `string` | `""` | no |
| vm_username | Default VM username | `string` | `"fedora"` | no |
| vm_password | VM user password | `string` | `""` | no |
| node_selector | Node selector labels | `map(string)` | `{"ibm-cloud.kubernetes.io/server-type" = "physical"}` | no |
| helm_timeout | Helm operation timeout (seconds) | `number` | `600` | no |
| helm_wait | Wait for resources to be ready | `bool` | `true` | no |
| create_namespace | Create namespace if it doesn't exist | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_name | Name of the deployed VM |
| vm_namespace | Namespace where VM is deployed |
| vm_status | Status of the Helm release |
| helm_release_version | Version of the Helm release |
| vm_access_info | Information for accessing the VM |

## Accessing the VM

### Via SSH (with port-forward)

```bash
# Create port-forward tunnel
kubectl port-forward -n <namespace> svc/<vm-name>-ssh 2222:22

# SSH to VM (in another terminal)
ssh -i <private-key> <username>@localhost -p 2222
```

### Via virtctl console

```bash
virtctl console <vm-name> -n <namespace>
```
