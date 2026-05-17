##############################################################################
# Deploy Virtual Machine using Helm Chart
##############################################################################

locals {
  vm_chart_location = "${path.module}/chart/vm"
}

resource "helm_release" "vm" {
  name             = var.vm_name
  chart            = local.vm_chart_location
  namespace        = var.vm_namespace
  create_namespace = var.create_namespace
  timeout          = var.helm_timeout
  wait             = var.helm_wait
  recreate_pods    = true
  force_update     = true

  values = [
    yamlencode({
      vm = {
        name         = var.vm_name
        running      = var.vm_running
        cores        = var.vm_cores
        memory       = var.vm_memory
        storageClass = var.storage_class
        diskSize     = var.disk_size
        image        = var.vm_image
        username     = var.vm_username
        password     = var.vm_password
        sshPublicKey = var.ssh_public_key
        cloudInit    = var.cloud_init_user_data
        nodeSelector = var.node_selector
      }
      network = {
        type             = var.network_type
        exposeSshService = var.expose_ssh_service
      }
    })
  ]
}