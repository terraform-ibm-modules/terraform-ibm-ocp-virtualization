#######################################################################################################################
# Resource Group
#######################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.1"
  existing_resource_group_name = var.existing_resource_group_name
}

locals {
  prefix       = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  cluster_name = "${local.prefix}${var.cluster_name}"
}

#############################################################################
# Provision VPC
#############################################################################

locals {
  subnets = {
    for count in range(1, 4) :
    "zone-${count}" => count == var.zone ? [
      {
        name           = "${var.prefix}-subnet-a"
        cidr           = var.address_prefix
        public_gateway = true
        acl_name       = "${var.prefix}-acl"
      }
    ] : []
  }

  public_gateway = {
    for count in range(1, 4) :
    "zone-${count}" => count == var.zone
  }
}

module "vpc" {
  source              = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version             = "7.23.13"
  resource_group_id   = module.resource_group.resource_group_id
  region              = var.region
  name                = "vpc"
  prefix              = var.prefix
  tags                = var.vpc_resource_tags
  subnets             = local.subnets
  use_public_gateways = local.public_gateway
  network_acls = [{
    name                         = "${var.prefix}-acl"
    add_ibm_cloud_internal_rules = true
    add_vpc_connectivity_rules   = true
    prepend_ibm_rules            = true
    rules = [{
      name        = "inbound"
      action      = "allow"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      direction   = "inbound"
      },
      {
        name        = "outbound"
        action      = "allow"
        source      = "0.0.0.0/0"
        destination = "0.0.0.0/0"
        direction   = "outbound"
      }
    ]
    }
  ]
}

#############################################################################
# Provision Cluster
#############################################################################

locals {
  worker_pools = [
    {
      subnet_prefix    = "zone-${var.zone}"
      pool_name        = "default"
      machine_type     = var.machine_type
      workers_per_zone = var.workers_per_zone
      operating_system = var.operating_system
    }
  ]

  addons = { for key, value in var.addons :
    key => value != null ? {
      version         = lookup(value, "version", null) == null && key == "openshift-data-foundation" ? "${var.ocp_version}.0" : lookup(value, "version", null)
      parameters_json = lookup(value, "parameters_json", null)
    } : null
  }
}

module "ocp_base" {
  source                              = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version                             = "3.49.0"
  resource_group_id                   = module.resource_group.resource_group_id
  region                              = var.region
  tags                                = var.cluster_resource_tags
  cluster_name                        = local.cluster_name
  force_delete_storage                = true
  vpc_id                              = module.vpc.vpc_id
  vpc_subnets                         = module.vpc.subnet_detail_map
  ocp_version                         = var.ocp_version
  worker_pools                        = local.worker_pools
  access_tags                         = var.access_tags
  ocp_entitlement                     = var.ocp_entitlement
  addons                              = local.addons
  cluster_ready_when                  = var.cluster_ready_when
  disable_outbound_traffic_protection = true # set as True to enable outbound traffic; required for accessing Operator Hub in the OpenShift console.
}

#######################################################################################################################
# Virtualization
#######################################################################################################################

# Retrieve information about an existing VPC cluster
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = module.ocp_base.cluster_id
  resource_group_id = module.ocp_base.resource_group_id
  config_dir        = "${path.module}/kubeconfig"
  endpoint_type     = var.cluster_config_endpoint_type != "default" ? var.cluster_config_endpoint_type : null
}

module "virtualization" {
  depends_on                     = [module.ocp_base]
  source                         = "../.."
  cluster_id                     = module.ocp_base.cluster_id
  cluster_resource_group_id      = module.ocp_base.resource_group_id
  cluster_config_endpoint_type   = var.cluster_config_endpoint_type
  wait_till                      = var.wait_till
  wait_till_timeout              = var.wait_till_timeout
  vpc_file_default_storage_class = var.vpc_file_default_storage_class
  infra_node_selectors           = var.infra_node_selectors
  workloads_node_selectors       = var.workloads_node_selectors
}
