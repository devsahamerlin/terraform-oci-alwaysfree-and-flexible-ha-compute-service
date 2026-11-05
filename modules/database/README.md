# Terraform OCI Database Module (IaC submodule)

Deploys an Autonomous Transaction Processing (ATP) database and its wallet. With `is_free_tier = true` it is an Always Free ATP (public endpoint secured by mTLS, no private endpoint); otherwise it uses a private endpoint in `subnet_id`.

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
| [oci_database_autonomous_database.atp](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database) | resource |
| [oci_database_autonomous_database_wallet.atp_wallet](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database_wallet) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for the Autonomous Database | `string` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | OCI Compartment OCID | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the Autonomous Database | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_is_free_tier"></a> [is\_free\_tier](#input\_is\_free\_tier) | Boolean flag to determine if the Autonomous Database should use the Always Free tier | `bool` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet OCID for the database | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids) | List of Network Security Group OCIDs to associate with the Autonomous Database | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_atp_connection_strings"></a> [atp\_connection\_strings](#output\_atp\_connection\_strings) | Connection strings for the Autonomous Database |
| <a name="output_atp_connection_urls"></a> [atp\_connection\_urls](#output\_atp\_connection\_urls) | Connection URLs for the Autonomous Database |
| <a name="output_atp_id"></a> [atp\_id](#output\_atp\_id) | OCID of the Autonomous Database |
| <a name="output_atp_wallet_content"></a> [atp\_wallet\_content](#output\_atp\_wallet\_content) | Base64 encoded content of the database wallet |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
