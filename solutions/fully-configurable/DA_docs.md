# Configuring complex inputs for OCP in IBM Cloud projects

Several optional input variables in the Red Hat OpenShift cluster [Deployable Architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You can specify these inputs when you configure your deployable architecture.

- [Additional Worker Pools](#options-with-additional-worker-pools) (`additional_worker_pools`)


## Options with additional_worker_pools <a name="options-with-additional-worker-pools"></a>

This variable defines the worker node pools for the Red Hat OpenShift cluster, with each pool having its own configuration settings.

- Variable name: `additional_worker_pools`.
- Type: A list of objects. Each object represents a `worker_pool` configuration.
- Default value: An empty list (`[]`).

### Options for additional_worker_pools

- `vpc_subnets` (optional): (List) A list of object which specify which all subnets the worker pool should deploy its nodes.
  - `id` (required): A unique identifier for the VPC subnet.
  - `zone` (required): The zone where the subnet is located.
  - `cidr_block` (required): This defines the IP address range for the subnet in CIDR notation.
- `pool_name` (required): The name of the worker pool.
- `machine_type` (required): The machine type for worker nodes.
- `workers_per_zone` (required): Number of worker nodes in each zone of the cluster.
- `operating_system` (required): The operating system installed on the worker nodes.
- `labels` (optional): A set of key-value labels assigned to the worker pool for identification.
- `minSize` (optional): The minimum number of worker nodes allowed in the pool.
- `maxSize` (optional): The maximum number of worker nodes allowed in the pool.
- `secondary_storage` (optional): The secondary storage attached to the worker nodes. Secondary storage is immutable and can't be changed after provisioning.
- `enableAutoscaling` (optional): Set `true` to enable automatic scaling of worker based on workload demand.
- `additional_security_group_ids` (optional): A list of security group IDs that are attached to the worker nodes for additional network security controls.

### Example for additional_worker_pools configuration

```hcl
[
  {
    pool_name                         = "infra"
    machine_type                      = "gx3.16x80.l4"
    workers_per_zone                  = 2
    secondary_storage                 = "300gb.5iops-tier"
    operating_system                  = "RHCOS"
  }
]
```

## Options with `infra_node_selectors` <a name="options-with-infra"></a>

This variable configuration allows you to specify a list of key-value pairs that define the node affinity for the Virtualization Operator resources within the cluster.

- Variable name: `infra_node_selectors`
- Type: A List objects representing infra node selectors.

### Options for infra_node_selectors

- `key` : The label key to match against on the node.
- `values` : (List) The list of allowed values for the name label.

### Example for infra_node_selectors configuration

```hcl
[{
    key  = "ibm-cloud.kubernetes.io/server-type"
    values = ["virtual", "physical"]
}]
```

## Options with `workloads_node_selectors` <a name="options-with-workload"></a>

This variable configuration allows you to specify a list of key-value pairs that define the node affinity for the Virtualization VM workloads resources within the cluster.

- Variable name: `workloads_node_selectors`
- Type: A List objects representing workload node selectors.

### Options for workloads_node_selectors

- `key` : The label key to match against on the node.
- `values` : (List) The list of allowed values for the name label.

### Example for workloads_node_selectors configuration

```hcl
[{
    key  = "ibm-cloud.kubernetes.io/server-type"
    values = ["physical"]
}]
```
