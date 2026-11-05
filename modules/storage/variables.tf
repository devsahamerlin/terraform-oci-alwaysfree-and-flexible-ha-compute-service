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

variable "instance_ids" {
  description = "OCIDs of the VM instances to attach the block volumes to (one volume per VM, same order as vm_count)"
  type        = list(string)
}

variable "block_volume_size_gb" {
  description = "Size in GB of each block volume"
  type        = number
  default     = 50
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