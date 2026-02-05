# Retrieve information about an existing VPC cluster
data "ibm_container_vpc_cluster" "cluster" {
  name              = var.cluster_id
  resource_group_id = var.cluster_resource_group_id
  wait_till         = var.wait_till
  wait_till_timeout = var.wait_till_timeout
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = var.cluster_id
  resource_group_id = var.cluster_resource_group_id
  config_dir        = "${path.module}/kubeconfig"
  endpoint_type     = var.cluster_config_endpoint_type != "default" ? var.cluster_config_endpoint_type : null
}

resource "kubernetes_config_map_v1_data" "disable_default_storageclass" {
  metadata {
    name      = "addon-vpc-block-csi-driver-configmap"
    namespace = "kube-system"
  }

  data = {
    "IsStorageClassDefault" = "false"
  }

  force = true
}

resource "terraform_data" "install_required_binaries" {
  count = var.install_required_binaries ? 1 : 0
  triggers_replace    = {
    KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
  }
  provisioner "local-exec" {
    command     = "${path.module}/scripts/install-binaries.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "terraform_data" "config_map_status" {
  provisioner "local-exec" {
    command     = "${path.module}/scripts/get_config_map_status.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}

resource "kubernetes_config_map_v1_data" "set_vpc_file_default_storage_class" {
  depends_on = [terraform_data.config_map_status]
  metadata {
    name      = "addon-vpc-file-csi-driver-configmap"
    namespace = "kube-system"
  }

  data = {
    "SET_DEFAULT_STORAGE_CLASS" = var.vpc_file_default_storage_class
  }

  force = true
}

resource "terraform_data" "enable_catalog_source" {
  provisioner "local-exec" {
    command     = "${path.module}/scripts/enable_catalog_source.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}

########################################################################################################################
# Subscribing to the OpenShift Virtualization catalog
########################################################################################################################

locals {
  subscription_version        = "v4.19.15"
  subscription_chart_location = "${path.module}/chart/subscription"
  namespace                   = "openshift-cnv" # This is hard-coded because using any other namespace will break the virtualization.
}

resource "helm_release" "subscription" {
  depends_on       = [terraform_data.enable_catalog_source]
  name             = "${data.ibm_container_vpc_cluster.cluster.name}-subscription"
  chart            = local.subscription_chart_location
  namespace        = local.namespace
  create_namespace = true
  timeout          = 1200
  wait             = true
  recreate_pods    = true
  force_update     = true

  set = [
    {
      name  = "subscription.version"
      type  = "string"
      value = local.subscription_version
    }
  ]
}

#########################################################################################################################
# Deploying the OpenShift Virtualization Operator
########################################################################################################################

locals {
  operator_chart_location = "${path.module}/chart/operator"
  binaries_path           = "/tmp"
}

resource "time_sleep" "wait_for_subscription" {
  depends_on = [helm_release.subscription]

  create_duration = "240s"
}

resource "helm_release" "operator" {
  depends_on       = [time_sleep.wait_for_subscription]
  name             = "${data.ibm_container_vpc_cluster.cluster.name}-operator"
  chart            = local.operator_chart_location
  namespace        = local.namespace
  create_namespace = false
  timeout          = 1200
  wait             = true
  recreate_pods    = true
  force_update     = true
  disable_webhooks = true

  values = [
    yamlencode({
      infra_node_selectors     = var.infra_node_selectors
      workloads_node_selectors = var.workloads_node_selectors
    })
  ]
}

resource "terraform_data" "storageprofile_status" {
  depends_on = [helm_release.operator]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/confirm-storageprofile-status.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}

resource "terraform_data" "update_storage_profile" {
  depends_on = [terraform_data.storageprofile_status]
  provisioner "local-exec" {
    command     = "${path.module}/scripts/update_storage_profile.sh ${var.vpc_file_default_storage_class} ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}
