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
