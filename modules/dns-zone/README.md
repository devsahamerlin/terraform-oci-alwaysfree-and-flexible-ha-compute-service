# Terraform OCI DNS Zone Module (IaC submodule)

Creates an OCI DNS zone (PRIMARY by default). Delegate the domain to the zone's OCI name servers at your registrar for it to resolve publicly. OCI DNS is not part of the Always Free resources.

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
| [oci_dns_zone.dns-zone](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/dns_zone) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | OCI Compartment OCID | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the DNS zone | `string` | n/a | yes |
| <a name="input_zone_type"></a> [zone\_type](#input\_zone\_type) | Type of the DNS zone (e.g., PRIMARY) | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | OCID of the DNS zone |
| <a name="output_zone_name"></a> [zone\_name](#output\_zone\_name) | Name of the DNS zone |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
