variable "domain_name" {
  description = "Domain name for the record"
  type        = string
}

variable "rtype" {
  description = "Record type (e.g., A, CNAME)"
  type        = string
}

variable "zone_name_or_id" {
  description = "Zone name or OCID"
  type        = string
}

variable "public_ip" {
  description = "Public IP address for the record"
  type        = string
}

variable "ttl" {
  description = "Time to Live (TTL) for the record"
  type        = number
}