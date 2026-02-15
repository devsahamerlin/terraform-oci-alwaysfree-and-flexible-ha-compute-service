variable "bastion_id" {
  description = "OCID of the Bastion service"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for the session"
  type        = string
}

variable "target_resource_id" {
  description = "OCID of the target resource (VM)"
  type        = string
}

variable "target_resource_operating_system_user_name" {
  description = "OS username for the session"
  type        = string
}

variable "target_resource_private_ip_address" {
  description = "Private IP of the target resource"
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

variable "vm_name" {
  description = "Name of the VM for display purposes"
  type        = string
}