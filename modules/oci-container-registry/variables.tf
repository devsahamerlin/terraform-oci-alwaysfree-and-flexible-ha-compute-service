variable "region_key" {
  description = "Region key for OCIR (e.g., iad, phx, fra)"
  type        = string
}

variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
}

variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
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

variable "github_actions_public_key" {
  description = "Public key for GitHub Actions API access (optional)"
  type        = string
  default     = ""
}

variable "user_email" {
  description = "Email for GitHub Actions user (optional)"
  type        = string
  default     = ""
}

variable "create_vault_secret" {
  description = "Create Vault secret for auth token"
  type        = bool
  default     = false
}

variable "vault_id" {
  description = "Vault ID for storing secrets"
  type        = string
  default     = ""
}

variable "vault_key_id" {
  description = "Vault Key ID for encrypting secrets"
  type        = string
  default     = ""
}
