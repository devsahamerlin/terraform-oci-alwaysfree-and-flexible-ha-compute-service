# Terraform OCI Storage Module (IaC submodule)

Creates a private, versioned Object Storage bucket and one block volume per VM, attached as paravirtualized volumes. Optionally adds a daily incremental backup policy with 7-day retention (not Always Free: 5 free backups in total).

Internal submodule of the [OCI Always Free & Flexible HA Compute Stack](../../README.md), wired by the root module.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.33.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 6.33.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [oci_core_volume.block_volume](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.block_volume_attachment](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy.block_volume_backup](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume_backup_policy) | resource |
| [oci_core_volume_backup_policy_assignment.volume_backup_policy_assignment](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_objectstorage_bucket.main](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket) | resource |
| [oci_identity_availability_domains.ads](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domains) | data source |
| [oci_objectstorage_namespace.ns](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | OCI Compartment OCID | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_instance_ids"></a> [instance\_ids](#input\_instance\_ids) | OCIDs of the VM instances to attach the block volumes to (one volume per VM, same order as vm\_count) | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Number of VM instances | `number` | n/a | yes |
| <a name="input_block_volume_size_gb"></a> [block\_volume\_size\_gb](#input\_block\_volume\_size\_gb) | Size in GB of each block volume | `number` | `50` | no |
| <a name="input_enable_backups"></a> [enable\_backups](#input\_enable\_backups) | Enable automated backups for block volumes | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Object Storage Namespace | `string` | `""` | no |
| <a name="input_object_events_enabled"></a> [object\_events\_enabled](#input\_object\_events\_enabled) | Enables audit logging and compliance tracking, Allows automation based on object operations, required for security monitoring and alerting | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_policy_id"></a> [backup\_policy\_id](#output\_backup\_policy\_id) | OCID of the block volume backup policy (null when backups are disabled) |
| <a name="output_block_volume_ids"></a> [block\_volume\_ids](#output\_block\_volume\_ids) | OCIDs of the created block volumes |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the Object Storage bucket |
| <a name="output_bucket_namespace"></a> [bucket\_namespace](#output\_bucket\_namespace) | Namespace of the Object Storage bucket |
| <a name="output_volume_attachment_ids"></a> [volume\_attachment\_ids](#output\_volume\_attachment\_ids) | OCIDs of the block volume attachments |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
