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
  value       = "Your Red Hat OpenShift cluster is ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "OpenShift cluster web console"
  description = "Primary label"
}

output "next_step_primary_url" {
  # Prefer the provider data source's ingress hostname; fall back to module if available
  value       = "https://console-openshift-console.${data.ibm_container_vpc_cluster.cluster.ingress_hostname}/dashboards"
  description = "primary url"
}

output "ingress_hostname" {
  description = "The hostname assigned to the Cluster's Ingress subdomain for external access."
  value       = data.ibm_container_vpc_cluster.cluster.ingress_hostname
}

output "next_step_secondary_label" {
  value       = "Red Hat OpenShift cluster overview page"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/containers/cluster-management/clusters/${module.virtualization.cluster_id}/overview"
  description = "Secondary URL"
}
