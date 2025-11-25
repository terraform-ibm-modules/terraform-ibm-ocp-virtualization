# Retrieve information about an existing VPC cluster
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = var.cluster_id
  resource_group_id = var.cluster_resource_group_id
  config_dir        = "${path.module}/kubeconfig"
  endpoint_type     = var.cluster_config_endpoint_type != "default" ? var.cluster_config_endpoint_type : null
}


#######################################################################################################################
# Virtualization
#######################################################################################################################

module "virtualization" {
  source                         = "../.."
  cluster_id                     = var.cluster_id
  cluster_resource_group_id      = var.cluster_resource_group_id
  cluster_config_endpoint_type   = var.cluster_config_endpoint_type
  wait_till                      = var.wait_till
  wait_till_timeout              = var.wait_till_timeout
  vpc_file_default_storage_class = var.vpc_file_default_storage_class
  infra_node_selectors           = var.infra_node_selectors
  workloads_node_selectors       = var.workloads_node_selectors
}
