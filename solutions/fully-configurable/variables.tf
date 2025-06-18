########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

##############################################################################
# Cluster variables
##############################################################################

variable "cluster_id" {
  type        = string
  description = "The ID of the cluster to deploy the agents in."
}

variable "cluster_resource_group_id" {
  type        = string
  description = "The resource group ID of the cluster."
}

variable "cluster_config_endpoint_type" {
  description = "Specify the type of endpoint to use to access the cluster configuration. Possible values: `default`, `private`, `vpe`, `link`. The `default` value uses the default endpoint of the cluster."
  type        = string
  default     = "default"
  nullable    = false # use default if null is passed in
}

variable "wait_till" {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, `IngressReady` and `Normal`"
  type        = string
  default     = "Normal"
}

variable "wait_till_timeout" {
  description = "Timeout for wait_till in minutes."
  type        = number
  default     = 90
}

variable "vpc_file_default_storage_class" {
  description = "The name of the VPC File storage class which will be set as the default storage class."
  type        = string
  default     = "ibmc-vpc-file-metro-1000-iops"
}

variable "infra_node_selectors" {
  type = list(object({
    label  = string
    values = list(string)
  }))
  description = "List of infra node selectors to apply to HyperConverged pods."
  default = [{
    label  = "ibm-cloud.kubernetes.io/server-type"
    values = ["virtual", "physical"]
  }]
}

variable "workloads_node_selectors" {
  type = list(object({
    label  = string
    values = list(string)
  }))
  description = "List of workload node selectors to apply to HyperConverged pods."
  default = [{
    label  = "ibm-cloud.kubernetes.io/server-type"
    values = ["physical"]
  }]
}

# tflint-ignore: all
variable "ocp_version" {
  type        = string
  description = "Version of the OCP cluster to provision. OpenShift Virtualization is supported from ocp version 4.17 and above."
  default     = "4.17"

  validation {
    condition     = tonumber(var.ocp_version) >= 4.17
    error_message = "To install Red Hat OpenShift Virtualization, all worker node should be a bare metal server."
  }
}

# tflint-ignore: all
variable "default_worker_pool_machine_type" {
  type        = string
  description = "Specifies the machine type for the default worker pool. This determines the CPU, memory, and disk resources available to each worker node. For OpenShift Virtualization installation, machines should be VPC bare metal servers. Refer [IBM Cloud documentation for available machine types](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-flavors)"
  default     = "cx2d.metal.96x192"
}

# tflint-ignore: all
variable "default_worker_pool_workers_per_zone" {
  type        = number
  description = "Defines the number of worker nodes to provision in each zone for the default worker pool. Overall cluster must have at least 2 worker nodes, but individual worker pools may have fewer nodes per zone."
  default     = 2
}

# tflint-ignore: all
variable "default_worker_pool_operating_system" {
  type        = string
  description = "Provide the operating system for the worker nodes in the default worker pool. OpenShift Virtualization installation is supported only on RHCOS operating system. Refer [here](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift_versions) for supported Operating Systems"
  default     = "RHCOS"

  validation {
    condition     = var.default_worker_pool_operating_system == "RHCOS"
    error_message = "Invalid operating system. Allowed values is 'RHCOS'."
  }
}

# tflint-ignore: all
variable "additional_worker_pools" {
  type = list(object({
    vpc_subnets = optional(list(object({
      id         = string
      zone       = string
      cidr_block = string
    })), [])
    pool_name                     = string
    machine_type                  = string
    workers_per_zone              = number
    operating_system              = string
    labels                        = optional(map(string))
    minSize                       = optional(number)
    secondary_storage             = optional(string)
    maxSize                       = optional(number)
    enableAutoscaling             = optional(bool)
    additional_security_group_ids = optional(list(string))
  }))
  description = "List of additional worker pools with custom configurations to accommodate diverse VM workload requirements within the cluster. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-virtualization/blob/main/solutions/fully-configurable/DA_docs.md#options-with-worker-pools)"
  default     = []
}
