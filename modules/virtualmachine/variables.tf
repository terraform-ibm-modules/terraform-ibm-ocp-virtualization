##############################################################################
# Virtual Machine Configuration
##############################################################################

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine to deploy."
}

variable "vm_namespace" {
  type        = string
  description = "Kubernetes namespace where the VM will be deployed."
  default     = "default"
}

variable "vm_cores" {
  type        = number
  description = "Number of CPU cores for the VM."
  default     = 2
  validation {
    condition     = var.vm_cores > 0 && var.vm_cores <= 32
    error_message = "VM cores must be between 1 and 32."
  }
}

variable "vm_memory" {
  type        = string
  description = "Memory size for the VM (e.g., '4Gi', '8Gi')."
  default     = "4Gi"
  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.vm_memory))
    error_message = "Memory must be specified in Mi or Gi (e.g., '4Gi')."
  }
}

variable "vm_running" {
  type        = bool
  description = "Whether the VM should be in running state after deployment."
  default     = true
}

##############################################################################
# Storage Configuration
##############################################################################

variable "storage_class" {
  type        = string
  description = "StorageClass to use for VM disks. Should support ReadWriteMany for live migration."
  default     = "ibmc-vpc-file-metro-1000-iops"
}

variable "disk_size" {
  type        = string
  description = "Size of the root disk (e.g., '30Gi', '50Gi')."
  default     = "30Gi"
  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.disk_size))
    error_message = "Disk size must be specified in Mi or Gi (e.g., '30Gi')."
  }
}

##############################################################################
# VM Image Configuration
##############################################################################

variable "vm_image" {
  type        = string
  description = "Container disk image for the VM. Use registry URL format (e.g., 'quay.io/kubevirt/fedora-cloud-container-disk-demo')."
  default     = "quay.io/kubevirt/fedora-cloud-container-disk-demo:latest"
}

##############################################################################
# Network Configuration
##############################################################################

variable "network_type" {
  type        = string
  description = "Network type for the VM: 'pod' (default pod network), 'multus' (additional networks), or 'bridge'."
  default     = "pod"
  validation {
    condition     = contains(["pod", "multus", "bridge"], var.network_type)
    error_message = "Network type must be one of: pod, multus, bridge."
  }
}

variable "expose_ssh_service" {
  type        = bool
  description = "Whether to expose SSH access via NodePort service."
  default     = true
}

##############################################################################
# VM Access Configuration
##############################################################################

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access. Will be added to authorized_keys."
  sensitive   = true
  default     = ""
}

variable "cloud_init_user_data" {
  type        = string
  description = "Additional cloud-init user data script (YAML format)."
  default     = ""
}

variable "vm_username" {
  type        = string
  description = "Default username for the VM."
  default     = "fedora"
}

variable "vm_password" {
  type        = string
  description = "Password for the VM user (optional, SSH key recommended)."
  sensitive   = true
  default     = ""
}

##############################################################################
# Node Placement Configuration
##############################################################################

variable "node_selector" {
  type        = map(string)
  description = "Node selector labels for VM placement."
  default = {
    "ibm-cloud.kubernetes.io/server-type" = "physical"
  }
}

##############################################################################
# Helm Configuration
##############################################################################

variable "helm_timeout" {
  type        = number
  description = "Timeout in seconds for Helm operations."
  default     = 600
}

variable "helm_wait" {
  type        = bool
  description = "Wait for all resources to be ready before marking the release as successful."
  default     = true
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace if it doesn't exist."
  default     = true
}
