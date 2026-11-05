variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "frontend_domain_name" {
  description = "Domain name for the frontend load balancer (required when enable_dns = true)"
  type        = string
  default     = ""
}

variable "backend_domain_name" {
  description = "Domain name for the backend load balancer (required when enable_dns = true and enable_backend_lb = true)"
  type        = string
  default     = ""
}

variable "region" {
  description = "OCI Region. Always Free resources must be created in your tenancy home region"
  type        = string
  default     = "eu-marseille-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ha-backend"
}

variable "compartment_enable_delete" {
  description = "Allow terraform destroy to delete the compartment. Keep false to protect it; set true for ephemeral environments (CI, tests)"
  type        = bool
  default     = false
}

variable "vcn_cidr" {
  description = "VCN CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR block"
  type        = string
  default     = "10.0.2.0/24"
}

variable "database_subnet_cidr" {
  description = "Database subnet CIDR block (only created when enable_database = true and free_tier_mode = false)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "vm_count" {
  description = "Number of VM instances (use at least 2 for high availability)"
  type        = number
  default     = 2
}

variable "vm_shape" {
  description = "VM shape. free_tier_mode only allows VM.Standard.A1.Flex; any shape is allowed when free_tier_mode = false"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "vm_ocpus" {
  description = "Number of OCPUs per VM (Always Free A1: 2 OCPUs total across all VMs)"
  type        = number
  default     = 1
}

variable "vm_memory_gb" {
  description = "Memory in GB per VM (Always Free A1: 12 GB total across all VMs)"
  type        = number
  default     = 6
}

variable "vm_boot_volume_size_gb" {
  description = "Boot volume size in GB per VM (boot + block volumes share the 200 GB Always Free quota)"
  type        = number
  default     = 50
}

variable "ssh_public_key" {
  description = "SSH public key content (not a path) used for VM access and Bastion sessions, e.g. file(\"~/.ssh/id_rsa.pub\")"
  type        = string

  validation {
    condition     = can(regex("^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp(256|384|521)) ", trimspace(var.ssh_public_key)))
    error_message = "ssh_public_key must be the content of an OpenSSH public key (ssh-rsa, ssh-ed25519 or ecdsa-sha2-*), not a file path. Use file(\"~/.ssh/id_rsa.pub\")."
  }
}

variable "ssh_user" {
  description = "OS user for SSH and Bastion sessions (ubuntu for Canonical Ubuntu images, opc for Oracle Linux)"
  type        = string
  default     = "ubuntu"
}

variable "ubuntu_version" {
  description = "Canonical Ubuntu version used to look up the latest image when the region is not in instance_image_ocid"
  type        = string
  default     = "24.04"
}

variable "atp_db_name" {
  description = "Autonomous Database name"
  type        = string
  default     = "habackenddb"
}

variable "atp_admin_password" {
  description = "ATP admin password, required when enable_database = true (12-30 chars, upper, lower and number)"
  type        = string
  sensitive   = true
  default     = null
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to connect to the Bastion service. Restrict to your public IP (curl ifconfig.me) as x.x.x.x/32"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy  = "Terraform"
    CostCenter = "AlwaysFree"
  }
}

variable "github_actions_public_key" {
  description = "Public Key for GitHub Actions user (optional, leave empty to skip GitHub Actions setup)"
  default     = ""
  type        = string
}

variable "github_actions_email" {
  description = "Email for GitHub Actions user (optional, leave empty to skip GitHub Actions setup)"
  type        = string
  default     = ""
}

variable "instance_image_ocid" {
  description = "Map of region => image OCID overrides. Regions not listed fall back to the latest Canonical Ubuntu image compatible with vm_shape"
  type        = map(string)
  default = {
    us-phoenix-1           = "ocid1.image.oc1.phx.aaaaaaaa6hooptnlbfwr5lwemqjbu3uqidntrlhnt45yihfj222zahe7p3wq"
    us-ashburn-1           = "ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvt4jz4vc47qoc2ec4anha"
    eu-frankfurt-1         = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaadvi77prh3vjijhwe5xbd6kjg3n5ndxjcpod6om6qaiqeu3csof7a"
    uk-london-1            = "ocid1.image.oc1.uk-london-1.aaaaaaaaw5gvriwzjhzt2tnylrfnpanz5ndztyrv3zpwhlzxdbkqsjfkwxaq"
    eu-marseille-1-aarch64 = "ocid1.image.oc1.eu-marseille-1.aaaaaaaa457toyb4brqmdbcjdvjchspijbpjb3rubfddf7cgqrpfmjp55txq" # ubuntu aarch64
    eu-marseille-1         = "ocid1.image.oc1.eu-marseille-1.aaaaaaaawmjm3gek2tgwdbttgn6qyb5rzrrgrdaibeu6lyfgjgolh4kceumq" # good ubuntu Always Free-eligible
    eu-amsterdam-1         = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaai5hr6qpvn4crggx6qffx2ckkpgvozcebdi44ykspx5dxpabjm3vq" # good ubuntu Always Free-eligible
  }
}

