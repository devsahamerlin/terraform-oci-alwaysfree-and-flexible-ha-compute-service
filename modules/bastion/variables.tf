variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID for the Bastion service"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to connect to the Bastion"
  type        = list(string)
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
