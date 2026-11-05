# Terraform OCI OCIR Module (IaC submodule)

Configures an OCI Container Registry repository, a dynamic group and policy so the stack's VMs can pull images, and an optional GitHub Actions user, group, auth token and API key to push images. Creates tenancy-level IAM resources, so it needs administrator rights.

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
| [oci_artifacts_container_repository.backend_repository](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/artifacts_container_repository) | resource |
| [oci_identity_api_key.github_actions_api_key](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_api_key) | resource |
| [oci_identity_auth_token.github_actions_token](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_auth_token) | resource |
| [oci_identity_dynamic_group.vm_dynamic_group](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group) | resource |
| [oci_identity_group.github_actions_group](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_group) | resource |
| [oci_identity_policy.github_actions_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_identity_policy.ocir_pull_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_identity_user.github_actions_user](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_user) | resource |
| [oci_identity_user_group_membership.github_actions_membership](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_user_group_membership) | resource |
| [oci_vault_secret.github_actions_token](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vault_secret) | resource |
| [oci_objectstorage_namespace.tenancy_namespace](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | OCI Compartment OCID | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_region_key"></a> [region\_key](#input\_region\_key) | Region key for OCIR (e.g., iad, phx, fra) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | OCI Tenancy OCID | `string` | n/a | yes |
| <a name="input_create_vault_secret"></a> [create\_vault\_secret](#input\_create\_vault\_secret) | Create Vault secret for auth token | `bool` | `false` | no |
| <a name="input_github_actions_public_key"></a> [github\_actions\_public\_key](#input\_github\_actions\_public\_key) | Public key for GitHub Actions API access (optional) | `string` | `""` | no |
| <a name="input_user_email"></a> [user\_email](#input\_user\_email) | Email for GitHub Actions user (optional) | `string` | `""` | no |
| <a name="input_vault_id"></a> [vault\_id](#input\_vault\_id) | Vault ID for storing secrets | `string` | `""` | no |
| <a name="input_vault_key_id"></a> [vault\_key\_id](#input\_vault\_key\_id) | Vault Key ID for encrypting secrets | `string` | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamic_group_id"></a> [dynamic\_group\_id](#output\_dynamic\_group\_id) | Dynamic group OCID for VM instances |
| <a name="output_github_actions_auth_token"></a> [github\_actions\_auth\_token](#output\_github\_actions\_auth\_token) | Auth token for GitHub Actions (sensitive - store in GitHub Secrets) |
| <a name="output_github_actions_user_ocid"></a> [github\_actions\_user\_ocid](#output\_github\_actions\_user\_ocid) | OCID of the GitHub Actions user |
| <a name="output_github_actions_username"></a> [github\_actions\_username](#output\_github\_actions\_username) | Username for GitHub Actions (use with auth token for OCIR login) |
| <a name="output_ocir_namespace"></a> [ocir\_namespace](#output\_ocir\_namespace) | OCIR namespace for this tenancy |
| <a name="output_ocir_repository_repository_id"></a> [ocir\_repository\_repository\_id](#output\_ocir\_repository\_repository\_id) | OCID backend of the container repository |
| <a name="output_ocir_repository_url"></a> [ocir\_repository\_url](#output\_ocir\_repository\_url) | Full backend URL for the container repository |
| <a name="output_ocir_url"></a> [ocir\_url](#output\_ocir\_url) | OCIR registry endpoint (docker login host) |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