variable "public_security_list_ingress_security_rules" {
  description = "Public Security List ingress rules (protocol: 6 = TCP, 17 = UDP, 1 = ICMP). SSH is not needed here: access goes through the OCI Bastion service"
  type = list(object({
    protocol  = string
    source    = string
    stateless = optional(bool, false)
    port_min  = optional(number)
    port_max  = optional(number)
    icmp_type = optional(number)
    icmp_code = optional(number)
  }))
  default = [
    {
      protocol = "6"
      port_min = 80
      port_max = 80
      source   = "0.0.0.0/0"
    },
    {
      protocol = "6"
      port_min = 443
      port_max = 443
      source   = "0.0.0.0/0"
    }
  ]
}

variable "private_security_list_ingress_security_rules" {
  description = "Private Security List ingress rules, allowed from the VCN CIDR only (protocol: 6 = TCP, 17 = UDP, 1 = ICMP). Must include the load balancer backend ports (8080 frontend, 8000 backend)"
  type = list(object({
    protocol  = string
    stateless = optional(bool, false)
    port_min  = optional(number)
    port_max  = optional(number)
    icmp_type = optional(number)
    icmp_code = optional(number)
  }))
  default = [
    {
      protocol = "6"
      port_min = 22
      port_max = 22
    },
    {
      protocol = "6"
      port_min = 80
      port_max = 80
    },
    {
      protocol = "6"
      port_min = 443
      port_max = 443
    },
    {
      protocol = "6"
      port_min = 1521
      port_max = 1522
    },
    {
      protocol = "6"
      port_min = 8000
      port_max = 8000
    },
    {
      protocol = "6"
      port_min = 8080
      port_max = 8080
    },
    {
      protocol = "6"
      port_min = 8443
      port_max = 8443
    },
  ]
}

variable "enable_database" {
  description = "Enable or disable the Autonomous Database"
  type        = bool
  default     = false
}

variable "enable_backend_lb" {
  description = "Enable or disable the private Backend Load Balancer (Always Free includes a single load balancer)"
  type        = bool
  default     = false
}

variable "enable_frontend_lb" {
  description = "Enable or disable the public Frontend Load Balancer"
  type        = bool
  default     = true
}

variable "enable_dns" {
  description = "Enable or disable OCI DNS zones and records (not part of Always Free; requires a domain delegated to OCI DNS)"
  type        = bool
  default     = false
}

variable "enable_storage" {
  description = "Enable or disable Storage resources (Object Storage bucket and one block volume attached per VM)"
  type        = bool
  default     = true
}

variable "block_volume_size_gb" {
  description = "Size in GB of the block volume attached to each VM when enable_storage = true"
  type        = number
  default     = 50
}

variable "enable_backups" {
  description = "Enable daily block volume backups (7-day retention). Exceeds the 5 Always Free backups, so it is rejected when free_tier_mode = true"
  type        = bool
  default     = false
}

variable "object_events_enabled" {
  description = "Enables audit logging and compliance tracking, Allows automation based on object operations, required for security monitoring and alerting"
  default     = true
  type        = bool
}

variable "enable_bastion" {
  description = "Enable or disable Bastion service"
  type        = bool
  default     = true
}

variable "enable_ocir" {
  description = "Enable or disable OCI Container Registry setup (creates tenancy-level IAM dynamic group and policies)"
  type        = bool
  default     = false
}

variable "cloud_init_config" {
  description = "Cloud-init configuration for instances"
  type        = string
  default     = ""
}

variable "is_pv_encryption_in_transit_enabled" {
  description = "Enable in-transit encryption for boot volumes. Protects data in transit between compute instance and boot volume. Prevents man-in-the-middle attacks on internal OCI network. Zero performance impact (hardware-accelerated). Required for many compliance frameworks (PCI-DSS, HIPAA, etc.)."
  type        = bool
  default     = true
}

variable "are_legacy_imds_endpoints_disabled" {
  description = "Disable legacy IMDS endpoints, IMDSv1 (legacy metadata service) is vulnerable to Server-Side Request Forgery (SSRF) attacks, Any compromised process on the instance can access sensitive metadata without authentication, This is a known attack vector used in real-world cloud breaches, Disabling legacy endpoints forces use of IMDSv2 which requires session tokens"
  default     = true
  type        = bool
}

variable "enable_egress_security_rules_stateless" {
  description = "Whether to enable stateless egress security rules"
  type        = bool
  default     = false
}

variable "free_tier_mode" {
  description = "Enforce Always Free limits (A1 shape, 2 OCPUs, 12 GB RAM, 1 load balancer, 200 GB block storage, no scheduled backups). Set to false to use paid shapes and resources"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Object Storage Namespace (optional, looked up automatically when empty)"
  type        = string
  default     = ""
}
