variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
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

variable "enable_backups" {
  description = "Enable automated backups for block volumes"
  type        = bool
  default     = true
}

variable "vm_count" {
  description = "Number of VM instances"
  type        = number
}

variable "object_events_enabled" {
  description = "Enables audit logging and compliance tracking, Allows automation based on object operations, required for security monitoring and alerting"
  default     = true
  type        = bool
}

variable "namespace" {
  description = "Object Storage Namespace"
  type        = string
  default     = ""
}