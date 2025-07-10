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
    key    = string
    values = list(string)
  }))
  description = "List of infra node selectors to apply to HyperConverged pods. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-virtualization/blob/main/solutions/quickstart/DA_docs.md#options-with-infra)"
  default = [{
    key    = "ibm-cloud.kubernetes.io/server-type"
    values = ["virtual", "physical"]
  }]
}

variable "workloads_node_selectors" {
  type = list(object({
    key    = string
    values = list(string)
  }))
  description = "List of workload node selectors to apply to HyperConverged pods. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-virtualization/blob/main/solutions/quickstart/DA_docs.md#options-with-workload)"
  default = [{
    key    = "ibm-cloud.kubernetes.io/server-type"
    values = ["physical"]
  }]
}
# tflint-ignore: all
variable "addons" {
  type = object({
    debug-tool = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
    image-key-synchronizer = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
    openshift-data-foundation = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
    vpc-file-csi-driver = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
    static-route = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
    cluster-autoscaler = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
    vpc-block-csi-driver = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
    ibm-storage-operator = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
    openshift-ai = optional(object({
      version         = optional(string)
      parameters_json = optional(string)
    }))
  })
  description = "Map of OCP cluster add-on versions to install (NOTE: The 'vpc-block-csi-driver' add-on is installed by default for VPC clusters and 'ibm-storage-operator' is installed by default in OCP 4.15 and later, however you can explicitly specify it here if you wish to choose a later version than the default one). For full list of all supported add-ons and versions, see https://cloud.ibm.com/docs/containers?topic=containers-supported-cluster-addon-versions. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-virtualization/blob/main/solutions/quickstart/DA_docs.md#options-with-addons)"
  nullable    = false
  # See, https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6290
  default = {
    openshift-data-foundation = {
      parameters_json = "{\"osdStorageClassName\":\"localblock\",\"odfDeploy\":\"true\",\"autoDiscoverDevices\":\"true\"}"
    }
    vpc-file-csi-driver = {
      version = "2.0"
    }
  }
}

# # tflint-ignore: all
variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-0205-openshift. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

# # tflint-ignore: all
# variable "default_worker_pool_workers_per_zone" {
#   type        = number
#   description = "Defines the number of worker nodes to provision in each zone for the default worker pool. Overall cluster must have at least 2 worker nodes, but individual worker pools may have fewer nodes per zone."
#   default     = 2
# }

# # tflint-ignore: all
# variable "default_worker_pool_operating_system" {
#   type        = string
#   description = "Provide the operating system for the worker nodes in the default worker pool. OpenShift Virtualization installation is supported only on RHCOS operating system. Refer [here](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift_versions) for supported Operating Systems"
#   default     = "RHCOS"

#   validation {
#     condition     = var.default_worker_pool_operating_system == "RHCOS"
#     error_message = "Invalid operating system. Allowed values is 'RHCOS'."
#   }
# }

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
