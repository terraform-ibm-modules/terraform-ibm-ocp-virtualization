##############################################################################
# Virtual Machine Outputs
##############################################################################

output "vm_name" {
  description = "Name of the deployed virtual machine."
  value       = helm_release.vm.name
}

output "vm_namespace" {
  description = "Namespace where the VM is deployed."
  value       = helm_release.vm.namespace
}

output "vm_status" {
  description = "Status of the Helm release."
  value       = helm_release.vm.status
}

output "helm_release_version" {
  description = "Version of the Helm release."
  value       = helm_release.vm.version
}

output "vm_access_info" {
  description = "Information for accessing the VM."
  value = {
    vm_name        = var.vm_name
    namespace      = var.vm_namespace
    username       = var.vm_username
    ssh_enabled    = var.expose_ssh_service
    access_command = var.expose_ssh_service ? "kubectl get svc ${var.vm_name}-ssh -n ${var.vm_namespace}" : "virtctl console ${var.vm_name} -n ${var.vm_namespace}"
  }
}