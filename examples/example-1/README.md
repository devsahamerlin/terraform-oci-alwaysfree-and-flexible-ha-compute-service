# Example 1: Terraform IaC deployment of the OCI Always Free HA stack

This example deploys the [root module](../../README.md) with a working demo application, so you can see load balancing and Bastion access end to end, for $0.

## What gets deployed (defaults)

- **Network**: VCN with a public and a private subnet, internet / NAT / service gateways.
- **Compute**: 2 Ampere A1 VMs (1 OCPU / 6 GB each, the full Always Free quota) with no public IP. `cloud-init.yaml` installs Nginx and serves a page on ports 80, 8080 and 8000 that shows which instance answered.
- **Load balancer**: 1 public Flexible LB (10 Mbps), HTTP :80 → VMs :8080, health-checked.
- **Bastion**: OCI Bastion service and one managed SSH session per VM.
- **Storage**: a private, versioned bucket and one 50 GB block volume attached to each VM.

Database, backend load balancer, DNS and OCIR are disabled by default; enable them in `terraform.tfvars`. The module's guardrails reject any combination that leaves the Always Free tier while `free_tier_mode = true`.

## Prerequisites

1. An OCI account, and its **home region** (Always Free resources must be created there).
2. Terraform ≥ 1.5 (OpenTofu also works).
3. An OCI API signing key uploaded to your user (see the [root README](../../README.md#prerequisites)).
4. An SSH key pair, e.g. `ssh-keygen -t ed25519`.

## Configuration

```bash
cd examples/example-1
cp terraform.tfvars.example terraform.tfvars
# or keep several environments: cp terraform.tfvars.example env/dev.tfvars
```

Edit the values, at least:

```hcl
tenancy_ocid        = "ocid1.tenancy.oc1..aaaa..."
user_ocid           = "ocid1.user.oc1..aaaa..."
fingerprint         = "xx:xx:xx:..."
private_key_path    = "/absolute/path/to/oci_api_key.pem" # use an absolute path if ~ is not expanded
region              = "eu-marseille-1"                    # your home region
ssh_public_key_path = "~/.ssh/id_ed25519.pub"
allowed_ssh_cidrs   = ["203.0.113.10/32"]                 # curl ifconfig.me
```

A `401-NotAuthenticated` error almost always means a wrong `user_ocid`, `fingerprint` or `private_key_path`.

The state is stored locally in `states/dev/terraform.tfstate` (see `backend.tf`, which also lists remote backend options).

## Usage

```bash
terraform init
terraform plan -out tfplan.out              # or: terraform plan -var-file=env/dev.tfvars -out tfplan.out
terraform apply tfplan.out
```

The first apply takes about 15 minutes: the module waits 10 minutes for the Bastion plugin to start before creating the SSH sessions.

## Verify

**Load balancing**: requests alternate between the two VMs.

```bash
LB=$(terraform output -raw frontend_load_balancer_public_ip)
for i in 1 2 3 4; do curl -s "http://$LB/" | grep -o 'vm-[0-9]*'; done
```

**SSH through Bastion**:

```bash
terraform output bastion_connection_metadata   # copy the connection_command of a VM
```

Replace `<your-private-key-path>` with your private key (e.g. `~/.ssh/id_ed25519`). Sessions expire after 3 hours; run `terraform apply` to recreate them.

## Cleanup

```bash
terraform destroy
```

The compartment is kept by default (`compartment_enable_delete = false`). Set it to `true` before destroying if you want it removed too.

## Reference

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.3.7 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.33.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.6 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_oci_ha_stack"></a> [oci\_ha\_stack](#module\_oci\_ha\_stack) | ../../ | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_fingerprint"></a> [fingerprint](#input\_fingerprint) | OCI API Key Fingerprint | `string` | n/a | yes |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Path to OCI API private key | `string` | n/a | yes |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to the SSH public key file used for VM access and Bastion sessions (e.g. ~/.ssh/id\_rsa.pub) | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | OCI Tenancy OCID | `string` | n/a | yes |
| <a name="input_user_ocid"></a> [user\_ocid](#input\_user\_ocid) | OCI User OCID | `string` | n/a | yes |
| <a name="input_allowed_ssh_cidrs"></a> [allowed\_ssh\_cidrs](#input\_allowed\_ssh\_cidrs) | List of CIDR blocks allowed to SSH via Bastion | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_are_legacy_imds_endpoints_disabled"></a> [are\_legacy\_imds\_endpoints\_disabled](#input\_are\_legacy\_imds\_endpoints\_disabled) | Disable legacy IMDS endpoints, IMDSv1 (legacy metadata service) is vulnerable to Server-Side Request Forgery (SSRF) attacks, Any compromised process on the instance can access sensitive metadata without authentication, This is a known attack vector used in real-world cloud breaches, Disabling legacy endpoints forces use of IMDSv2 which requires session tokens | `bool` | `true` | no |
| <a name="input_atp_admin_password"></a> [atp\_admin\_password](#input\_atp\_admin\_password) | ATP admin password (min 12 chars, must include upper, lower, number) | `string` | `null` | no |
| <a name="input_atp_db_name"></a> [atp\_db\_name](#input\_atp\_db\_name) | Autonomous Database name | `string` | `"habackenddb"` | no |
| <a name="input_backend_domain_name"></a> [backend\_domain\_name](#input\_backend\_domain\_name) | Domain name for the backend load balancer | `string` | `""` | no |
| <a name="input_compartment_enable_delete"></a> [compartment\_enable\_delete](#input\_compartment\_enable\_delete) | Allow terraform destroy to delete the compartment (set true for ephemeral environments) | `bool` | `false` | no |
| <a name="input_database_subnet_cidr"></a> [database\_subnet\_cidr](#input\_database\_subnet\_cidr) | Database subnet CIDR block | `string` | `"10.0.3.0/24"` | no |
| <a name="input_enable_backend_lb"></a> [enable\_backend\_lb](#input\_enable\_backend\_lb) | Enable or disable the Backend Load Balancer | `bool` | `false` | no |
| <a name="input_enable_backups"></a> [enable\_backups](#input\_enable\_backups) | Enable daily block volume backups (rejected in free\_tier\_mode: exceeds the 5 Always Free backups) | `bool` | `false` | no |
| <a name="input_enable_bastion"></a> [enable\_bastion](#input\_enable\_bastion) | Enable or disable Bastion service | `bool` | `true` | no |
| <a name="input_enable_database"></a> [enable\_database](#input\_enable\_database) | Enable or disable the Autonomous Database | `bool` | `false` | no |
| <a name="input_enable_dns"></a> [enable\_dns](#input\_enable\_dns) | Enable or disable DNS resources (requires a domain delegated to OCI DNS) | `bool` | `false` | no |
| <a name="input_enable_frontend_lb"></a> [enable\_frontend\_lb](#input\_enable\_frontend\_lb) | Enable or disable the Frontend Load Balancer | `bool` | `true` | no |
| <a name="input_enable_ocir"></a> [enable\_ocir](#input\_enable\_ocir) | Enable or disable OCI Container Registry | `bool` | `false` | no |
| <a name="input_enable_storage"></a> [enable\_storage](#input\_enable\_storage) | Enable or disable Storage resources (bucket + one block volume attached per VM) | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_free_tier_mode"></a> [free\_tier\_mode](#input\_free\_tier\_mode) | Enable strict Always Free limits validation. Set to false to use paid shapes and resources beyond free tier limits. | `bool` | `true` | no |
| <a name="input_frontend_domain_name"></a> [frontend\_domain\_name](#input\_frontend\_domain\_name) | Domain name for the frontend load balancer | `string` | `""` | no |
| <a name="input_github_actions_email"></a> [github\_actions\_email](#input\_github\_actions\_email) | Email for GitHub Actions user (optional, leave empty to skip GitHub Actions setup) | `string` | `""` | no |
| <a name="input_github_actions_public_key"></a> [github\_actions\_public\_key](#input\_github\_actions\_public\_key) | Public Key for GitHub Actions user (optional, leave empty to skip GitHub Actions setup) | `string` | `""` | no |
| <a name="input_is_pv_encryption_in_transit_enabled"></a> [is\_pv\_encryption\_in\_transit\_enabled](#input\_is\_pv\_encryption\_in\_transit\_enabled) | Enable in-transit encryption for boot volumes. Protects data in transit between compute instance and boot volume. Prevents man-in-the-middle attacks on internal OCI network. Zero performance impact (hardware-accelerated). Required for many compliance frameworks (PCI-DSS, HIPAA, etc.). | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Object Storage Namespace | `string` | `""` | no |
| <a name="input_object_events_enabled"></a> [object\_events\_enabled](#input\_object\_events\_enabled) | Enables audit logging and compliance tracking, Allows automation based on object operations, required for security monitoring and alerting | `bool` | `true` | no |
| <a name="input_private_subnet_cidr"></a> [private\_subnet\_cidr](#input\_private\_subnet\_cidr) | Private subnet CIDR block | `string` | `"10.0.2.0/24"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | `"ha-stack"` | no |
| <a name="input_public_subnet_cidr"></a> [public\_subnet\_cidr](#input\_public\_subnet\_cidr) | Public subnet CIDR block | `string` | `"10.0.1.0/24"` | no |
| <a name="input_region"></a> [region](#input\_region) | OCI Region | `string` | `"eu-marseille-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | <pre>{<br/>  "CostCenter": "AlwaysFree",<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_vcn_cidr"></a> [vcn\_cidr](#input\_vcn\_cidr) | VCN CIDR block | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vm_boot_volume_size_gb"></a> [vm\_boot\_volume\_size\_gb](#input\_vm\_boot\_volume\_size\_gb) | Boot volume size in GB | `number` | `50` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Number of VM instances | `number` | `2` | no |
| <a name="input_vm_memory_gb"></a> [vm\_memory\_gb](#input\_vm\_memory\_gb) | Memory in GB per VM (Always Free A1: 12 GB total across all VMs) | `number` | `6` | no |
| <a name="input_vm_ocpus"></a> [vm\_ocpus](#input\_vm\_ocpus) | Number of OCPUs per VM (Always Free A1: 2 OCPUs total across all VMs) | `number` | `1` | no |
| <a name="input_vm_shape"></a> [vm\_shape](#input\_vm\_shape) | VM shape (free\_tier\_mode only allows VM.Standard.A1.Flex) | `string` | `"VM.Standard.A1.Flex"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_atp_wallet_content"></a> [atp\_wallet\_content](#output\_atp\_wallet\_content) | Base64 encoded content of the ATP wallet (Sensitive) |
| <a name="output_autonomous_database_id"></a> [autonomous\_database\_id](#output\_autonomous\_database\_id) | OCID of the Autonomous Database |
| <a name="output_backend_load_balancer_ip"></a> [backend\_load\_balancer\_ip](#output\_backend\_load\_balancer\_ip) | Private IP of the Backend Load Balancer |
| <a name="output_backup_policy_id"></a> [backup\_policy\_id](#output\_backup\_policy\_id) | OCID of the assigned backup policy |
| <a name="output_bastion_connection_metadata"></a> [bastion\_connection\_metadata](#output\_bastion\_connection\_metadata) | Connection metadata for Bastion sessions (if any) |
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | OCID of the Bastion Service |
| <a name="output_block_volume_ids"></a> [block\_volume\_ids](#output\_block\_volume\_ids) | OCIDs of the Block Volumes |
| <a name="output_database_connection_strings"></a> [database\_connection\_strings](#output\_database\_connection\_strings) | Connection strings for the Autonomous Database |
| <a name="output_database_subnet_id"></a> [database\_subnet\_id](#output\_database\_subnet\_id) | OCID of the Database Subnet |
| <a name="output_frontend_load_balancer_public_ip"></a> [frontend\_load\_balancer\_public\_ip](#output\_frontend\_load\_balancer\_public\_ip) | Public IP of the Frontend Load Balancer |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | OCIDs of the Compute Instances |
| <a name="output_instance_names"></a> [instance\_names](#output\_instance\_names) | Display names of the Compute Instances |
| <a name="output_instance_private_ips"></a> [instance\_private\_ips](#output\_instance\_private\_ips) | Private IP addresses of the Compute Instances |
| <a name="output_object_storage_bucket_name"></a> [object\_storage\_bucket\_name](#output\_object\_storage\_bucket\_name) | Name of the Object Storage Bucket |
| <a name="output_object_storage_namespace"></a> [object\_storage\_namespace](#output\_object\_storage\_namespace) | Object Storage Namespace |
| <a name="output_ocir_auth_token"></a> [ocir\_auth\_token](#output\_ocir\_auth\_token) | Auth token for OCIR login (Sensitive) |
| <a name="output_ocir_repository_url"></a> [ocir\_repository\_url](#output\_ocir\_repository\_url) | URL of the OCIR Repository |
| <a name="output_ocir_url"></a> [ocir\_url](#output\_ocir\_url) | OCIR registry endpoint (docker login host) |
| <a name="output_ocir_username"></a> [ocir\_username](#output\_ocir\_username) | Username for OCIR login (e.g. for GitHub Actions) |
| <a name="output_private_subnet_id"></a> [private\_subnet\_id](#output\_private\_subnet\_id) | OCID of the Private (Backend) Subnet |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | OCID of the Public Subnet |
| <a name="output_vcn_cidr"></a> [vcn\_cidr](#output\_vcn\_cidr) | CIDR block of the VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | OCID of the Virtual Cloud Network (VCN) |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
