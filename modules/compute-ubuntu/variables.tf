variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID for the VMs"
  type        = string
}

variable "vm_count" {
  description = "Number of VM instances to create"
  type        = number
}

variable "vm_shape" {
  description = "Shape of the VM instances"
  type        = string
}

variable "vm_ocpus" {
  description = "Number of OCPUs per VM"
  type        = number
}

variable "vm_memory_gb" {
  description = "Memory in GB per VM"
  type        = number
}

variable "vm_boot_volume_size_gb" {
  description = "Boot volume size in GB"
  type        = number
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
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

variable "bastion" {
  description = "State of the Bastion plugin (ENABLED/DISABLED)"
  type        = string
}

variable "os_manegement_service_agent" {
  description = "State of the OS Management Service Agent plugin (ENABLED/DISABLED)"
  type        = string
}

variable "instance_image_ocid" {
  description = "OCID of the image to use for the instances"
  type        = string
}

variable "cloud_init_config" {
  description = "Cloud-init configuration content"
  type        = string
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