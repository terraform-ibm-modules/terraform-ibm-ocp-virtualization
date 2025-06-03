# Cloud automation for OpenShift Virtualization

This quickstart architecture configures Openshift Virtualization on a Red Hat OpenShift cluster.


![virtualization-deployable-architecture](../../reference-architecture/deployable-architecture-logs-agent.svg)

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.78.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.37.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ocp_base"></a> [ocp\_base](#module\_ocp\_base) | terraform-ibm-modules/base-ocp-vpc/ibm | 3.49.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.2.0 |
| <a name="module_virtualization"></a> [virtualization](#module\_virtualization) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-ibm-modules/landing-zone-vpc/ibm | 7.23.12 |

### Resources

| Name | Type |
|------|------|
| [ibm_container_cluster_config.cluster_config](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.78.3/docs/data-sources/container_cluster_config) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the resources created by the module. | `list(string)` | `[]` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | Map of OCP cluster add-on versions to install (NOTE: The 'vpc-block-csi-driver' add-on is installed by default for VPC clusters and 'ibm-storage-operator' is installed by default in OCP 4.15 and later, however you can explicitly specify it here if you wish to choose a later version than the default one). For full list of all supported add-ons and versions, see https://cloud.ibm.com/docs/containers?topic=containers-supported-cluster-addon-versions. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-virtualization/blob/main/solutions/quickstart/DA_docs.md#options-with-addons) | <pre>object({<br/>    debug-tool = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>    image-key-synchronizer = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>    openshift-data-foundation = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>    vpc-file-csi-driver = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>    static-route = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>    cluster-autoscaler = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>    vpc-block-csi-driver = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>    ibm-storage-operator = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>    openshift-ai = optional(object({<br/>      version         = optional(string)<br/>      parameters_json = optional(string)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "openshift-data-foundation": {<br/>    "parameters_json": "        {\n            \"osdStorageClassName\":\"localblock\",\n            \"odfDeploy\":\"true\",\n            \"autoDiscoverDevices\":\"true\"\n        }\n",<br/>    "version": null<br/>  },<br/>  "vpc-file-csi-driver": {<br/>    "version": null<br/>  }<br/>}</pre> | no |
| <a name="input_address_prefix"></a> [address\_prefix](#input\_address\_prefix) | The IP range that will be defined for the VPC for a certain location. Use only with manual address prefixes. | `string` | `"10.10.10.0/24"` | no |
| <a name="input_cluster_config_endpoint_type"></a> [cluster\_config\_endpoint\_type](#input\_cluster\_config\_endpoint\_type) | Specify the type of endpoint to use to access the cluster configuration. Possible values: `default`, `private`, `vpe`, `link`. The `default` value uses the default endpoint of the cluster. | `string` | `"default"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the new IBM Cloud OpenShift Cluster. If a `prefix` input variable is specified, it is added to this name in the `<prefix>-value` format. | `string` | `"openshift"` | no |
| <a name="input_cluster_ready_when"></a> [cluster\_ready\_when](#input\_cluster\_ready\_when) | The cluster is ready based on one of the following:: MasterNodeReady (not recommended), OneWorkerNodeReady, Normal, IngressReady. | `string` | `"IngressReady"` | no |
| <a name="input_cluster_resource_tags"></a> [cluster\_resource\_tags](#input\_cluster\_resource\_tags) | Metadata labels describing this cluster deployment, i.e. test. | `list(string)` | `[]` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group to provision the cluster. | `string` | `"Default"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key. | `string` | n/a | yes |
| <a name="input_infra_node_selectors"></a> [infra\_node\_selectors](#input\_infra\_node\_selectors) | List of infra node selectors to apply to HyperConverged pods. | <pre>list(object({<br/>    label  = string<br/>    values = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "label": "ibm-cloud.kubernetes.io/server-type",<br/>    "values": [<br/>      "virtual",<br/>      "physical"<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Specifies the machine type for the default worker pool. This determines the CPU, memory, and disk resources available to each worker node. For OpenShift Virtualization installation, machines should be VPC bare metal servers. Refer [IBM Cloud documentation for available machine types](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-flavors) | `string` | `"cx2d.metal.96x192"` | no |
| <a name="input_ocp_entitlement"></a> [ocp\_entitlement](#input\_ocp\_entitlement) | Value that is applied to the entitlements for OCP cluster provisioning | `string` | `null` | no |
| <a name="input_ocp_version"></a> [ocp\_version](#input\_ocp\_version) | Version of the OCP cluster to provision | `string` | `"4.17"` | no |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | Provide the operating system for the worker nodes in the default worker pool. OpenShift Virtualization installation is supported only on RHCOS operating system. Refer [here](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift_versions) for supported Operating Systems | `string` | `"RHCOS"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: wx-0205-openshift. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to provision all resources created by this example | `string` | `"us-south"` | no |
| <a name="input_vpc_file_default_storage_class"></a> [vpc\_file\_default\_storage\_class](#input\_vpc\_file\_default\_storage\_class) | The name of the VPC File storage class which will be set as the default storage class. | `string` | `"ibmc-vpc-file-metro-1000-iops"` | no |
| <a name="input_vpc_resource_tags"></a> [vpc\_resource\_tags](#input\_vpc\_resource\_tags) | Metadata labels describing this vpc deployment, i.e. test. | `list(string)` | `[]` | no |
| <a name="input_wait_till"></a> [wait\_till](#input\_wait\_till) | To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, `IngressReady` and `Normal` | `string` | `"Normal"` | no |
| <a name="input_wait_till_timeout"></a> [wait\_till\_timeout](#input\_wait\_till\_timeout) | Timeout for wait\_till in minutes. | `number` | `90` | no |
| <a name="input_workers_per_zone"></a> [workers\_per\_zone](#input\_workers\_per\_zone) | Defines the number of worker nodes to provision in each zone for the default worker pool. Overall cluster must have at least 2 worker nodes. | `number` | `2` | no |
| <a name="input_workloads_node_selectors"></a> [workloads\_node\_selectors](#input\_workloads\_node\_selectors) | List of workload node selectors to apply to HyperConverged pods. | <pre>list(object({<br/>    label  = string<br/>    values = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "label": "ibm-cloud.kubernetes.io/server-type",<br/>    "values": [<br/>      "physical"<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Specify the zone to which the cluster will be deployed. | `number` | `1` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_crn"></a> [cluster\_crn](#output\_cluster\_crn) | The Cloud Resource Name (CRN) of the provisioned OpenShift cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The unique identifier assigned to the provisioned OpenShift cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the provisioned OpenShift cluster. |
| <a name="output_cos_crn"></a> [cos\_crn](#output\_cos\_crn) | The Cloud Resource Name (CRN) of the Object Storage instance associated with the cluster. |
| <a name="output_ingress_hostname"></a> [ingress\_hostname](#output\_ingress\_hostname) | The hostname assigned to the Cluster's Ingress subdomain for external access. |
| <a name="output_master_status"></a> [master\_status](#output\_master\_status) | The current status of the Kubernetes master node in the cluster. |
| <a name="output_master_url"></a> [master\_url](#output\_master\_url) | The API endpoint URL for the Kubernetes master node of the cluster. |
| <a name="output_ocp_version"></a> [ocp\_version](#output\_ocp\_version) | The version of OpenShift running on the provisioned cluster. |
| <a name="output_operating_system"></a> [operating\_system](#output\_operating\_system) | The operating system used by the worker nodes in the default worker pool. |
| <a name="output_public_service_endpoint_url"></a> [public\_service\_endpoint\_url](#output\_public\_service\_endpoint\_url) | The public service endpoint URL for accessing the cluster over the internet. |
| <a name="output_region"></a> [region](#output\_region) | The IBM Cloud region where the cluster is deployed. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the resource group where the cluster is deployed. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the Virtual Private Cloud (VPC) in which the cluster is deployed. |
| <a name="output_workerpools"></a> [workerpools](#output\_workerpools) | A list of worker pools associated with the provisioned cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
