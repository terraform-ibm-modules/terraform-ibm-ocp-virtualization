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
  validation {
    error_message = "The specified endpoint type is not valid. Specify one of the following types of endpoints: `default`, `private`, `vpe`, or `link`."
    condition     = contains(["default", "private", "vpe", "link"], var.cluster_config_endpoint_type)
  }
}

variable "wait_till" {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, `IngressReady` and `Normal`."
  type        = string
  default     = "Normal"

  validation {
    error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, `IngressReady` or `Normal`."
    condition = contains([
      "MasterNodeReady",
      "OneWorkerNodeReady",
      "IngressReady",
      "Normal"
    ], var.wait_till)
  }
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
  description = "List of infra node selectors to apply to HyperConverged pods. [Learn more](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)."
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
  description = "List of workload node selectors to apply to HyperConverged pods. [Learn more](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)."
  default = [{
    key    = "ibm-cloud.kubernetes.io/server-type"
    values = ["physical"]
  }]
}
