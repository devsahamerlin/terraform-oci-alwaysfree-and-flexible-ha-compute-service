# Terraform OCI Load Balancer Module (IaC submodule)

Creates an OCI Flexible Load Balancer fixed at 10 Mbps (the Always Free shape), a round-robin backend set with HTTP health checks, one backend per VM, path route rules, and either an HTTP listener or an HTTPS listener with the provided certificate (`is_ssl_enabled`).

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
| [oci_load_balancer_backend.app_backends](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_backend) | resource |
| [oci_load_balancer_backend_set.app_backend_set](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_backend_set) | resource |
| [oci_load_balancer_certificate.certificate](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_certificate) | resource |
| [oci_load_balancer_listener.http_listener](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_listener) | resource |
| [oci_load_balancer_listener.https_listener](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_listener) | resource |
| [oci_load_balancer_load_balancer.app_lb](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_load_balancer) | resource |
| [oci_load_balancer_path_route_set.app_path_routes](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_path_route_set) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_backend_set_health_checker_port"></a> [app\_backend\_set\_health\_checker\_port](#input\_app\_backend\_set\_health\_checker\_port) | Port for the health checker | `number` | n/a | yes |
| <a name="input_app_backend_set_health_checker_url_path"></a> [app\_backend\_set\_health\_checker\_url\_path](#input\_app\_backend\_set\_health\_checker\_url\_path) | URL path for the health checker | `string` | n/a | yes |
| <a name="input_app_backends_port"></a> [app\_backends\_port](#input\_app\_backends\_port) | Port for the backend servers | `number` | n/a | yes |
| <a name="input_backend_set_backend_max_connections"></a> [backend\_set\_backend\_max\_connections](#input\_backend\_set\_backend\_max\_connections) | Maximum connections for the backend set | `number` | n/a | yes |
| <a name="input_backend_vm_ips"></a> [backend\_vm\_ips](#input\_backend\_vm\_ips) | List of backend VM private IPs | `list(string)` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | OCI Compartment OCID | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_is_private_lb"></a> [is\_private\_lb](#input\_is\_private\_lb) | Whether the load balancer is private | `bool` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the load balancer | `string` | n/a | yes |
| <a name="input_path_routes_1"></a> [path\_routes\_1](#input\_path\_routes\_1) | Path route 1 | `string` | n/a | yes |
| <a name="input_path_routes_2"></a> [path\_routes\_2](#input\_path\_routes\_2) | Path route 2 | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | List of subnet IDs for the load balancer | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_certificate_name"></a> [certificate\_name](#input\_certificate\_name) | Name of the SSL certificate | `string` | `null` | no |
| <a name="input_certificate_private_key"></a> [certificate\_private\_key](#input\_certificate\_private\_key) | Private key for the SSL certificate (PEM format) | `string` | `null` | no |
| <a name="input_certificate_public_cert"></a> [certificate\_public\_cert](#input\_certificate\_public\_cert) | Public certificate for the SSL certificate (PEM format) | `string` | `null` | no |
| <a name="input_is_ssl_enabled"></a> [is\_ssl\_enabled](#input\_is\_ssl\_enabled) | Enable SSL/HTTPS for the load balancer listener | `bool` | `false` | no |
| <a name="input_lb_listener_port"></a> [lb\_listener\_port](#input\_lb\_listener\_port) | Port for the load balancer listener | `number` | `80` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_set_name"></a> [backend\_set\_name](#output\_backend\_set\_name) | Backend Set Name |
| <a name="output_lb_details"></a> [lb\_details](#output\_lb\_details) | Full Load Balancer resource attributes |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | Load Balancer ID |
| <a name="output_lb_public_ip"></a> [lb\_public\_ip](#output\_lb\_public\_ip) | Load Balancer IP address (public, or private when is\_private\_lb = true) |
| <a name="output_lb_shape"></a> [lb\_shape](#output\_lb\_shape) | Load Balancer Shape |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
