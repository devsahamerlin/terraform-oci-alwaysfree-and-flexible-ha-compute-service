variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
}

variable "frontend_domain_name" {
  description = "Domain name for the frontend load balancer"
  type        = string
  default     = ""
}

variable "backend_domain_name" {
  description = "Domain name for the backend load balancer"
  type        = string
  default     = ""
}

variable "user_ocid" {
  description = "OCI User OCID"
  type        = string
}

variable "fingerprint" {
  description = "OCI API Key Fingerprint"
  type        = string
}

variable "private_key_path" {
  description = "Path to OCI API private key"
  type        = string
}

variable "region" {
  description = "OCI Region"
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
  default     = "ha-stack"
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
  description = "Database subnet CIDR block"
  type        = string
  default     = "10.0.3.0/24"
}

variable "vm_count" {
  description = "Number of VM instances"
  type        = number
  default     = 2
}

variable "vm_shape" {
  description = "VM shape (VM.Standard.E2.1.Micro or VM.Standard.A1.Flex)"
  type        = string
  default     = "VM.Standard.A1.Flex" # ARM-based for better free tier
}

variable "vm_ocpus" {
  description = "Number of OCPUs per VM (max 4 for A1 free tier total)"
  type        = number
  default     = 2
}

variable "vm_memory_gb" {
  description = "Memory in GB per VM (max 24GB for A1 free tier total)"
  type        = number
  default     = 12
}

variable "vm_boot_volume_size_gb" {
  description = "Boot volume size in GB"
  type        = number
  default     = 50
}

variable "atp_db_name" {
  description = "Autonomous Database name"
  type        = string
  default     = "habackenddb"
}

variable "atp_admin_password" {
  description = "ATP admin password (min 12 chars, must include upper, lower, number)"
  type        = string
  sensitive   = true
  default     = null
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH via Bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Remove 0.0.0.0/0 and use "your-public-ip/32"
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
  type = map(string)
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
  description = "Public Security List of ingress security rules"
  type = list(object({
    protocol = string
    port_min = number
    port_max = number
    source   = string
  }))
  default = [
    {
      protocol = "6"
      port_min = 22
      port_max = 22
      source   = "0.0.0.0/0"
    },
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
  description = "Private Security List of ingress security rules"
  type = list(object({
    protocol = string
    port_min = number
    port_max = number
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
      port_min = 8443
      port_max = 8443
    },
    {
      protocol = "6"
      port_min = 8080
      port_max = 8080
    },
    {
      protocol = "6"
      port_min = 8000
      port_max = 8000
    },
  ]
}

variable "enable_database" {
  description = "Enable or disable the Autonomous Database"
  type        = bool
  default     = false
}

variable "enable_backend_lb" {
  description = "Enable or disable the Backend Load Balancer"
  type        = bool
  default     = false
}

variable "enable_frontend_lb" {
  description = "Enable or disable the Frontend Load Balancer"
  type        = bool
  default     = true
}

variable "enable_dns" {
  description = "Enable or disable DNS resources"
  type        = bool
  default     = true
}

variable "enable_storage" {
  description = "Enable or disable Storage resources"
  type        = bool
  default     = false
}

variable "enable_backups" {
  description = "Enable automated backups for block volumes"
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
  description = "Enable or disable OCI Container Registry"
  type        = bool
  default     = false
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

variable "free_tier_mode" {
  description = "Enable strict Always Free limits validation. Set to false to use paid shapes and resources beyond free tier limits."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Object Storage Namespace"
  type        = string
  default     = ""
}
