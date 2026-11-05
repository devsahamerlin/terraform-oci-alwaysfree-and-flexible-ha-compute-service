# Terraform OCI Compartment Module (IaC submodule)

Creates an OCI compartment under the tenancy root to group all the stack's resources. With `enable_delete = false`, `terraform destroy` removes it from the state but keeps it in OCI.

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
| [oci_identity_compartment.compartment](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_compartment) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the compartment | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the compartment | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | OCI Tenancy OCID | `string` | n/a | yes |
| <a name="input_enable_delete"></a> [enable\_delete](#input\_enable\_delete) | Enable deletion of the compartment | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID of the created compartment |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
