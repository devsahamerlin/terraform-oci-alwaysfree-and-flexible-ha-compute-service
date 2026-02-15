variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
}

variable "name" {
  description = "Name of the DNS zone"
  type        = string
}

variable "zone_type" {
  description = "Type of the DNS zone (e.g., PRIMARY)"
  type        = string
}