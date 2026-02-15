variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID for the database"
  type        = string
}

variable "db_name" {
  description = "Name of the Autonomous Database"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the Autonomous Database"
  type        = string
  sensitive   = true
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

variable "is_free_tier" {
  description = "Boolean flag to determine if the Autonomous Database should use the Always Free tier"
  type        = bool
}

variable "nsg_ids" {
  description = "List of Network Security Group OCIDs to associate with the Autonomous Database"
  type        = list(string)
  default     = []
}
