# Terraform OCI DNS RRSet Module (IaC submodule)

Manages a DNS resource record set (for example an A record pointing a domain to a load balancer IP).

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
| [oci_dns_rrset.rrset](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/dns_rrset) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for the record | `string` | n/a | yes |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | Public IP address for the record | `string` | n/a | yes |
| <a name="input_rtype"></a> [rtype](#input\_rtype) | Record type (e.g., A, CNAME) | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Time to Live (TTL) for the record | `number` | n/a | yes |
| <a name="input_zone_name_or_id"></a> [zone\_name\_or\_id](#input\_zone\_name\_or\_id) | Zone name or OCID | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_rrset_id"></a> [rrset\_id](#output\_rrset\_id) | OCID of the DNS RRSet |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
