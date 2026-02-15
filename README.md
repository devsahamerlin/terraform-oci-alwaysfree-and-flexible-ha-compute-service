# OCI Always Free High Availability Infrastructure

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Terraform](https://img.shields.io/badge/Terraform-v1.5+-blueviolet.svg)
![OCI Always Free](https://img.shields.io/badge/OCI%20Always%20Free-Compliant-brightgreen.svg)


## The Challenge
Startups, students, and developers often need a reliable, production-grade infrastructure to host applications but face significant barriers:
- **High Cloud Costs**: Enterprise-grade features like Load Balancers and HA databases usually come with a steep price tag.
- **Complexity**: Setting up a secure Virtual Cloud Network (VCN) with public/private subnets, NAT gateways, and Bastion hosts is complex and error-prone.
- **Security Risks**: Default configurations often expose databases and backend services to the public internet.

## The Solution
This project provides a **fully automated, production-ready infrastructure stack** on Oracle Cloud Infrastructure (OCI) that leverages the **Always Free Tier**. 

It delivers a **High Availability (HA)** architecture with **zero estimated monthly cost**, featuring:
- **Redundancy**: Multiple compute instances behind a Load Balancer.
- **Security**: Strict network isolation with private subnets and Bastion access.
- **Scalability**: Auto-scaling Autonomous Database.
- **Automation**: One-click deployment using Terraform.

## Key Features
- **💰 100% Free**: Designed to fit entirely within OCI's Always Free limits (4 ARM OCPUs, 24GB RAM, 200GB Storage).
- **🛡️ Secure by Design**: Backend services and databases are isolated in private subnets. No public IPs on compute instances.
- **🚀 High Performance**: Uses ARM-based Ampere A1 instances which offer superior performance over traditional x86 micro instances.
- **🔄 High Availability**: Architecture designed to survive instance failures.

---

## Security & Compliance

This module provisions a production-ready OCI infrastructure
optimized for Always Free usage by default, but fully flexible
for paid instance types and horizontal scaling.

- Always Free compliant defaults
- Scalable to paid shapes
- Security best practices enforced with Checkov static analysis
- Bastion-based secure access
- Checkov static analysis & TFLint validation
- CI security scanning

Documented exceptions are defined in `.checkov.yaml`
with architectural justifications.

All skipped checks are risk-assessed and aligned
with OCI best practices.


## Technical Overview
This project automates the deployment of a secure, scalable, and cost-effective infrastructure stack using Terraform. It sets up a complete VCN with public, backend, and database subnets, deploys Nginx load balancers, and provisions an Autonomous Database.

## Architecture Diagram

```mermaid
graph TD
    User[User/Internet] -->|HTTPS| IGW[Internet Gateway]
    
    subgraph OCI_Region [OCI Region]
        subgraph VCN [Virtual Cloud Network]
            
            subgraph Public_Subnet [Public Subnet]
                FLB[Frontend Load Balancer]
                Bastion[Bastion Service]
            end
            
            subgraph Private_Subnet [Backend Subnet]
                VM1[Compute VM 1]
                VM2[Compute VM 2]
                VMn[... VM n]
                BLB[Backend Load Balancer]
            end

            subgraph Database_Subnet [Database Subnet]
                ATP[(Autonomous Database)]
            end
            
            NGW[NAT Gateway]
            SGW[Service Gateway]
        end
        
        OS[Object Storage]
    end
    
    IGW --> FLB
    FLB -->|Traffic| VM1
    FLB -->|Traffic| VM2
    FLB -.->|Traffic| VMn
    
    VM1 -->|Internal API| BLB
    VM2 -->|Internal API| BLB
    VMn -.->|Internal API| BLB
    
    BLB --> ATP
    
    VM1 -->|Updates| NGW
    VM2 -->|Updates| NGW
    VMn -.->|Updates| NGW
    
    VM1 -->|Backups/Assets| SGW
    VM2 -->|Backups/Assets| SGW
    VMn -.->|Backups/Assets| SGW
    SGW --> OS
    
    Bastion -.->|SSH| VM1
    Bastion -.->|SSH| VM2
    Bastion -.->|SSH| VMn
```

## Architecture Components

### Network
- **VCN**: Virtual Cloud Network with public, backend, and database subnets.
- **Internet Gateway**: Provides public access for the load balancer.
- **NAT Gateway**: Allows private subnet resources to access the internet for updates.
- **Service Gateway**: Enables secure access to OCI services (like Object Storage) without traversing the public internet.

### Compute
- **Instances**: 1 to 4 VM instances (ARM-based A1.Flex), configurable via `vm_count`.
- **High Availability**: Distributed across availability domains (where available) or fault domains to ensure redundancy.
- **Load Balancer**: Nginx configured as a load balancer with Let's Encrypt SSL for secure traffic distribution.
- **Automation**: Cloud-init scripts for automated instance provisioning and configuration.

### Database
- **Autonomous Transaction Processing (ATP)**: Fully managed, auto-scaling database.
- **Subnet**: Deployed in a dedicated private subnet for enhanced security.
- **Always Free Tier**: 1 OCPU and 20GB storage included.
- **Features**: Automatic backups, patching, and self-repairing capabilities.

### Storage
- **Object Storage**: Bucket for storing static assets and backups (20GB free).
- **Block Volumes**: Persistent storage for compute instances (200GB total free).

### Security
- **Bastion Service**: Secure, ephemeral SSH access to private instances without public IPs.
- **Security Lists & NSGs**: Granular network access control.
- **Private Subnets**: Backend and database resources are isolated from the public internet.

## Prerequisites

1. **OCI Account**: Sign up at [https://cloud.oracle.com/](https://cloud.oracle.com/).
2. **API Keys**: Generate API signing keys in the OCI Console.
3. **Terraform**: Install Terraform version >= 1.5.0.
4. **OCI CLI** (Optional): Useful for managing Bastion sessions and advanced operations.

## Integration as a Terraform Module

You can integrate this stack as a module into your existing Terraform infrastructure.

### Example Usage

```hcl
module "oci_ha_stack" {
  source = "git::https://github.com/your-username/terraform-oci-alwaysfree-production-ha-stack.git?ref=main"

  # OCI Authentication (Passed from parent module or environment variables)
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region

  # Project Settings
  project_name = "my-app"
  environment  = "prod"

  # Network Configuration
  vcn_cidr             = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  private_subnet_cidr  = "10.0.2.0/24"
  database_subnet_cidr = "10.0.3.0/24"
  public_security_list_ingress_security_rules  = var.public_security_list_ingress_security_rules
  private_security_list_ingress_security_rules = var.private_security_list_ingress_security_rules

  # Feature Flags
  enable_database    = true
  enable_frontend_lb = true
  enable_backend_lb  = true
  enable_bastion     = true
  enable_dns         = true
  enable_storage     = true
  enable_ocir        = true

  # Compute Settings
  vm_count     = 2 # from 1 to 4 for Always Free Resources
  vm_shape     = "VM.Standard.A1.Flex"
  ssh_public_key_path = "~/.ssh/id_rsa.pub"

  # Database Settings
  atp_db_name        = "myappdb"
  atp_admin_password = var.db_password # Pass sensitive variables securely

  # Domain Settings
  frontend_domain_name = "app.example.com"
  backend_domain_name  = "api.example.com"
  
  # Other
  github_actions_email      = "ci@example.com"
  github_actions_public_key = "ssh-rsa AAAA..."
  cloud_init_config = file("${path.module}/cloud-init.yaml")
}
```

**Note**: When using as a module, ensure that the OCI provider is configured in your root module. The module itself does not instantiate the provider to avoid conflicts.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.3.7 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.33.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.7.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend_dns_rrset"></a> [backend\_dns\_rrset](#module\_backend\_dns\_rrset) | ./modules/dns-zone-rrset | n/a |
| <a name="module_backend_dns_zone"></a> [backend\_dns\_zone](#module\_backend\_dns\_zone) | ./modules/dns-zone | n/a |
| <a name="module_backend_load_balancer"></a> [backend\_load\_balancer](#module\_backend\_load\_balancer) | ./modules/load_balancer | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/bastion | n/a |
| <a name="module_bastion_sessions"></a> [bastion\_sessions](#module\_bastion\_sessions) | ./modules/bastion-session | n/a |
| <a name="module_compartment"></a> [compartment](#module\_compartment) | ./modules/compartment | n/a |
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute-ubuntu | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_frontend_dns_rrset"></a> [frontend\_dns\_rrset](#module\_frontend\_dns\_rrset) | ./modules/dns-zone-rrset | n/a |
| <a name="module_frontend_dns_zone"></a> [frontend\_dns\_zone](#module\_frontend\_dns\_zone) | ./modules/dns-zone | n/a |
| <a name="module_frontend_load_balancer"></a> [frontend\_load\_balancer](#module\_frontend\_load\_balancer) | ./modules/load_balancer | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_ocir"></a> [ocir](#module\_ocir) | ./modules/oci-container-registry | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.free_tier_guard](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_for_instance](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_instance_configuration](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [tls_private_key.backend_lb_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.public_private_key_pair](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.backend_lb_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ssh_cidrs"></a> [allowed\_ssh\_cidrs](#input\_allowed\_ssh\_cidrs) | List of CIDR blocks allowed to SSH via Bastion | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_are_legacy_imds_endpoints_disabled"></a> [are\_legacy\_imds\_endpoints\_disabled](#input\_are\_legacy\_imds\_endpoints\_disabled) | Disable legacy IMDS endpoints, IMDSv1 (legacy metadata service) is vulnerable to Server-Side Request Forgery (SSRF) attacks, Any compromised process on the instance can access sensitive metadata without authentication, This is a known attack vector used in real-world cloud breaches, Disabling legacy endpoints forces use of IMDSv2 which requires session tokens | `bool` | `true` | no |
| <a name="input_atp_admin_password"></a> [atp\_admin\_password](#input\_atp\_admin\_password) | ATP admin password (min 12 chars, must include upper, lower, number) | `string` | `null` | no |
| <a name="input_atp_db_name"></a> [atp\_db\_name](#input\_atp\_db\_name) | Autonomous Database name | `string` | `"habackenddb"` | no |
| <a name="input_backend_domain_name"></a> [backend\_domain\_name](#input\_backend\_domain\_name) | Domain name for the backend load balancer | `string` | n/a | yes |
| <a name="input_cloud_init_config"></a> [cloud\_init\_config](#input\_cloud\_init\_config) | Cloud-init configuration for instances | `string` | `""` | no |
| <a name="input_database_subnet_cidr"></a> [database\_subnet\_cidr](#input\_database\_subnet\_cidr) | Database subnet CIDR block | `string` | `"10.0.3.0/24"` | no |
| <a name="input_enable_backend_lb"></a> [enable\_backend\_lb](#input\_enable\_backend\_lb) | Enable or disable the Backend Load Balancer | `bool` | `true` | no |
| <a name="input_enable_backups"></a> [enable\_backups](#input\_enable\_backups) | Enable automated backups for block volumes | `bool` | `true` | no |
| <a name="input_enable_bastion"></a> [enable\_bastion](#input\_enable\_bastion) | Enable or disable Bastion service | `bool` | `true` | no |
| <a name="input_enable_database"></a> [enable\_database](#input\_enable\_database) | Enable or disable the Autonomous Database | `bool` | `true` | no |
| <a name="input_enable_dns"></a> [enable\_dns](#input\_enable\_dns) | Enable or disable DNS resources | `bool` | `true` | no |
| <a name="input_enable_egress_security_rules_stateless"></a> [enable\_egress\_security\_rules\_stateless](#input\_enable\_egress\_security\_rules\_stateless) | Whether to enable stateless egress security rules | `bool` | `false` | no |
| <a name="input_enable_frontend_lb"></a> [enable\_frontend\_lb](#input\_enable\_frontend\_lb) | Enable or disable the Frontend Load Balancer | `bool` | `true` | no |
| <a name="input_enable_ocir"></a> [enable\_ocir](#input\_enable\_ocir) | Enable or disable OCI Container Registry | `bool` | `true` | no |
| <a name="input_enable_storage"></a> [enable\_storage](#input\_enable\_storage) | Enable or disable Storage resources | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_free_tier_mode"></a> [free\_tier\_mode](#input\_free\_tier\_mode) | Enable strict Always Free limits validation | `bool` | `true` | no |
| <a name="input_frontend_domain_name"></a> [frontend\_domain\_name](#input\_frontend\_domain\_name) | Domain name for the frontend load balancer | `string` | n/a | yes |
| <a name="input_github_actions_email"></a> [github\_actions\_email](#input\_github\_actions\_email) | Email for GitHub Actions user (optional, leave empty to skip GitHub Actions setup) | `string` | `""` | no |
| <a name="input_github_actions_public_key"></a> [github\_actions\_public\_key](#input\_github\_actions\_public\_key) | Public Key for GitHub Actions user (optional, leave empty to skip GitHub Actions setup) | `string` | `""` | no |
| <a name="input_instance_image_ocid"></a> [instance\_image\_ocid](#input\_instance\_image\_ocid) | n/a | `map(string)` | <pre>{<br/>  "eu-amsterdam-1": "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaai5hr6qpvn4crggx6qffx2ckkpgvozcebdi44ykspx5dxpabjm3vq",<br/>  "eu-frankfurt-1": "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaadvi77prh3vjijhwe5xbd6kjg3n5ndxjcpod6om6qaiqeu3csof7a",<br/>  "eu-marseille-1": "ocid1.image.oc1.eu-marseille-1.aaaaaaaawmjm3gek2tgwdbttgn6qyb5rzrrgrdaibeu6lyfgjgolh4kceumq",<br/>  "eu-marseille-1-aarch64": "ocid1.image.oc1.eu-marseille-1.aaaaaaaa457toyb4brqmdbcjdvjchspijbpjb3rubfddf7cgqrpfmjp55txq",<br/>  "uk-london-1": "ocid1.image.oc1.uk-london-1.aaaaaaaaw5gvriwzjhzt2tnylrfnpanz5ndztyrv3zpwhlzxdbkqsjfkwxaq",<br/>  "us-ashburn-1": "ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvt4jz4vc47qoc2ec4anha",<br/>  "us-phoenix-1": "ocid1.image.oc1.phx.aaaaaaaa6hooptnlbfwr5lwemqjbu3uqidntrlhnt45yihfj222zahe7p3wq"<br/>}</pre> | no |
| <a name="input_is_pv_encryption_in_transit_enabled"></a> [is\_pv\_encryption\_in\_transit\_enabled](#input\_is\_pv\_encryption\_in\_transit\_enabled) | Enable in-transit encryption for boot volumes. Protects data in transit between compute instance and boot volume. Prevents man-in-the-middle attacks on internal OCI network. Zero performance impact (hardware-accelerated). Required for many compliance frameworks (PCI-DSS, HIPAA, etc.). | `bool` | `true` | no |
| <a name="input_object_events_enabled"></a> [object\_events\_enabled](#input\_object\_events\_enabled) | Enables audit logging and compliance tracking, Allows automation based on object operations, required for security monitoring and alerting | `bool` | `true` | no |
| <a name="input_private_security_list_ingress_security_rules"></a> [private\_security\_list\_ingress\_security\_rules](#input\_private\_security\_list\_ingress\_security\_rules) | Private Security List of ingress security rules | <pre>list(object({<br/>    protocol = string<br/>    port_min = number<br/>    port_max = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "port_max": 22,<br/>    "port_min": 22,<br/>    "protocol": "6"<br/>  },<br/>  {<br/>    "port_max": 80,<br/>    "port_min": 80,<br/>    "protocol": "6"<br/>  },<br/>  {<br/>    "port_max": 443,<br/>    "port_min": 443,<br/>    "protocol": "6"<br/>  },<br/>  {<br/>    "port_max": 1522,<br/>    "port_min": 1521,<br/>    "protocol": "6"<br/>  },<br/>  {<br/>    "port_max": 8443,<br/>    "port_min": 8443,<br/>    "protocol": "6"<br/>  }<br/>]</pre> | no |
| <a name="input_private_subnet_cidr"></a> [private\_subnet\_cidr](#input\_private\_subnet\_cidr) | Private subnet CIDR block | `string` | `"10.0.2.0/24"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | `"ha-backend"` | no |
| <a name="input_public_security_list_ingress_security_rules"></a> [public\_security\_list\_ingress\_security\_rules](#input\_public\_security\_list\_ingress\_security\_rules) | Public Security List of ingress security rules | <pre>list(object({<br/>    protocol = string<br/>    port_min = number<br/>    port_max = number<br/>    source   = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "port_max": 22,<br/>    "port_min": 22,<br/>    "protocol": "6",<br/>    "source": "0.0.0.0/0"<br/>  },<br/>  {<br/>    "port_max": 80,<br/>    "port_min": 80,<br/>    "protocol": "6",<br/>    "source": "0.0.0.0/0"<br/>  },<br/>  {<br/>    "port_max": 443,<br/>    "port_min": 443,<br/>    "protocol": "6",<br/>    "source": "0.0.0.0/0"<br/>  }<br/>]</pre> | no |
| <a name="input_public_subnet_cidr"></a> [public\_subnet\_cidr](#input\_public\_subnet\_cidr) | Public subnet CIDR block | `string` | `"10.0.1.0/24"` | no |
| <a name="input_region"></a> [region](#input\_region) | OCI Region | `string` | `"eu-marseille-1"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to SSH public key for VM access | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | <pre>{<br/>  "CostCenter": "AlwaysFree",<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | OCI Tenancy OCID | `string` | n/a | yes |
| <a name="input_vcn_cidr"></a> [vcn\_cidr](#input\_vcn\_cidr) | VCN CIDR block | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vm_boot_volume_size_gb"></a> [vm\_boot\_volume\_size\_gb](#input\_vm\_boot\_volume\_size\_gb) | Boot volume size in GB | `number` | `50` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Number of VM instances | `number` | `2` | no |
| <a name="input_vm_memory_gb"></a> [vm\_memory\_gb](#input\_vm\_memory\_gb) | Memory in GB per VM (max 24GB for A1 free tier total) | `number` | `12` | no |
| <a name="input_vm_ocpus"></a> [vm\_ocpus](#input\_vm\_ocpus) | Number of OCPUs per VM (max 4 for A1 free tier total) | `number` | `2` | no |
| <a name="input_vm_shape"></a> [vm\_shape](#input\_vm\_shape) | VM shape (VM.Standard.E2.1.Micro or VM.Standard.A1.Flex) | `string` | `"VM.Standard.A1.Flex"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_atp_wallet_content"></a> [atp\_wallet\_content](#output\_atp\_wallet\_content) | Base64 encoded content of the ATP wallet (Sensitive) |
| <a name="output_autonomous_database_id"></a> [autonomous\_database\_id](#output\_autonomous\_database\_id) | OCID of the Autonomous Database |
| <a name="output_backend_load_balancer_public_ip"></a> [backend\_load\_balancer\_public\_ip](#output\_backend\_load\_balancer\_public\_ip) | Public IP of the Backend Load Balancer |
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | OCID of the Bastion Service |
| <a name="output_bastion_ssh_metadata"></a> [bastion\_ssh\_metadata](#output\_bastion\_ssh\_metadata) | Metadata for Bastion sessions (if any) |
| <a name="output_block_volume_ids"></a> [block\_volume\_ids](#output\_block\_volume\_ids) | OCIDs of the Block Volumes |
| <a name="output_database_connection_strings"></a> [database\_connection\_strings](#output\_database\_connection\_strings) | Connection strings for the Autonomous Database |
| <a name="output_database_subnet_id"></a> [database\_subnet\_id](#output\_database\_subnet\_id) | OCID of the Database Subnet |
| <a name="output_frontend_load_balancer_public_ip"></a> [frontend\_load\_balancer\_public\_ip](#output\_frontend\_load\_balancer\_public\_ip) | Public IP of the Frontent Load Balancer |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | OCIDs of the Compute Instances |
| <a name="output_instance_names"></a> [instance\_names](#output\_instance\_names) | Display names of the Compute Instances |
| <a name="output_instance_private_ips"></a> [instance\_private\_ips](#output\_instance\_private\_ips) | Private IP addresses of the Compute Instances |
| <a name="output_object_storage_bucket_name"></a> [object\_storage\_bucket\_name](#output\_object\_storage\_bucket\_name) | Name of the Object Storage Bucket |
| <a name="output_object_storage_namespace"></a> [object\_storage\_namespace](#output\_object\_storage\_namespace) | Object Storage Namespace |
| <a name="output_ocir_auth_token"></a> [ocir\_auth\_token](#output\_ocir\_auth\_token) | Auth token for OCIR login (Sensitive) |
| <a name="output_ocir_repository_url"></a> [ocir\_repository\_url](#output\_ocir\_repository\_url) | URL of the OCIR Repository |
| <a name="output_ocir_username"></a> [ocir\_username](#output\_ocir\_username) | Username for OCIR login (e.g. for GitHub Actions) |
| <a name="output_private_subnet_id"></a> [private\_subnet\_id](#output\_private\_subnet\_id) | OCID of the Private (Backend) Subnet |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | OCID of the Public Subnet |
| <a name="output_vcn_cidr"></a> [vcn\_cidr](#output\_vcn\_cidr) | CIDR block of the VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | OCID of the Virtual Cloud Network (VCN) |


## Setup Instructions (Standalone)

### 1. Get My Public IP Address
You can get your public IP address using the following command:

```bash
curl ifconfig.me
```
Use this IP to restrict access in your security rules (e.g., `5.78.28.166/32`).
- `/32` - Single IP (most restrictive, recommended for bastion services)
- `/24` - 256 IP addresses
- `/16` - 65,536 IP addresses

### 2. Generate OCI API Keys
Create a dedicated directory for your OCI keys and generate them:

```bash
mkdir -p ~/.oci
cd ~/.oci
openssl genrsa -out oci_api_key.pem 2048
chmod 600 oci_api_key.pem
openssl rsa -pubout -in oci_api_key.pem -out oci_api_key_public.pem
cat oci_api_key_public.pem
```
Upload the public key content to your OCI Console under **User Settings → API Keys → Add API Key**.

### 3. Configure Terraform Variables
Copy the example variable file and update it with your specific details:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your OCI tenancy, user, and region details
```

### 4. Initialize Terraform
Initialize the project to download the necessary providers and modules:

```bash
terraform init
```

### 5. Plan Deployment
Preview the changes that Terraform will make to your infrastructure:

```bash
# For local environment
terraform plan -var-file="env/local.tfvars"
```

### 6. Apply Infrastructure
Provision the resources in OCI:

```bash
terraform apply -var-file="env/local.tfvars" -auto-approve
```

### 7. Access Resources
After a successful apply, retrieve the output information:

```bash
terraform output
```

## Accessing VMs via Bastion

Since the compute instances are in a private subnet, you must use the OCI Bastion service to connect.

### 1. Create a Port Forwarding Session
Use the OCI CLI to create a session:

```bash
oci bastion session create-port-forwarding \
  --bastion-id <bastion_id_from_output> \
  --display-name "ssh-session" \
  --key-type PUB \
  --ssh-public-key-file ~/.ssh/id_rsa.pub \
  --target-private-ip <VM_PRIVATE_IP> \
  --target-port 22
```

### 2. Connect via SSH
Construct the SSH command using the session ID:

```bash
ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -i ~/.ssh/id_rsa -W %h:%p <bastion_session_id>@host.bastion.<region>.oci.oraclecloud.com" opc@<VM_PRIVATE_IP>
```

## Post-Deployment Configuration

### Nginx Configuration
The Nginx load balancer is configured to route traffic to your application.
- **Frontend**: Serves static content or proxies to the frontend application.
- **Backend**: Proxies API requests to the backend service.
- **SSL**: Secured using Let's Encrypt via Certbot.

To manually update upstream servers:
```bash
sudo vi /etc/nginx/conf.d/backend.conf
# Update upstream IPs with actual private IPs
sudo nginx -t
sudo systemctl reload nginx
```

### Database Connection
To connect to the ATP database:
1. Download the wallet:
   ```bash
   terraform output -raw atp_wallet_content | base64 -d > wallet.zip
   unzip wallet.zip -d ~/wallet
   ```
2. Configure your application or SQL client to use the wallet files.

### OCIR Workflow (Optional)
If you are using OCI Container Registry (OCIR):

```bash
# Get OCIR details
terraform output ocir_configuration

# Push images to OCIR
docker login <region>.ocir.io
docker push <region>.ocir.io/<namespace>/fastapi-backend:latest
docker push <region>.ocir.io/<namespace>/angular-frontend:latest
```

## Environment Management

You can manage multiple environments (dev, staging, prod) using Terraform workspaces and separate variable files.

```bash
# Switch to dev
terraform workspace new dev
terraform apply -var-file="env/dev.tfvars"

# Switch to prod
terraform workspace new prod
terraform apply -var-file="env/prod.tfvars"
```

## Cost Optimization
This entire stack is designed to fit within the **OCI Always Free Tier**:
- **Compute**: 4 OCPUs and 24GB RAM (ARM) are free.
- **Database**: 20GB Autonomous Database is free.
- **Storage**: 200GB Block Volume and 20GB Object Storage are free.
- **Networking**: 10TB outbound data transfer per month is free.

**Estimated Monthly Cost: $0.00**

## Security Best Practices

1. **Restrict SSH Access**: Use specific CIDR blocks (e.g., `YOUR_IP/32`) instead of `0.0.0.0/0`.
2. **Enable MFA**: Enable Multi-Factor Authentication on your OCI account.
3. **Rotate Credentials**: Regularly rotate database passwords, API keys, and SSH keys.
4. **Use Vault**: Store sensitive data in OCI Vault.
   ```bash
   oci vault secret create-base64 \
     --compartment-id <compartment_id> \
     --vault-id <vault_id> \
     --key-id <key_id> \
     --secret-name "db-password" \
     --secret-content-content "$(echo -n 'password' | base64)"
   ```

## Backup Strategy

- **Automated**: ATP Daily automatic backups, Object Storage Versioning.
- **Manual**:
  ```bash
  oci compute boot-volume-backup create \
    --boot-volume-id <boot_volume_id> \
    --display-name "vm-backup-$(date +%Y%m%d)"
  ```

## Troubleshooting

### Common Issues
- **Instance Capacity**: If A1.Flex instances are unavailable in your region, try a different region or retry later.
- **Terraform Locks**: If the state is locked, use `terraform force-unlock <lock_id>`.
- **Connectivity**: Ensure your IP is added to the allowed CIDR list for SSH access if restricted.

### Debugging Cloud-Init
If the instance is not configuring correctly, check the cloud-init logs:

```bash
# Check status
sudo cloud-init status --long

# View output logs
sudo cat /var/log/cloud-init-output.log

# View full logs
sudo cat /var/log/cloud-init.log | grep -A 20 "package-update-upgrade-install"
```

### Manual Nginx/Certbot Install (Fallback)
If cloud-init fails to install packages:

```bash
# Enable EPEL
sudo dnf install -y oracle-epel-release-el8
sudo dnf config-manager --enable ol8_developer_EPEL

# Install Nginx
sudo dnf install -y nginx

# Install Certbot
sudo dnf install -y snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install --classic certbot
```

## Cleanup
To remove all resources and avoid any potential future costs (if limits are exceeded):

```bash
terraform destroy -var-file="env/local.tfvars" -auto-approve
```

## License
MIT License. See the LICENSE file for details.
