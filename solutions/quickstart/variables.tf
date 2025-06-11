########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: wx-0205-openshift. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)"

  validation {
    condition = var.prefix == null || var.prefix == "" ? true : alltrue([
      can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)), length(regexall("--", var.prefix)) == 0
    ])
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the cluster."
  default     = "Default"
}

variable "region" {
  type        = string
  description = "Region where the all cluster resources will be provisioned."
  default     = "us-south"
}

variable "vpc_resource_tags" {
  type        = list(string)
  description = "Metadata labels describing this vpc deployment, i.e. test."
  default     = []
}

variable "cluster_resource_tags" {
  type        = list(string)
  description = "Metadata labels describing this cluster deployment, i.e. test."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the resources created by the module."
  default     = []
}

##############################################################################
# VPC variables
##############################################################################

variable "address_prefix" {
  description = "The IP range that will be defined for the VPC for a certain location. Use only with manual address prefixes."
  type        = string
  default     = "10.10.10.0/24"
}

variable "zone" {
  type        = number
  description = "Specify the zone to which the cluster will be deployed."
  default     = 1
  validation {
    condition     = contains([1, 2, 3], var.zone)
    error_message = "Each region has only 3 zones."
  }
}
##############################################################################
# Cluster variables
##############################################################################

variable "cluster_name" {
  type        = string
  description = "The name of the new IBM Cloud OpenShift Cluster. If a `prefix` input variable is specified, it is added to this name in the `<prefix>-value` format."
  default     = "openshift"
}

variable "ocp_version" {
  type        = string
  description = "Version of the OCP cluster to provision"
  default     = "4.17"

  validation {
    condition     = tonumber(var.ocp_version) >= 4.17
    error_message = "To install Red Hat OpenShift Virtualization, all `ocp_version` should be higher than `4.17`."
  }
}

variable "ocp_entitlement" {
  type        = string
  description = "Value that is applied to the entitlements for OCP cluster provisioning"
  default     = null
}

variable "cluster_ready_when" {
  type        = string
  description = "The cluster is ready based on one of the following:: MasterNodeReady (not recommended), OneWorkerNodeReady, Normal, IngressReady."
  default     = "IngressReady"
}

variable "workers_per_zone" {
  type        = number
  description = "Defines the number of worker nodes to provision in each zone for the default worker pool. Overall cluster must have at least 2 worker nodes."
  default     = 2

  validation {
    condition     = var.workers_per_zone >= 2
    error_message = "Minimum of 2 is allowed when using single zone."
  }
}

variable "machine_type" {
  type        = string
  description = "Specifies the machine type for the default worker pool. This determines the CPU, memory, and disk resources available to each worker node. For OpenShift Virtualization installation, machines should be VPC bare metal servers. Refer [IBM Cloud documentation for available machine types](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-flavors)"
  default     = "cx2d.metal.96x192"
}

variable "operating_system" {
  type        = string
  description = "Provide the operating system for the worker nodes in the default worker pool. OpenShift Virtualization installation is supported only on RHCOS operating system. Refer [here](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift_versions) for supported Operating Systems"
  default     = "RHCOS"

  validation {
    condition     = var.operating_system == "RHCOS"
    error_message = "Invalid operating system. Allowed values is 'RHCOS'."
  }
}

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
  default = {
    openshift-data-foundation = {
      parameters_json = "{\"osdStorageClassName\":\"localblock\",\"odfDeploy\":\"true\",\"autoDiscoverDevices\":\"true\"}"
    }
    vpc-file-csi-driver = {
      version = "2.0"
    }
  }
}

##############################################################################
# virtualization variables
##############################################################################

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
