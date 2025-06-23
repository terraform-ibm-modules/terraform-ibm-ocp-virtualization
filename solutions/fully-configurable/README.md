# Cloud automation for OpenShift Virtualization

This architecture configures Openshift Virtualization on a Red Hat OpenShift cluster.

## Before you begin

* Make sure that the Cluster is deployed.

* Make sure outbound traffic protection is disabled.

* Make sure following cluster addons are installed:
    - openshift-data-foundation
    - vpc-file-csi-driver

![monitoring-agent-deployable-architecture](../../reference-architecture/deployable-architecture-logs-agent.svg)

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
| <a name="module_virtualization"></a> [virtualization](#module\_virtualization) | ../.. | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_container_cluster_config.cluster_config](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.78.3/docs/data-sources/container_cluster_config) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_worker_pools"></a> [additional\_worker\_pools](#input\_additional\_worker\_pools) | List of additional worker pools with custom configurations to accommodate diverse VM workload requirements within the cluster. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-virtualization/blob/main/solutions/fully-configurable/DA_docs.md#options-with-worker-pools) | <pre>list(object({<br/>    vpc_subnets = optional(list(object({<br/>      id         = string<br/>      zone       = string<br/>      cidr_block = string<br/>    })), [])<br/>    pool_name                     = string<br/>    machine_type                  = string<br/>    workers_per_zone              = number<br/>    operating_system              = string<br/>    labels                        = optional(map(string))<br/>    minSize                       = optional(number)<br/>    secondary_storage             = optional(string)<br/>    maxSize                       = optional(number)<br/>    enableAutoscaling             = optional(bool)<br/>    additional_security_group_ids = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_config_endpoint_type"></a> [cluster\_config\_endpoint\_type](#input\_cluster\_config\_endpoint\_type) | Specify the type of endpoint to use to access the cluster configuration. Possible values: `default`, `private`, `vpe`, `link`. The `default` value uses the default endpoint of the cluster. | `string` | `"default"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ID of the cluster to deploy the agents in. | `string` | n/a | yes |
| <a name="input_cluster_resource_group_id"></a> [cluster\_resource\_group\_id](#input\_cluster\_resource\_group\_id) | The resource group ID of the cluster. | `string` | n/a | yes |
| <a name="input_default_worker_pool_machine_type"></a> [default\_worker\_pool\_machine\_type](#input\_default\_worker\_pool\_machine\_type) | Specifies the machine type for the default worker pool. This determines the CPU, memory, and disk resources available to each worker node. For OpenShift Virtualization installation, machines should be VPC bare metal servers. Refer [IBM Cloud documentation for available machine types](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-flavors) | `string` | `"cx2d.metal.96x192"` | no |
| <a name="input_default_worker_pool_operating_system"></a> [default\_worker\_pool\_operating\_system](#input\_default\_worker\_pool\_operating\_system) | Provide the operating system for the worker nodes in the default worker pool. OpenShift Virtualization installation is supported only on RHCOS operating system. Refer [here](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift_versions) for supported Operating Systems | `string` | `"RHCOS"` | no |
| <a name="input_default_worker_pool_workers_per_zone"></a> [default\_worker\_pool\_workers\_per\_zone](#input\_default\_worker\_pool\_workers\_per\_zone) | Defines the number of worker nodes to provision in each zone for the default worker pool. Overall cluster must have at least 2 worker nodes, but individual worker pools may have fewer nodes per zone. | `number` | `2` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key. | `string` | n/a | yes |
| <a name="input_infra_node_selectors"></a> [infra\_node\_selectors](#input\_infra\_node\_selectors) | List of infra node selectors to apply to HyperConverged pods. | <pre>list(object({<br/>    label  = string<br/>    values = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "label": "ibm-cloud.kubernetes.io/server-type",<br/>    "values": [<br/>      "virtual",<br/>      "physical"<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_ocp_version"></a> [ocp\_version](#input\_ocp\_version) | Version of the OCP cluster to provision. OpenShift Virtualization is supported from ocp version 4.17 and above. | `string` | `"4.17"` | no |
| <a name="input_vpc_file_default_storage_class"></a> [vpc\_file\_default\_storage\_class](#input\_vpc\_file\_default\_storage\_class) | The name of the VPC File storage class which will be set as the default storage class. | `string` | `"ibmc-vpc-file-metro-1000-iops"` | no |
| <a name="input_wait_till"></a> [wait\_till](#input\_wait\_till) | To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, `IngressReady` and `Normal` | `string` | `"Normal"` | no |
| <a name="input_wait_till_timeout"></a> [wait\_till\_timeout](#input\_wait\_till\_timeout) | Timeout for wait\_till in minutes. | `number` | `90` | no |
| <a name="input_workloads_node_selectors"></a> [workloads\_node\_selectors](#input\_workloads\_node\_selectors) | List of workload node selectors to apply to HyperConverged pods. | <pre>list(object({<br/>    label  = string<br/>    values = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "label": "ibm-cloud.kubernetes.io/server-type",<br/>    "values": [<br/>      "physical"<br/>    ]<br/>  }<br/>]</pre> | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
