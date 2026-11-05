# Terraform OCI Bastion Session Module (IaC submodule)

Creates a managed SSH session through the OCI Bastion service for one private VM. Sessions last 3 hours (`session_ttl_in_seconds = 10800`); the VM must run the Bastion plugin of the Oracle Cloud Agent.

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
| [oci_bastion_session.managed_ssh](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/bastion_session) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_id"></a> [bastion\_id](#input\_bastion\_id) | OCID of the Bastion service | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key for the session | `string` | n/a | yes |
| <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id) | OCID of the target resource (VM) | `string` | n/a | yes |
| <a name="input_target_resource_operating_system_user_name"></a> [target\_resource\_operating\_system\_user\_name](#input\_target\_resource\_operating\_system\_user\_name) | OS username for the session | `string` | n/a | yes |
| <a name="input_target_resource_private_ip_address"></a> [target\_resource\_private\_ip\_address](#input\_target\_resource\_private\_ip\_address) | Private IP of the target resource | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the VM for display purposes | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_session_id"></a> [bastion\_session\_id](#output\_bastion\_session\_id) | Bastion session ID for SSH access |
| <a name="output_bastion_session_ssh_metadata"></a> [bastion\_session\_ssh\_metadata](#output\_bastion\_session\_ssh\_metadata) | Bastion session IDs for SSH access |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
