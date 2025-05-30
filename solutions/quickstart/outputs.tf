########################################################################################################################
# Outputs
########################################################################################################################

output "cluster_name" {
  value       = module.ocp_base.cluster_name
  description = "The name of the provisioned OpenShift cluster."
}

output "cluster_id" {
  value       = module.ocp_base.cluster_id
  description = "The unique identifier assigned to the provisioned OpenShift cluster."
}

output "cluster_crn" {
  description = "The Cloud Resource Name (CRN) of the provisioned OpenShift cluster."
  value       = module.ocp_base.cluster_crn
}

output "workerpools" {
  description = "A list of worker pools associated with the provisioned cluster"
  value       = module.ocp_base.workerpools
}

output "ocp_version" {
  description = "The version of OpenShift running on the provisioned cluster."
  value       = module.ocp_base.ocp_version
}

output "cos_crn" {
  description = "The Cloud Resource Name (CRN) of the Object Storage instance associated with the cluster."
  value       = module.ocp_base.cos_crn
}

output "vpc_id" {
  description = "The ID of the Virtual Private Cloud (VPC) in which the cluster is deployed."
  value       = module.ocp_base.vpc_id
}

output "region" {
  description = "The IBM Cloud region where the cluster is deployed."
  value       = module.ocp_base.region
}

output "resource_group_id" {
  description = "The ID of the resource group where the cluster is deployed."
  value       = module.ocp_base.resource_group_id
}

output "ingress_hostname" {
  description = "The hostname assigned to the Cluster's Ingress subdomain for external access."
  value       = module.ocp_base.ingress_hostname
}

output "public_service_endpoint_url" {
  description = "The public service endpoint URL for accessing the cluster over the internet."
  value       = module.ocp_base.public_service_endpoint_url
}

output "master_url" {
  description = "The API endpoint URL for the Kubernetes master node of the cluster."
  value       = module.ocp_base.master_url
}

output "operating_system" {
  description = "The operating system used by the worker nodes in the default worker pool."
  value       = module.ocp_base.operating_system
}

output "master_status" {
  description = "The current status of the Kubernetes master node in the cluster."
  value       = module.ocp_base.master_status
}
