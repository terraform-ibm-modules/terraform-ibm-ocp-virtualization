# Terraform IBM OpenShift Virtualization module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-ocp-virtualization?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-virtualization/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

This module configures Openshift Virtualization on an IBM Cloud Red Hat OpenShift Container Platform.


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-ocp-virtualization](#terraform-ibm-ocp-virtualization)
* [Examples](./examples)
    * [Basic example](./examples/basic)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and link to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-ocp-virtualization

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
# ############################################################################
# Init cluster config for helm
# ############################################################################

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = "xxxxxxxxx" # replace with cluster ID or name
}

# ############################################################################
# Config providers
# ############################################################################

provider "ibm" {
  ibmcloud_api_key = "xxxxxxxxxxxx"  # pragma: allowlist secret
}

provider "helm" {
  kubernetes {
    host                   = data.ibm_container_cluster_config.cluster_config.host
    token                  = data.ibm_container_cluster_config.cluster_config.token
    cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
  }
}

provider "kubernetes" {
  host                   = data.ibm_container_cluster_config.cluster_config.host
  token                  = data.ibm_container_cluster_config.cluster_config.token
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
}

# ############################################################################
# Install Virtualization
# ############################################################################

module "virtualization" {
  source                        = "terraform-ibm-modules/ocp-virtualization/ibm"
  version                       = "X.Y.Z" # replace with actual version of module to consume
  cluster_id                    = "xxxxxxx" # replace with ID of the cluster
  cluster_resource_group_id     = "xxxxxxx" # replace with ID of the cluster resource group
}
```

### Required access policies

### Required IAM access policies
You need the following permissions to run this module.

- Service
    - **Resource group only**
        - `Viewer` access on the specific resource group
    - **Kubernetes** service
        - `Viewer` platform access
        - `Manager` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.15.0, <3.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.78.3, <2.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.16.1, < 3.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [helm_release.operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.subscription](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map_v1_data.disable_default_storageclass](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [kubernetes_config_map_v1_data.set_vpc_file_default_storage_class](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [null_resource.config_map_status](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.enable_catalog_source](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.storageprofile_status](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.update_storage_profile](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_for_subscription](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_container_cluster_config.cluster_config](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/container_cluster_config) | data source |
| [ibm_container_vpc_cluster.cluster](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/container_vpc_cluster) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_config_endpoint_type"></a> [cluster\_config\_endpoint\_type](#input\_cluster\_config\_endpoint\_type) | Specify the type of endpoint to use to access the cluster configuration. Possible values: `default`, `private`, `vpe`, `link`. The `default` value uses the default endpoint of the cluster. | `string` | `"default"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ID of the cluster to deploy the agents in. | `string` | n/a | yes |
| <a name="input_cluster_resource_group_id"></a> [cluster\_resource\_group\_id](#input\_cluster\_resource\_group\_id) | The resource group ID of the cluster. | `string` | n/a | yes |
| <a name="input_infra_node_selectors"></a> [infra\_node\_selectors](#input\_infra\_node\_selectors) | List of infra node selectors to apply to HyperConverged pods. | <pre>list(object({<br/>    label  = string<br/>    values = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "label": "ibm-cloud.kubernetes.io/server-type",<br/>    "values": [<br/>      "virtual",<br/>      "physical"<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_vpc_file_default_storage_class"></a> [vpc\_file\_default\_storage\_class](#input\_vpc\_file\_default\_storage\_class) | The name of the VPC File storage class which will be set as the default storage class. | `string` | `"ibmc-vpc-file-metro-1000-iops"` | no |
| <a name="input_wait_till"></a> [wait\_till](#input\_wait\_till) | To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, `IngressReady` and `Normal` | `string` | `"Normal"` | no |
| <a name="input_wait_till_timeout"></a> [wait\_till\_timeout](#input\_wait\_till\_timeout) | Timeout for wait\_till in minutes. | `number` | `90` | no |
| <a name="input_workloads_node_selectors"></a> [workloads\_node\_selectors](#input\_workloads\_node\_selectors) | List of workload node selectors to apply to HyperConverged pods. | <pre>list(object({<br/>    label  = string<br/>    values = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "label": "ibm-cloud.kubernetes.io/server-type",<br/>    "values": [<br/>      "physical"<br/>    ]<br/>  }<br/>]</pre> | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
