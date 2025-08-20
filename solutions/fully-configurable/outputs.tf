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
