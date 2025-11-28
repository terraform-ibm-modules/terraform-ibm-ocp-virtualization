##############################################################################
# Outputs
##############################################################################

output "cluster_id" {
  description = "ID of the cluster."
  value       = data.ibm_container_vpc_cluster.cluster.id
}

output "cluster_name" {
  description = "Name of the cluster."
  value       = data.ibm_container_vpc_cluster.cluster.name
}

output "cluster_crn" {
  description = "CRN of the cluster."
  value       = data.ibm_container_vpc_cluster.cluster.crn
}

output "ingress_hostname" {
  description = "Ingress hostname for the cluster"
  value       = data.ibm_container_vpc_cluster.cluster.ingress_hostname
}
##############################################################################
