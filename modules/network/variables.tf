variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private (backend) subnet"
  type        = string
}

variable "database_subnet_cidr" {
  description = "CIDR block for the database subnet"
  type        = string
  default     = ""
}

variable "enable_database" {
  description = "Flag to enable database subnet creation"
  type        = bool
  default     = false
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "public_security_list_ingress_security_rules" {
  description = "Public Security List of ingress security rules"
  type = list(object({
    protocol  = string
    source    = string
    stateless = optional(bool, false)
    port_min  = optional(number)
    port_max  = optional(number)
    icmp_type = optional(number)
    icmp_code = optional(number)
  }))
}

variable "private_security_list_ingress_security_rules" {
  description = "Private Security List of ingress security rules"
  type = list(object({
    protocol  = string
    stateless = optional(bool, false)
    port_min  = optional(number) # Make optional for non-TCP/UDP
    port_max  = optional(number) # Make optional for non-TCP/UDP
    icmp_type = optional(number) # Support ICMP
    icmp_code = optional(number) # Support ICMP
  }))
}

variable "enable_egress_security_rules_stateless" {
  description = "Whether to enable stateless egress security rules"
  type        = bool
  default     = false
}
