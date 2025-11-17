##############################################################################
# Outputs
##############################################################################

output "cluster_id" {
  description = "ID of the cluster."
  value       = module.virtualization.cluster_id
}

output "cluster_name" {
  description = "Name of the cluster."
  value       = module.virtualization.cluster_name
}

output "cluster_crn" {
  description = "CRN of the cluster."
  value       = module.virtualization.cluster_crn
}

output "next_steps_text" {
  value       = "Your Red Hat OpenShift environment is ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Cluster"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/containers/cluster-management/clusters/${module.virtualization.cluster_id}/overview"
  description = "Primary URL"
}

