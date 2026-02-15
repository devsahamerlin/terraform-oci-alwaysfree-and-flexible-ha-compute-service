variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "description" {
  description = "Description of the compartment"
  type        = string
}

variable "name" {
  description = "Name of the compartment"
  type        = string
}

variable "enable_delete" {
  description = "Enable deletion of the compartment"
  type        = bool
  default     = false
}